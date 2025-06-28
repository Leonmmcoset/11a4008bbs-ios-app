//
//  MoneyConditionRecord.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/7.
//

import SwiftUI
import os

struct MoneyConditionRecord: View {
    let Usermoney : Double?
    let userId : String
    
    @State private var moneyData = [Datum10]()
    @State private var money = -1.0
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack{
            if moneyData.isEmpty || money == -1.0{
                MoneyConditionRecordContentLoader()
            }else{
                List{
                    Section("当前资产"){
                        HStack{
                            Spacer()
                            
                            if Usermoney != nil{
                                if let usermoney = Usermoney{
                                    Text(String(usermoney))
                                        .font(Font.system(size: 60, weight: .bold))
                                        .multilineTextAlignment(.center)
                                        .tracking(0.5)
                                        .overlay {
                                            LinearGradient(
                                                colors: [.red, .blue, .green, .yellow],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .mask(
                                                Text(String(usermoney))
                                                    .font(Font.system(size: 60, weight: .bold))
                                                    .multilineTextAlignment(.center)
                                                    .tracking(0.5)
                                            )
                                        }
                                }
                            }else{
                                Text(String(money))
                                    .font(Font.system(size: 60, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .tracking(0.5)
                                    .overlay {
                                        LinearGradient(
                                            colors: [.red, .blue, .green, .yellow],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Text(String(money))
                                                .font(Font.system(size: 60, weight: .bold))
                                                .multilineTextAlignment(.center)
                                                .tracking(0.5)
                                        )
                                    }
                            }  
                            Spacer()
                        }
                    }
                    
                    Section("资产记录"){
                        ForEach(moneyData, id: \.id) { item in
                            HStack{
                                VStack(alignment: .leading){
                                    Text(item.attributes.createTime)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(translateReason(item.attributes.reason))
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                        .padding(.top)
                                }
                                
                                Spacer()
                                
                                Text(formatMoney(item.attributes.money))
                                    .bold()
                                    .font(.title)
                                    .foregroundStyle(item.attributes.money >= 0 ? .green : .red)
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
        }
        .navigationTitle("我的资产")
        .onAppear{
            Task{
                await fetchUserProfile()
            }
            
            fetchMoneyData { success in
                if success{
                    os_log("Successfully load MoneyRecord View!", log: .default, type: .info)
                }
            }
        }
        
    }
    
    func formatMoney(_ money: Double) -> String {
        let absoluteMoney = abs(money)
        let formattedMoney = money > 0 ? "+\(absoluteMoney)" : "-\(absoluteMoney)"
        return formattedMoney
    }

    func getShortenedReason(_ reason: String) -> String {
        if let range = reason.range(of: "xypp-money-more.forum.awarness.") {
            let startIndex = range.upperBound
            return String(reason[startIndex...])
        }
        return reason
    }
    
    func translateReason(_ reason: String) -> String {
        switch getShortenedReason(reason) {
        case "admin-edit":
            return "管理员修改"
        case "post-liked":
            return "回复被赞"
        case "discussion-started":
            return "发帖"
        case "bepurchased":
            return "付费内容收益"
        case "purchase":
            return "购买付费内容"
        case "checkin":
            return "签到"
        case "post-posted":
            return "评论"
        default:
            return "未知原因"
        }
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
                if let flarumMoney = decodedResponse.data.attributes.money{
                    self.money = flarumMoney
                }
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }
    
    private func fetchMoneyData(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/money-more/record/\(userId)?page=0") else {
            os_log("Invalid URL", log: .default, type: .error)
            completion(false)
            return
        }
        
        // 创建URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 使用GET方法
        
        // 设置请求头
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appSettings.token != "" {
            request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
        } else {
            os_log("Invalid token or not logged in yet!", log: .default, type: .error)
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
            
            // 在请求成功时处理数据
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(MoneyData.self, from: data) {
                    os_log("Successfully decoding use MoneyData.self", log: .default, type: .info)
                    self.moneyData = decodedResponse.data
                } else {
                    os_log("Decoding to MoneyData Failed!", log: .default, type: .error)
                }
            }
            
            // 请求成功后调用回调
            completion(true)
        }.resume()
    }
}
