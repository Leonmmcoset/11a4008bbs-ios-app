//
//  ProfileView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI
import UIKit
import SafariServices // 保留Safari框架导入

struct ProfileView: View {
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var avatarUrl: String = ""
    @State private var joinTime: String = ""
    @State private var lastSeenAt: String = ""
    @State private var bioHtml: String = ""
    @State private var cover: String = ""
    @State private var discussionCount: Int = 0
    @State private var commentCount: Int = 0
    @State private var money: Double = -1
    @State private var include: [UserInclude]?
    @State private var savePersonalProfile = false
    @State private var showAlert = false
    @State private var showSaveAlert = false
    @State private var showLogoutAlert = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appSettings: AppSettings
    @State private var showLoginPage = false
    @State private var showChangeProfilePage = false
    @State private var buttonText = "保存"

    @State private var showSafariView = false // 控制Safari视图显示的状态变量
    
    private var isUserVIP: Bool {
        return appSettings.vipUsernames.contains(username)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                VStack {
                    HStack {
                        if avatarUrl != "" {
                            if appSettings.isVIP {
                                AvatarAsyncImage(
                                    url: URL(string: avatarUrl),
                                    frameSize: 130,
                                    lineWidth: 2.5,
                                    shadow: 6,
                                    strokeColor: Color(hex: "FFD700")
                                )
                                .scaleEffect(isUserVIP ? 1.1 : 1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isUserVIP)
                                .padding(.bottom)
                            } else {
                                AvatarAsyncImage(
                                    url: URL(string: avatarUrl),
                                    frameSize: 130,
                                    lineWidth: 2,
                                    shadow: 6
                                )
                                .scaleEffect(isUserVIP ? 1.1 : 1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isUserVIP)
                                .padding(.bottom)
                            }
                        } else {
                            CircleImage(
                                image: Image(systemName: "person.circle.fill"),
                                widthAndHeight: 120,
                                lineWidth: 1,
                                shadow: 3
                            )
                            .opacity(0.3)
                            .padding(.bottom)
                        }
                    }
                    .background(
                        CachedImage(
                            url: appSettings.cover,
                            animation: .spring(),
                            transition: .slide.combined(with: .opacity)
                        ) { phase in
                            switch phase {
                            case .empty, .failure:
                                EmptyView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 400, height: 350)
                                    .opacity(0.9)
                                    .padding(.bottom)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    )
                    
                    List {
                        if !cover.isEmpty {
                            Section("Bio") {
                                if appSettings.isVIP {
                                    Text(bioHtml.htmlConvertedWithoutUrl)
                                        .multilineTextAlignment(.center)
                                        .tracking(0.5)
                                        .bold()
                                        .overlay {
                                            LinearGradient(
                                                colors: [.purple, .blue, .mint, .green],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .mask(
                                                Text(bioHtml.htmlConvertedWithoutUrl)
                                                    .multilineTextAlignment(.center)
                                                    .tracking(0.5)
                                                    .bold()
                                            )
                                        }
                                } else {
                                    Text(bioHtml.htmlConvertedWithoutUrl)
                                        .multilineTextAlignment(.center)
                                        .tracking(0.5)
                                        .bold()
                                }
                            }
                        }
                        
                        Section {
                            LevelProgressView(isUserVip: appSettings.isVIP, currentExp: appSettings.userExp)
                        } header: {
                            Text("Flarum Level").padding(.leading)
                        }
                        .listRowInsets(EdgeInsets())
                        
                        Section(header: Text("Account")) {
                            HStack {
                                Text("🎊 Username: ").foregroundStyle(.secondary)
                                Text(appSettings.username).bold()
                            }
                            
                            HStack {
                                Text("🎎 DisplayName: ").foregroundStyle(.secondary)
                                
                                if appSettings.isVIP {
                                    Text(appSettings.displayName)
                                        .multilineTextAlignment(.center)
                                        .bold()
                                        .overlay {
                                            LinearGradient(
                                                colors: [Color(hex: "7F7FD5"), Color(hex: "91EAE4")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .mask(
                                                Text(appSettings.displayName)
                                                    .multilineTextAlignment(.center)
                                                    .bold()
                                            )
                                        }
                                } else {
                                    Text(appSettings.displayName).bold()
                                }
                            }
                            
                            HStack {
                                Text("🎉 Join Time:").foregroundStyle(.secondary)
                                Text(appSettings.joinTime).bold()
                            }
                            
                            HStack {
                                Text("🎀 Last seen at:").foregroundStyle(.secondary)
                                if lastSeenAt.isEmpty {
                                    Text("Information has been hidden")
                                        .bold()
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(appSettings.lastSeenAt).bold()
                                }
                            }
                        }
                        
                        Section("Flarum Contributions") {
                            HStack {
                                Text("🏖️ Discussion Count: ").foregroundStyle(.secondary)
                                Text(discussionCount.description).bold()
                            }
                            
                            HStack {
                                Text("🧬 Comment Count: ").foregroundStyle(.secondary)
                                Text(commentCount.description).bold()
                            }
                            
                            if money != -1 {
                                HStack {
                                    Text("💰 money: ").foregroundStyle(.secondary)
                                    if money.truncatingRemainder(dividingBy: 1) == 0 {
                                        Text(String(format: "%.0f", money)).bold()
                                    } else {
                                        Text(String(format: "%.1f", money)).bold()
                                    }
                                }
                            }
                        }
                        
                        Section("Authentication Information") {
                            if let include, !include.isEmpty {
                                let groups = include.filter { $0.type == "groups" }
                                if !groups.isEmpty {
                                    ForEach(groups, id: \.id) { item in
                                        HStack {
                                            if let singular = item.attributes.nameSingular {
                                                Text("\(singular): ").foregroundStyle(.secondary)
                                            }
                                            if let plural = item.attributes.namePlural {
                                                Text(plural).bold()
                                            }
                                        }
                                    }
                                } else {
                                    Text("No authentication information available")
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            } else {
                                Text("No authentication information available")
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        
                        Section("Earned Badges") {
                            if let include, !include.isEmpty {
                                let groups = include.filter { $0.type == "badges" }
                                if !groups.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(groups, id: \.id) { item in
                                                NavigationLink(value: item) {
                                                    if let badgeName = item.attributes.name,
                                                       let backgroundColor = item.attributes.backgroundColor {
                                                        Text(badgeName)
                                                            .bold()
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 12))
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 6)
                                                            .lineLimit(1)
                                                            .background(Color(hex: removeFirstCharacter(from: backgroundColor)))
                                                            .cornerRadius(18)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .navigationDestination(for: UserInclude.self) { badge in
                                        BadgeDetail(badge: badge)
                                    }
                                } else {
                                    Text("No Badges Earned Yet")
                                        .padding(.leading)
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            } else {
                                Text("No Badges Earned Yet")
                                    .padding(.leading)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        
                        Section {
                            HStack {
                                NavigationLink {
                                    APPInfoView()
                                } label: {
                                    Text("App Info").bold()
                                }
                            }
                            
                            HStack {
                                NavigationLink {
                                    BugsView()
                                } label: {
                                    Text("Bugs").bold()
                                }
                            }
                        }
                        
                        Section {
                            HStack {
                                Button(action: { showSafariView = true }) {
                                    Text(NSLocalizedString("moneyauthor", comment: ""))
                                }
                                .disabled(false)
                            }
                            
                            HStack {
                                Button(action: openAppSettings) {
                                    Text("打开应用设置").bold()
                                }
                                .disabled(false)
                            }

                            HStack {
                                Button("检查更新") {
                                    // 调用手动检查更新函数
                                    checkManualVersionUpdate()
                                }
                                .bold()
                                .disabled(false)
                            }
                        }
                    }
                    .textSelection(.enabled)
                }
                .sheet(isPresented: $showSafariView) {
                    SafariView(url: URL(string: "https://afdian.com/a/leonmmcoset")!) // 引用外部SafariView
                }
                .sheet(isPresented: $showChangeProfilePage) {
                    ChangeProfileDetail().environmentObject(appSettings)
                        .presentationDetents([.height(200)])
                }
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("Sign out"),
                        message: Text("Quit?"),
                        primaryButton: .default(Text("Confirm"), action: logoutConfirmed),
                        secondaryButton: .cancel()
                    )
                }
                .refreshable { await fetchUserProfile() }
                .onAppear { Task { await fetchUserProfile() } }
                .background(
                    colorScheme == .dark
                    ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing)
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Section(NSLocalizedString("profile_operations", comment: "")) {
                            Button { logout() } label: {
                                Label(NSLocalizedString("choose_to_quit", comment: ""), systemImage: "iphone.and.arrow.forward")
                            }
                        }
                    } label: {
                        Image(systemName: "gear.circle")
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: Circle())
                    }
                }
            }
        }
        .navigationTitle("我")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.automatic)
    }
    
    func saveProfile() {
        showChangeProfilePage = true
        showAlert = true
        savePersonalProfile = true
        showSaveAlert = true
        
        buttonText = "Successfully Saved!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            buttonText = "保存"
            savePersonalProfile = false
        }
    }
    
    func logoutConfirmed() {
        appSettings.stopTimer()
        appSettings.token = ""
        showLoginPage.toggle()
        appSettings.isLoggedIn = false
    }
    
    func logout() {
        showLogoutAlert = true
    }
    
    private func fetchUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else {
            print("Invalid URL")
            return
        }
        print("Fetching User Info at: \(url)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data) {
                appSettings.username = decodedResponse.data.attributes.username
                appSettings.canCheckIn = decodedResponse.data.attributes.canCheckin ?? false
                appSettings.canCheckinContinuous = decodedResponse.data.attributes.canCheckinContinuous ?? false
                appSettings.totalContinuousCheckIn = decodedResponse.data.attributes.totalContinuousCheckIn ?? 0
                include = decodedResponse.included
                username = decodedResponse.data.attributes.username
                displayName = decodedResponse.data.attributes.displayName
                avatarUrl = decodedResponse.data.attributes.avatarURL ?? ""
                joinTime = calculateTimeDifference(from: decodedResponse.data.attributes.joinTime)
                lastSeenAt = decodedResponse.data.attributes.lastSeenAt.map(calculateTimeDifference) ?? ""
                discussionCount = decodedResponse.data.attributes.discussionCount
                commentCount = decodedResponse.data.attributes.commentCount
                money = decodedResponse.data.attributes.money ?? -1
                cover = decodedResponse.data.attributes.cover ?? ""
                bioHtml = decodedResponse.data.attributes.bioHtml ?? ""
            }
        } catch {
            print("Fetch user profile failed: \(error)")
            // 可以添加更多错误处理逻辑，如显示提示框给用户
            // showAlert(message: "获取用户资料失败，请重试")
        }
    }
    
    private func calculateTimeDifference(from dateString: String) -> String {
        // 假设原有时间处理逻辑不变，此处需根据实际实现补充
        return dateString // 示例占位，需替换为实际时间转换逻辑
    }
    
    private func removeFirstCharacter(from string: String) -> String {
        // 假设原有字符串处理逻辑不变
        return string.isEmpty ? "#6168d0" : String(string.dropFirst())
    }
    
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - 假设以下结构体在其他文件中定义（如UserInclude、LevelProgressView、AvatarAsyncImage、CircleImage等）
// struct UserInclude: Decodable {
//     let type: String
//     let id: String
//     let attributes: UserIncludeAttributes
// }
//
// struct UserIncludeAttributes: Decodable {
//     let nameSingular: String?
//     let namePlural: String?
//     let name: String?
//     let backgroundColor: String?
//     // 其他所需属性...
// }
//
// struct UserData: Decodable {
//     let data: User
//     let included: [UserInclude]?
// }
//
// struct User: Decodable {
//     let attributes: UserAttributes
// }
//
// struct UserAttributes: Decodable {
//     let username: String
//     let displayName: String
//     let avatarURL: String?
//     let joinTime: String
//     let lastSeenAt: String?
//     let discussionCount: Int
//     let commentCount: Int
//     let money: Double?
//     let cover: String?
//     let bioHtml: String?
//     let canCheckin: Bool?
//     let canCheckinContinuous: Bool?
//     let totalContinuousCheckIn: Int?
//     // 其他所需属性...
// }
