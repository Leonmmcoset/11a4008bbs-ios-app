//
//  FavoriteButton.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/5.
//

import SwiftUI
import os

enum FollowButtonMode {
    case follow
    case unfollow
}

struct FavoriteButton: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appSettings: AppSettings
    let isSubscription : Bool
    let discussionId : String
    @State private var subscription : Bool
    @State private var isUserSubscribed: Bool
    @State private var showAlert = false
    @State private var message = ""
    
    init(isSubscription: Bool, discussionId: String) {
        self.discussionId = discussionId
        self.isSubscription = isSubscription
        _subscription = State(initialValue: isSubscription)
        _isUserSubscribed = State(initialValue: isSubscription)
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                if isUserSubscribed{
                    subscription = false
                    message = NSLocalizedString("unfollow_success_message", comment: "")
                    
                    sendFollowRequest(completion: { success in
                        showAlert = true
                        isUserSubscribed = false
                        os_log("successfuly unfollow the post, ID: %{public}@", log: .default, type: .info, String(describing: discussionId))
                    }, mode: .unfollow)
                }else{
                    subscription = true
                    message = NSLocalizedString("follow_success_message", comment: "")
                    
                    sendFollowRequest(completion: { success in
                        showAlert = true
                        isUserSubscribed = true
                        os_log("successfuly follow the post, ID: %{public}@", log: .default, type: .info, String(describing: discussionId))
                    }, mode: .follow)
                }
            }) {
                Image(systemName: subscription ? "star.fill" : "star")
                    .font(.system(size: 15))
                    .foregroundColor(subscription ? .yellow : Color(UIColor.quaternaryLabel))
            }
            .buttonStyle(.plain)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(message),
                  message: nil,
                  dismissButton: .default(Text("OK"), action: {
                    dismiss()
                }))
        }
    }
    
    private func sendFollowRequest(completion: @escaping (Bool) -> Void, mode : FollowButtonMode) {
        var follow = false
        switch mode {
        case .follow:
            follow = true
        case .unfollow:
            follow = false
        }
        
        os_log("current Token: %{public}@", log: .default, type: .info, appSettings.token)
        os_log("current FlarumUrl: %{public}@", log: .default, type: .info, appSettings.FlarumUrl)
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/discussions/\(self.discussionId)") else {
            os_log("invalid Url!", log: .default, type: .error)
            completion(false)
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "type": "discussions",
                "attributes": [
                    "subscription": follow == true ? "follow" : nil
                ],
                "id": self.discussionId
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
