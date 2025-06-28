//
//  CheckinButton.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/10.
//

import SwiftUI
import os

struct CheckinButton: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSettings: AppSettings
    @Binding var isCheckInSucceeded : Bool
    
    
    var body: some View {
        Button {
            checkIn { success in
                if success{
                    isCheckInSucceeded = true
                    Task{
                        await fetchUserProfile()
                    }
                    os_log("successfully Check in !!!", log: .default, type: .info)
                }
            }
            
        } label: {
            Label(NSLocalizedString("check_in", comment: ""), systemImage: "flag.fill")
        }
        .disabled(isCheckInSucceeded || !appSettings.canCheckIn)
    }
    
    private func fetchUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else{
                os_log("Invalid URL", log: .default, type: .error)
            return
        }
        os_log("Fetching User Info at: %{public}@", log: .default, type: .info, url.absoluteString)
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                appSettings.username = decodedResponse.data.attributes.username
                
                if let canCheckIn = decodedResponse.data.attributes.canCheckin{
                    appSettings.canCheckIn = canCheckIn
                }
                
                if let canCheckinContinuous = decodedResponse.data.attributes.canCheckinContinuous{
                    appSettings.canCheckinContinuous = canCheckinContinuous
                }
                
                if let totalContinuousCheckIn = decodedResponse.data.attributes.totalContinuousCheckIn{
                    appSettings.totalContinuousCheckIn = totalContinuousCheckIn
                }
                
                if let include = decodedResponse.included {
                    if include.contains(where: { $0.id == "1" }) {
                        appSettings.isAdmin = true
                    }
                }


                os_log("Successfully decoded user data when sign in success!", log: .default, type: .info)
                os_log("username : %{public}@", log: .default, type: .info, appSettings.username)
                os_log("userId : %{public}@", log: .default, type: .info, String(describing: appSettings.userId))
                os_log("canCheckIn : %{public}@", log: .default, type: .info, String(describing: appSettings.canCheckIn))
                os_log("canCheckinContinuous : %{public}@", log: .default, type: .info, String(describing: appSettings.canCheckinContinuous))
                os_log("totalContinuousCheckIn : %{public}@", log: .default, type: .info, String(describing: appSettings.totalContinuousCheckIn))
                os_log("isAdmin : %{public}@", log: .default, type: .info, String(describing: appSettings.isAdmin))
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
            showAlert(message: "获取用户数据失败，请重试")
        }
    }
    
    
    private func checkIn(completion: @escaping (Bool) -> Void) {
        os_log("current Token: %{public}@", log: .default, type: .info, appSettings.token)
        os_log("current FlarumUrl: %{public}@", log: .default, type: .info, appSettings.FlarumUrl)
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else {
            os_log("invalid Url!", log: .default, type: .error)
            completion(false)
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "type": "users",
                "attributes": [
                    "canCheckin": false,
                    "totalContinuousCheckIn": appSettings.totalContinuousCheckIn
                ],
                "id": String(appSettings.userId)
            ]
        ]

        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            os_log("Failed to serialize post data to JSON!", log: .default, type: .error)
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appSettings.token != ""{
            request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
        }else{
            os_log("Invalid Token Or Not Logged in Yet!", log: .default, type: .error)
        }
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                os_log("Error: %{public}@", log: .default, type: .error, String(describing: error))
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                os_log("Invalid response", log: .default, type: .error)
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
}

private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
