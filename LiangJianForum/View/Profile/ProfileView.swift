//
//  ProfileView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI
import UIKit

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

    private var isUserVIP: Bool {
        return appSettings.vipUsernames.contains(username)
    }
    
    var body: some View {
        NavigationStack{
            ZStack (alignment: .topTrailing){
                VStack{
                    HStack{
                        if avatarUrl != "" {
                            if appSettings.isVIP{
                                AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 130, lineWidth: 2.5, shadow: 6, strokeColor : Color(hex: "FFD700"))
                                    .padding(.bottom)
                            }else{
                                AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 130, lineWidth: 2, shadow: 6)
                                    .padding(.bottom)
                            }
                        } else {
                            CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 120, lineWidth: 1, shadow: 3)
                                .opacity (0.3)
                                .padding(.bottom)
                        }

                    }
                    .background(
//                        AsyncImage(url: URL(string: cover)) { image in
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 400, height: 350)
//                                .opacity(0.9)
//                                .padding(.bottom)
//                        } placeholder: {
//                        }
                        
                        CachedImage(url: appSettings.cover,
                                    animation: .spring(),
                                    transition: .slide.combined(with: .opacity)) { phase in
                            
                            switch phase {
                            case .empty:
                                EmptyView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 400, height: 350)
                                    .opacity(0.9)
                                    .padding(.bottom)
                                
                            case .failure(let error):
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    )
                    
                    List{
                        if !cover.isEmpty{
                            Section("Bio"){
                                if appSettings.isVIP{
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
                                }else{
                                    Text(bioHtml.htmlConvertedWithoutUrl)
                                        .multilineTextAlignment(.center)
                                        .tracking(0.5)
                                        .bold()
                                }
                            }
                        }
                        
                        Section{
                            LevelProgressView(isUserVip: appSettings.isVIP, currentExp: appSettings.userExp)
                        } header: {
                            Text("Flarum Level").padding(.leading)
                        }
                        .listRowInsets(EdgeInsets())
                        
                        Section{
                            HStack {
                                Text("🎊 Username: ").foregroundStyle(.secondary)
                                Text("\(appSettings.username)").bold()
                            }
                            HStack {
                                Text("🎎 DisplayName: ").foregroundStyle(.secondary)
                                
                                if appSettings.isVIP{
                                    Text("\(appSettings.displayName)")
                                        .multilineTextAlignment(.center)
                                        .bold()
                                        .overlay {
                                            LinearGradient(
                                                colors: [Color(hex: "7F7FD5"), Color(hex: "91EAE4")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .mask(
                                                Text("\(appSettings.displayName)")
                                                    .multilineTextAlignment(.center)
                                                    .bold()
                                            )
                                        }
                                }else {
                                    Text("\(appSettings.displayName)")
                                        .bold()
                                }
                            }
                            HStack {
                                Text("🎉 Join Time:").foregroundStyle(.secondary)
                                Text("\(appSettings.joinTime)").bold()
                            }
                            HStack{
                                Text("🎀 Last seen at:").foregroundStyle(.secondary)
                                if lastSeenAt.isEmpty{
                                    Text("Information has been hidden")
                                        .bold()
                                        .foregroundStyle(.secondary)
                                }else{
                                    Text("\(appSettings.lastSeenAt)").bold()
                                }
                            }
                        } header: {
                            Text("Account")
                        }
                        
                        Section("Flarum Contributions"){
                            HStack {
                                Text("🏖️ Discussion Count: ").foregroundStyle(.secondary)
                                Text("\(appSettings.discussionCount)").bold()
                            }
                            HStack{
                                Text("🧬 Comment Count: ").foregroundStyle(.secondary)
                                Text("\(appSettings.commentCount)").bold()
                            }
                            if self.money != -1 {
                                HStack {
                                    Text("💰 money: ").foregroundStyle(.secondary)
                                    if self.money.truncatingRemainder(dividingBy: 1) == 0 {
                                        Text(String(format: "%.0f", self.money)).bold()
                                    } else {
                                        Text(String(format: "%.1f", self.money)).bold()
                                    }
                                }
                            }
                        }
                        
                        Section("Authentication Information") {
                            if let include = include, !include.isEmpty {
                                let groups = include.filter { $0.type == "groups" }
                                if !groups.isEmpty {
                                    ForEach(groups, id: \.id) { item in
                                        HStack{
                                            if let singular = item.attributes.nameSingular {
                                                Text("\(singular): ").foregroundStyle(.secondary)
                                            }

                                            if let plural = item.attributes.namePlural {
                                                Text("\(plural)").bold()
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
                            if let include = include, !include.isEmpty {
                                let groups = include.filter { $0.type == "badges" }
                                if !groups.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false){
                                        HStack{
                                            ForEach(groups, id: \.id) { item in
                                                NavigationLink(value: item) {
                                                    if let badgeName = item.attributes.name {
                                                        Text("\(badgeName)")
                                                            .bold()
                                                            .foregroundColor(Color.white)
                                                            .font(.system(size: 12))
                                                            .padding()
                                                            .lineLimit(1)
                                                            .background(Color(hex: removeFirstCharacter(from: item.attributes.backgroundColor ?? "#6168d0")))
                                                            .frame(height: 36)
                                                            .cornerRadius(18)
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        .navigationDestination(for: UserInclude.self) { badge in
                                            BadgeDetail(badge: badge)
                                        }
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
                                    // 使用 NavigationLink 实现跳转
                                    NavigationLink {
                                        APPInfoView()
                                    } label: {
                                        Text("App Info")
                                            .bold()
                                    }
                                }
                                HStack {
                                    // 使用 NavigationLink 实现跳转
                                    NavigationLink {
                                        BugsView()
                                    } label: {
                                        Text("Bugs")
                                            .bold()
                                    }
                                }
                            }
                            Section{
                                HStack {
                                    Button(action: {
                                        UIApplication.shared.open(URL(string: "https://afdian.com/a/leonmmcoset")!)
                                    }) {
                                        Text(NSLocalizedString("moneyauthor", comment: ""))
                                    }
                                    .disabled(false)
                                }
                                HStack {
                                    Button(action: {
                                        openAppSettings()
                                    }) {
                                        Text("打开应用设置")
                                            .bold()
                                    }
                                    .disabled(false)
                                }
                            }
                        }
                    .textSelection(.enabled)
                }
                .sheet(isPresented: $showChangeProfilePage) {
                    ChangeProfileDetail().environmentObject(appSettings)
                        .presentationDetents([.height(200)])
                }
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("Sign out"),
                        message: Text("Quit?"),
                        primaryButton: .default(Text("Confirm"), action: {
                            logoutConfirmed()
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
                .refreshable {
                    await fetchUserProfile()
                }
                .onAppear {
                    Task{
                        await fetchUserProfile()
                    }
                }
                .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing))
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Section(NSLocalizedString("profile_operations", comment: "")){
                            Button {
                                //选择退出逻辑
                                logout()
                            } label: {
                                Label(NSLocalizedString("choose_to_quit", comment: ""), systemImage: "iphone.and.arrow.forward")
                            }
                        }
                    } label: {
                        Image(systemName: "gear.circle")
//                            .padding()
                            .background(Color(uiColor: UIColor.secondarySystemGroupedBackground), in: Circle())
                    }
                }
            }
        }
        .listStyle(.grouped)
    }

    func saveProfile() {
        showChangeProfilePage = true
        showAlert = true
        savePersonalProfile = true
        showSaveAlert = true
        
        buttonText = "Successfully Saved!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            buttonText = "Save"
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
        showAlert = true
        showLogoutAlert = true
    }
    
    private func fetchUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else{
                print("Invalid URL")
            return
        }
        print("Fetching User Info at: \(url)")
        
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
                
                
                if let includes = decodedResponse.included{
                    self.include = includes
                }
                self.username = decodedResponse.data.attributes.username
                self.displayName = decodedResponse.data.attributes.displayName
                
                if let avatar = decodedResponse.data.attributes.avatarURL{
                    self.avatarUrl = avatar
                }
                self.joinTime = calculateTimeDifference(from: decodedResponse.data.attributes.joinTime)
                
                if let hasLastSeenTime = decodedResponse.data.attributes.lastSeenAt{
                    self.lastSeenAt = calculateTimeDifference(from: hasLastSeenTime)
                }
                
                self.discussionCount = decodedResponse.data.attributes.discussionCount
                self.commentCount = decodedResponse.data.attributes.commentCount
                
                if let flarumMoney = decodedResponse.data.attributes.money{
                    self.money = flarumMoney
                }
                
                if let cover = decodedResponse.data.attributes.cover{
                    self.cover = cover
                }
                
                if let bioHtml = decodedResponse.data.attributes.bioHtml{
                    self.bioHtml = bioHtml
                }

                print("Successfully decoded user data")
                print("Username: \(self.username)")
                print("Display Name: \(self.displayName)")
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }
    // MARK: - Open APP settings
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
