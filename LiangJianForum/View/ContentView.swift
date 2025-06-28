//
//  MainPage.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI
import UIKit
import Combine
import os

/// 应用的主内容视图，使用 `TabView` 实现多标签导航。
struct ContentView: View {
    @EnvironmentObject var appsettings: AppSettings
    @State private var selection: Tab = .post
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    /// 定义标签页的枚举类型。
    enum Tab {
        case post
        case profile
        case tag
        case notice
        case settings
    }

    /// 视图的主体内容，根据用户登录状态显示不同的 `TabView`。
    var body: some View {
        if appsettings.isLoggedIn {
            TabView(selection: $selection) {
                PostView()
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(Tab.post)
                    .environmentObject(appsettings)

                TagField()
                    .tabItem { Label("Tag", systemImage: "tag") }
                    .tag(Tab.tag)
                    .environmentObject(appsettings)

                NoticeView()
                    .tabItem { Label("Message", systemImage: "bell") }
                    .tag(Tab.notice)
                    .environmentObject(appsettings)

                ProfileView()
                    .tabItem { Label("Me", systemImage: "person") }
                    .tag(Tab.profile)
                    .environmentObject(appsettings)

                SettingsView()
                    .tabItem { Label("设置", systemImage: "gear") }
                    .tag(Tab.settings)
                    .environmentObject(appsettings)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.1), value: selection)
            .onReceive(Just(selection)) { newValue in
                feedbackGenerator.impactOccurred()
            }
            .onAppear{
                Task{
                    await retrieveCurrentUserInformation()
                }
            }
            .environmentObject(appsettings)
        } else {
            LoginPageView()
                .environmentObject(appsettings)
        }
    }
    
    private func retrieveCurrentUserInformation() async {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/users/\(appsettings.userId)") else{
            os_log("Invalid URL", log: .default, type: .error)
            return
        }
        os_log("Fetching User Info : id %{public}@ at: %{public}@", log: .default, type: .info, String(describing: appsettings.userId), url.absoluteString)

        do{
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                appsettings.username = decodedResponse.data.attributes.username
                appsettings.displayName = decodedResponse.data.attributes.displayName

                if let avatarUrl = decodedResponse.data.attributes.avatarURL{
                    appsettings.avatarUrl = avatarUrl
                }
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}


