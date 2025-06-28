//
//  LinksProfileView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/7/4.
//

import SwiftUI
import Shimmer
import os

/// 显示用户资料链接的视图。
/// 该视图展示用户的头像、简介、等级、账户信息以及论坛贡献等内容。
struct LinksProfileView: View {
    /// 用户的 ID。
    let userId: Int
    /// 用户是否为 VIP。
    let isVIP : Bool
    /// 用户的经验值。
    let Exp : Int

    /// 用户简介的 HTML 内容。
    @State private var bioHtml: String = ""
    /// 用户封面图的 URL。
    @State private var cover: String = ""
    /// 用户的用户名。
    @State private var username: String = ""
    /// 用户的显示名称。
    @State private var displayName: String = ""
    /// 用户头像的 URL。
    @State private var avatarUrl: String = ""
    /// 用户的加入时间。
    @State private var joinTime: String = ""
    /// 用户最后一次活跃时间。
    @State private var lastSeenAt: String = ""
    /// 用户发起的讨论数量。
    @State private var discussionCount: Int = 0
    /// 用户发表的评论数量。
    @State private var commentCount: Int = 0
    /// 用户的资产数量。
    @State private var money: Double = -1
    /// 用户的关联信息。
    @State private var include: [UserInclude]?
    /// 是否保存个人资料。
    @State private var savePersonalProfile = false
    /// 当前选中的行。
    @State private var selectedRow: Int? = nil
    /// 新的昵称。
    @State private var newNickName: String = ""
    /// 新的个人简介。
    @State private var newIntroduction: String = ""
    /// 存储的昵称。
    @AppStorage("nickName") var nickName: String = ""
    /// 存储的个人简介。
    @AppStorage("introduction") var introduction: String = ""
    /// 是否显示警告框。
    @State private var showAlert = false
    /// 是否显示保存警告框。
    @State private var showSaveAlert = false
    /// 是否显示退出登录警告框。
    @State private var showLogoutAlert = false
    /// 当前的颜色模式。
    @Environment(\.colorScheme) var colorScheme
    /// 应用设置。
    @EnvironmentObject var appSettings: AppSettings
    /// 是否显示登录页面。
    @State private var showLoginPage = false
    /// 按钮的文本。
    @State private var buttonText = "保存"
    /// 搜索关键词。
    @State private var searchTerm = ""
    /// 当前页码偏移量。
    @State private var currentPageOffset = 0
    /// 用户评论数据。
    @State private var userCommentData = [Datum8]()
    /// 用户评论的关联信息。
    @State private var userCommentInclude = [Included8]()
    /// 是否有下一页。
    @State private var hasNextPage = false
    /// 是否有上一页。
    @State private var hasPrevPage = false

    /// 视图的主体内容。
    var body: some View {
        VStack{
            HStack{
                if avatarUrl != "" {
                    if isVIP{
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
                AsyncImage(url: URL(string: cover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 350)
                        .opacity(0.8)
                        .padding(.bottom)
                } placeholder: {
                }
            )
            
            List{
                if !cover.isEmpty{
                    Section("Bio"){
                        if isVIP{
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
                    LevelProgressView(isUserVip: isVIP, currentExp: self.Exp)
                } header: {
                    Text("Flarum Level").padding(.leading)
                }
                .listRowInsets(EdgeInsets())
                
                Section{
                    HStack {
                        Text("🎊 Username: ").foregroundStyle(.secondary)
                        Text("\(username)").bold()
                    }
                    HStack {
                        Text("用户ID：").foregroundStyle(.secondary)
                        Text("\(userId)").bold()
                    }
                    HStack {
                        Text("🎎 DisplayName: ").foregroundStyle(.secondary)
                        if isVIP{
                            Text("\(displayName)")
                                .multilineTextAlignment(.center)
                                .bold()
                                .overlay {
                                    LinearGradient(
                                        colors: [Color(hex: "7F7FD5"), Color(hex: "91EAE4")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text("\(displayName)")
                                            .multilineTextAlignment(.center)
                                            .bold()
                                    )
                                }
                        }else{
                            Text("\(displayName)")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    HStack {
                        Text("🎉 Join Time:").foregroundStyle(.secondary)
                        Text("\(joinTime)").bold()
                    }
                    HStack{
                        Text("🎀 Last seen at:").foregroundStyle(.secondary)
                        if lastSeenAt.isEmpty{
                            Text("Information has been hidden")
                                .bold()
                                .foregroundStyle(.secondary)
                        }else{
                            Text("\(lastSeenAt)").bold()
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                Section("Flarum Contributions"){
                    HStack {
                        Text("🏖️ Discussion Count: ").foregroundStyle(.secondary)
                        Text("\(discussionCount)").bold()
                    }
                    
                    HStack{
                        NavigationLink(value: commentCount){
                            Text("🧬 Comment Count: ").foregroundStyle(.secondary)
                            Text("\(commentCount)").bold()
                        }
                    }
                    .navigationDestination(for: Int.self) { number in
                        CommentsView(username: username, displayname: displayName, userCommentData: $userCommentData, userCommentInclude: $userCommentInclude, avatarUrl: avatarUrl, searchTerm: $searchTerm)
                    }
                    
                    
                    if self.money != -1 {
                        HStack {
                            NavigationLink(value: money){
                                Text("💰 money: ").foregroundStyle(.secondary)
                                if self.money.truncatingRemainder(dividingBy: 1) == 0 {
                                    Text(String(format: "%.0f", self.money)).bold()
                                } else {
                                    Text(String(format: "%.1f", self.money)).bold()
                                }
                            }
                        }
                        .navigationDestination(for: Double.self) { number in
                            MoneyConditionRecord(Usermoney: self.money, userId: String(userId))
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
                                            Button(action: {
                                            }) {
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
                                            .navigationDestination(for: UserInclude.self) { item in
                                                Text(item.attributes.description ?? "No Description")
                                            }
                                        }
  
                                    }
                                }
                            }
                            
//                            ForEach(groups, id: \.id) { item in
//                                NavigationLink(value: item) {
//                                    HStack{
//                                        Spacer()
//                                        
//                                        if let badgeName = item.attributes.name {
//                                            Text("🎖️ \(badgeName)")
//                                                .bold()
//                                                .foregroundColor(Color.white)
//                                                .font(.system(size: 12))
//                                                .padding()
//                                                .lineLimit(1)
//                                                .background(Color(hex: removeFirstCharacter(from: item.attributes.backgroundColor ?? "#6168d0")))
//                                                .frame(height: 36)
//                                                .cornerRadius(18)
//                                        }
//                                        
//                                        Spacer()
//                                    }
//                                    .navigationDestination(for: UserInclude.self) { item in
//                                        Text(item.attributes.description ?? "No Description")
//                                    }
//                                }
//                            }
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
            }
            .textSelection(.enabled)
        }
        .listStyle(.automatic)
        
        .navigationTitle("\(self.displayName)的主页")
        .task{
            await fetchOtherUserProfile()
            await fetchOtherUserPost()
        }
//        .alert(isPresented: $showLogoutAlert) {
//            Alert(
//                title: Text("Sign out"),
//                message: Text("Quit?"),
//                primaryButton: .default(Text("Confirm"), action: {
//                    logoutConfirmed()
//                }),
//                secondaryButton: .cancel(Text("Cancel"))
//            )
//        }
        .refreshable {
            await fetchOtherUserProfile()
        }
        .onAppear {
            newIntroduction = introduction
            newNickName = nickName
            Task{
                await fetchOtherUserProfile()
                await fetchOtherUserPost()
            }
        }
        .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing))
    }

//    func saveProfile() {
//            showAlert = true
//            savePersonalProfile = true
//            showSaveAlert = true
//            nickName = newNickName
//            introduction = newIntroduction
//            
//            buttonText = "保存成功!"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                buttonText = "保存"
//                savePersonalProfile = false
//            }
//        }

//    func logoutConfirmed() {
//        appSettings.token = ""
//        showLoginPage.toggle()
//        appSettings.isLoggedIn = false
//    }
//    
//    
//    func logout() {
//        showAlert = true
//        showLogoutAlert = true
//    }
    
    private func fetchOtherUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(self.userId)") else{
                os_log("Invalid URL", log: .default, type: .error)
            return
        }
        os_log("Fetching User Info : at: %{public}@", log: .default, type: .info, url.absoluteString)
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
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
//                self.lastSeenAt =  calculateTimeDifference(from: decodedResponse.data.attributes.lastSeenAt)
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

                os_log("Successfully decoded user data", log: .default, type: .info)
                os_log("Username: %{public}@", log: .default, type: .info, self.username)
                os_log("Display Name: %{public}@", log: .default, type: .info, self.displayName)
                os_log("Avatar URL: %{public}@", log: .default, type: .info, self.avatarUrl)
                os_log("Join Time: %{public}@", log: .default, type: .info, self.joinTime)
                os_log("Last Seen At: %{public}@", log: .default, type: .info, self.lastSeenAt)
                os_log("Discussion Count: %{public}d", log: .default, type: .info, self.discussionCount)
                os_log("Comment Count: %{public}d", log: .default, type: .info, self.commentCount)
                os_log("money: %{public}@", log: .default, type: .info, String(describing: self.money))
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    private func isLoginUseProfile() -> Bool{
        return self.userId == appSettings.userId
    }
    
    private func fetchOtherUserPost() async {

        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else{
            os_log("Invalid URL", log: .default, type: .error)
            return
        }

        do{
           os_log("fetching from %{public}@", log: .default, type: .info, url.absoluteString)
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data){
                self.userCommentData = decodedResponse.data
                self.userCommentInclude = decodedResponse.included

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }

                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }

                os_log("successfully decode %{public}@'s comment data", log: .default, type: .info, username)
                os_log("current page offset: %{public}d", log: .default, type: .info, currentPageOffset)
                os_log("has next page: %{public}@", log: .default, type: .info, String(describing: hasNextPage))
                os_log("has prev page: %{public}@", log: .default, type: .info, String(describing: hasPrevPage))
            }else{
                os_log("fetching user %{public}@ 's comments data failed", log: .default, type: .error, username)
            }

        } catch {
            os_log("Invalid user's comment Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}


/// 显示帖子详情的视图。
/// 该视图展示帖子的标题、标签、投票信息以及评论列表等内容。
struct PostDetailView: View {
    /// 帖子的标题。
    let postTitle: String
    /// 帖子的 ID。
    let postID: String
    /// 帖子的评论数量。
    let commentCount: Int

    /// 排序选项列表。
    var sortOption = [NSLocalizedString("default_sort_option", comment: ""), NSLocalizedString("latest_sort_option", comment: "")]

    /// 当前选中的排序选项。
    @State private var selectedSortOption = NSLocalizedString("default_sort_option", comment: "")
    /// 当前页码。
    @State private var currentPage = 1
    /// 是否正在加载数据。
    @State private var isLoading = false
    /// 子视图是否正在加载数据。
    @State private var isSubViewLoading = false
    /// 当前的颜色模式。
    @Environment(\.colorScheme) var colorScheme
    /// 应用设置。
    @EnvironmentObject var appsettings: AppSettings
    /// 是否显示发帖区域。
    @State private var showingPostingArea = false
    /// 是否点赞该帖子。
    @State private var isLiked = false
    /// 是否回复该帖子。
    @State private var isReplied = false
    /// 帖子的关联信息。
    @State private var include = [Included5]()
    /// 帖子数组。
    @State var postsArray: [Included5] = []
    /// 用户数组。
    @State var usersArray: [Included5] = []
    /// 投票数组。
    @State var polls: [Included5] = []
    /// 投票选项数组。
    @State var pollOptions: [Included5] = []
    /// 搜索关键词。
    @State private var searchTerm = ""
    /// 获取到的标签数据。
    @State private var fetchedTags = [Datum6]()
    /// 显示的标签数据。
    @State private var showedTags = [Datum6]()
    /// 帖子详情中的标签 ID 数组。
    @State var tagsIdInPostDetail: [String] = []
    /// 复制的文本。
    @State private var copiedText: String?
    /// 帖子数据。
    @State private var postsData : DataClass5?

    /// 过滤后的帖子数组。
    var filteredPosts: [Included5] {
        VStack{
            HStack{
                if avatarUrl != "" {
                    if isVIP{
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
                AsyncImage(url: URL(string: cover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 350)
                        .opacity(0.8)
                        .padding(.bottom)
                } placeholder: {
                }
            )
            
            List{
                if !cover.isEmpty{
                    Section("Bio"){
                        if isVIP{
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
                    LevelProgressView(isUserVip: isVIP, currentExp: self.Exp)
                } header: {
                    Text("Flarum Level").padding(.leading)
                }
                .listRowInsets(EdgeInsets())
                
                Section{
                    HStack {
                        Text("🎊 Username: ").foregroundStyle(.secondary)
                        Text("\(username)").bold()
                    }
                    HStack {
                        Text("用户ID：").foregroundStyle(.secondary)
                        Text("\(userId)").bold()
                    }
                    HStack {
                        Text("🎎 DisplayName: ").foregroundStyle(.secondary)
                        if isVIP{
                            Text("\(displayName)")
                                .multilineTextAlignment(.center)
                                .bold()
                                .overlay {
                                    LinearGradient(
                                        colors: [Color(hex: "7F7FD5"), Color(hex: "91EAE4")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text("\(displayName)")
                                            .multilineTextAlignment(.center)
                                            .bold()
                                    )
                                }
                        }else{
                            Text("\(displayName)")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    HStack {
                        Text("🎉 Join Time:").foregroundStyle(.secondary)
                        Text("\(joinTime)").bold()
                    }
                    HStack{
                        Text("🎀 Last seen at:").foregroundStyle(.secondary)
                        if lastSeenAt.isEmpty{
                            Text("Information has been hidden")
                                .bold()
                                .foregroundStyle(.secondary)
                        }else{
                            Text("\(lastSeenAt)").bold()
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                Section("Flarum Contributions"){
                    HStack {
                        Text("🏖️ Discussion Count: ").foregroundStyle(.secondary)
                        Text("\(discussionCount)").bold()
                    }
                    
                    HStack{
                        NavigationLink(value: commentCount){
                            Text("🧬 Comment Count: ").foregroundStyle(.secondary)
                            Text("\(commentCount)").bold()
                        }
                    }
                    .navigationDestination(for: Int.self) { number in
                        CommentsView(username: username, displayname: displayName, userCommentData: $userCommentData, userCommentInclude: $userCommentInclude, avatarUrl: avatarUrl, searchTerm: $searchTerm)
                    }
                    
                    
                    if self.money != -1 {
                        HStack {
                            NavigationLink(value: money){
                                Text("💰 money: ").foregroundStyle(.secondary)
                                if self.money.truncatingRemainder(dividingBy: 1) == 0 {
                                    Text(String(format: "%.0f", self.money)).bold()
                                } else {
                                    Text(String(format: "%.1f", self.money)).bold()
                                }
                            }
                        }
                        .navigationDestination(for: Double.self) { number in
                            MoneyConditionRecord(Usermoney: self.money, userId: String(userId))
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
                                            Button(action: {
                                            }) {
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
                                            .navigationDestination(for: UserInclude.self) { item in
                                                Text(item.attributes.description ?? "No Description")
                                            }
                                        }
  
                                    }
                                }
                            }
                            
//                            ForEach(groups, id: \.id) { item in
//                                NavigationLink(value: item) {
//                                    HStack{
//                                        Spacer()
//                                        
//                                        if let badgeName = item.attributes.name {
//                                            Text("🎖️ \(badgeName)")
//                                                .bold()
//                                                .foregroundColor(Color.white)
//                                                .font(.system(size: 12))
//                                                .padding()
//                                                .lineLimit(1)
//                                                .background(Color(hex: removeFirstCharacter(from: item.attributes.backgroundColor ?? "#6168d0")))
//                                                .frame(height: 36)
//                                                .cornerRadius(18)
//                                        }
//                                        
//                                        Spacer()
//                                    }
//                                    .navigationDestination(for: UserInclude.self) { item in
//                                        Text(item.attributes.description ?? "No Description")
//                                    }
//                                }
//                            }
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
            }
            .textSelection(.enabled)
        }
        .listStyle(.automatic)
        
        .navigationTitle("\(self.displayName)的主页")
        .task{
            await fetchOtherUserProfile()
            await fetchOtherUserPost()
        }
//        .alert(isPresented: $showLogoutAlert) {
//            Alert(
//                title: Text("Sign out"),
//                message: Text("Quit?"),
//                primaryButton: .default(Text("Confirm"), action: {
//                    logoutConfirmed()
//                }),
//                secondaryButton: .cancel(Text("Cancel"))
//            )
//        }
        .refreshable {
            await fetchOtherUserProfile()
        }
        .onAppear {
            newIntroduction = introduction
            newNickName = nickName
            Task{
                await fetchOtherUserProfile()
                await fetchOtherUserPost()
            }
        }
        .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing))
    }

//    func saveProfile() {
//            showAlert = true
//            savePersonalProfile = true
//            showSaveAlert = true
//            nickName = newNickName
//            introduction = newIntroduction
//            
//            buttonText = "保存成功!"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                buttonText = "保存"
//                savePersonalProfile = false
//            }
//        }

//    func logoutConfirmed() {
//        appSettings.token = ""
//        showLoginPage.toggle()
//        appSettings.isLoggedIn = false
//    }
//    
//    
//    func logout() {
//        showAlert = true
//        showLogoutAlert = true
//    }
    
    private func fetchOtherUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(self.userId)") else{
                os_log("Invalid URL", log: .default, type: .error)
            return
        }
        os_log("Fetching User Info : at: %{public}@", log: .default, type: .info, url.absoluteString)
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
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
//                self.lastSeenAt =  calculateTimeDifference(from: decodedResponse.data.attributes.lastSeenAt)
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

                os_log("Successfully decoded user data", log: .default, type: .info)
                os_log("Username: %{public}@", log: .default, type: .info, self.username)
                os_log("Display Name: %{public}@", log: .default, type: .info, self.displayName)
                os_log("Avatar URL: %{public}@", log: .default, type: .info, self.avatarUrl)
                os_log("Join Time: %{public}@", log: .default, type: .info, self.joinTime)
                os_log("Last Seen At: %{public}@", log: .default, type: .info, self.lastSeenAt)
                os_log("Discussion Count: %{public}d", log: .default, type: .info, self.discussionCount)
                os_log("Comment Count: %{public}d", log: .default, type: .info, self.commentCount)
                os_log("money: %{public}@", log: .default, type: .info, String(describing: self.money))
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    private func isLoginUseProfile() -> Bool{
        return self.userId == appSettings.userId
    }
    
    private func fetchOtherUserPost() async {

        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else{
            os_log("Invalid URL", log: .default, type: .error)
            return
        }

        do{
           os_log("fetching from %{public}@", log: .default, type: .info, url.absoluteString)
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data){
                self.userCommentData = decodedResponse.data
                self.userCommentInclude = decodedResponse.included

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }

                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }

                os_log("successfully decode %{public}@'s comment data", log: .default, type: .info, username)
                os_log("current page offset: %{public}d", log: .default, type: .info, currentPageOffset)
                os_log("has next page: %{public}@", log: .default, type: .info, String(describing: hasNextPage))
                os_log("has prev page: %{public}@", log: .default, type: .info, String(describing: hasPrevPage))
            }else{
                os_log("fetching user %{public}@ 's comments data failed", log: .default, type: .error, username)
            }

        } catch {
            os_log("Invalid user's comment Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}


/// 显示投票图表的视图。
/// 该视图展示投票的问题、选项和投票结果，并支持投票操作。
struct PollChartView: View {
    /// 应用设置。
    @EnvironmentObject var appSettings: AppSettings

    /// 投票选项及其对应的投票数。
    var pollOptionsAndVoteCount: [String: Int]
    /// 投票选项及其对应的 ID。
    var AnswerWithId: [String: String]
    /// 投票问题。
    var voteQuestion: String?
    /// 投票截止时间。
    var endDate: String?
    /// 投票创建时间。
    var createdAT: String?
    /// 是否可以投票。
    var canVote: Bool?
    /// 投票的 ID。
    var pollId: String
    /// 是否允许多选。
    var allowMultipleVotes: Bool?
    /// 最多可选的选项数量。
    var maxVotes: Int?
    /// 是否允许修改投票。
    var allowChangeVote: Bool?

    /// 当前选中的选项 ID 数组。
    @State private var selectedOptionIds: [String] = []
    /// 当前选中的选项数组。
    @State private var selectedOptions: [String] = []
    /// 是否正在加载数据。
    @State private var isLoading = false
    /// 是否投票完成。
    @State private var isVotingComplete = false
    /// 是否显示投票图表。
    @State private var isPollChartVisible = true
    /// 是否显示保存图片的界面。
    @State private var isSaveImagePresented = false

    /// 视图的主体内容。
    var body: some View {
        VStack{
            HStack{
                if avatarUrl != "" {
                    if isVIP{
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
                AsyncImage(url: URL(string: cover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 350)
                        .opacity(0.8)
                        .padding(.bottom)
                } placeholder: {
                }
            )
            
            List{
                if !cover.isEmpty{
                    Section("Bio"){
                        if isVIP{
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
                    LevelProgressView(isUserVip: isVIP, currentExp: self.Exp)
                } header: {
                    Text("Flarum Level").padding(.leading)
                }
                .listRowInsets(EdgeInsets())
                
                Section{
                    HStack {
                        Text("🎊 Username: ").foregroundStyle(.secondary)
                        Text("\(username)").bold()
                    }
                    HStack {
                        Text("用户ID：").foregroundStyle(.secondary)
                        Text("\(userId)").bold()
                    }
                    HStack {
                        Text("🎎 DisplayName: ").foregroundStyle(.secondary)
                        if isVIP{
                            Text("\(displayName)")
                                .multilineTextAlignment(.center)
                                .bold()
                                .overlay {
                                    LinearGradient(
                                        colors: [Color(hex: "7F7FD5"), Color(hex: "91EAE4")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text("\(displayName)")
                                            .multilineTextAlignment(.center)
                                            .bold()
                                    )
                                }
                        }else{
                            Text("\(displayName)")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    HStack {
                        Text("🎉 Join Time:").foregroundStyle(.secondary)
                        Text("\(joinTime)").bold()
                    }
                    HStack{
                        Text("🎀 Last seen at:").foregroundStyle(.secondary)
                        if lastSeenAt.isEmpty{
                            Text("Information has been hidden")
                                .bold()
                                .foregroundStyle(.secondary)
                        }else{
                            Text("\(lastSeenAt)").bold()
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                Section("Flarum Contributions"){
                    HStack {
                        Text("🏖️ Discussion Count: ").foregroundStyle(.secondary)
                        Text("\(discussionCount)").bold()
                    }
                    
                    HStack{
                        NavigationLink(value: commentCount){
                            Text("🧬 Comment Count: ").foregroundStyle(.secondary)
                            Text("\(commentCount)").bold()
                        }
                    }
                    .navigationDestination(for: Int.self) { number in
                        CommentsView(username: username, displayname: displayName, userCommentData: $userCommentData, userCommentInclude: $userCommentInclude, avatarUrl: avatarUrl, searchTerm: $searchTerm)
                    }
                    
                    
                    if self.money != -1 {
                        HStack {
                            NavigationLink(value: money){
                                Text("💰 money: ").foregroundStyle(.secondary)
                                if self.money.truncatingRemainder(dividingBy: 1) == 0 {
                                    Text(String(format: "%.0f", self.money)).bold()
                                } else {
                                    Text(String(format: "%.1f", self.money)).bold()
                                }
                            }
                        }
                        .navigationDestination(for: Double.self) { number in
                            MoneyConditionRecord(Usermoney: self.money, userId: String(userId))
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
                                            Button(action: {
                                            }) {
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
                                            .navigationDestination(for: UserInclude.self) { item in
                                                Text(item.attributes.description ?? "No Description")
                                            }
                                        }
  
                                    }
                                }
                            }
                            
//                            ForEach(groups, id: \.id) { item in
//                                NavigationLink(value: item) {
//                                    HStack{
//                                        Spacer()
//                                        
//                                        if let badgeName = item.attributes.name {
//                                            Text("🎖️ \(badgeName)")
//                                                .bold()
//                                                .foregroundColor(Color.white)
//                                                .font(.system(size: 12))
//                                                .padding()
//                                                .lineLimit(1)
//                                                .background(Color(hex: removeFirstCharacter(from: item.attributes.backgroundColor ?? "#6168d0")))
//                                                .frame(height: 36)
//                                                .cornerRadius(18)
//                                        }
//                                        
//                                        Spacer()
//                                    }
//                                    .navigationDestination(for: UserInclude.self) { item in
//                                        Text(item.attributes.description ?? "No Description")
//                                    }
//                                }
//                            }
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
            }
            .textSelection(.enabled)
        }
        .listStyle(.automatic)
        
        .navigationTitle("\(self.displayName)的主页")
        .task{
            await fetchOtherUserProfile()
            await fetchOtherUserPost()
        }
//        .alert(isPresented: $showLogoutAlert) {
//            Alert(
//                title: Text("Sign out"),
//                message: Text("Quit?"),
//                primaryButton: .default(Text("Confirm"), action: {
//                    logoutConfirmed()
//                }),
//                secondaryButton: .cancel(Text("Cancel"))
//            )
//        }
        .refreshable {
            await fetchOtherUserProfile()
        }
        .onAppear {
            newIntroduction = introduction
            newNickName = nickName
            Task{
                await fetchOtherUserProfile()
                await fetchOtherUserPost()
            }
        }
        .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing))
    }

//    func saveProfile() {
//            showAlert = true
//            savePersonalProfile = true
//            showSaveAlert = true
//            nickName = newNickName
//            introduction = newIntroduction
//            
//            buttonText = "保存成功!"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                buttonText = "保存"
//                savePersonalProfile = false
//            }
//        }

//    func logoutConfirmed() {
//        appSettings.token = ""
//        showLoginPage.toggle()
//        appSettings.isLoggedIn = false
//    }
//    
//    
//    func logout() {
//        showAlert = true
//        showLogoutAlert = true
//    }
    
    private func fetchOtherUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(self.userId)") else{
                os_log("Invalid URL", log: .default, type: .error)
            return
        }
        os_log("Fetching User Info : at: %{public}@", log: .default, type: .info, url.absoluteString)
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
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
//                self.lastSeenAt =  calculateTimeDifference(from: decodedResponse.data.attributes.lastSeenAt)
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

                os_log("Successfully decoded user data", log: .default, type: .info)
                os_log("Username: %{public}@", log: .default, type: .info, self.username)
                os_log("Display Name: %{public}@", log: .default, type: .info, self.displayName)
                os_log("Avatar URL: %{public}@", log: .default, type: .info, self.avatarUrl)
                os_log("Join Time: %{public}@", log: .default, type: .info, self.joinTime)
                os_log("Last Seen At: %{public}@", log: .default, type: .info, self.lastSeenAt)
                os_log("Discussion Count: %{public}d", log: .default, type: .info, self.discussionCount)
                os_log("Comment Count: %{public}d", log: .default, type: .info, self.commentCount)
                os_log("money: %{public}@", log: .default, type: .info, String(describing: self.money))
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    private func isLoginUseProfile() -> Bool{
        return self.userId == appSettings.userId
    }
    
    private func fetchOtherUserPost() async {

        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else{
            os_log("Invalid URL", log: .default, type: .error)
            return
        }

        do{
           os_log("fetching from %{public}@", log: .default, type: .info, url.absoluteString)
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data){
                self.userCommentData = decodedResponse.data
                self.userCommentInclude = decodedResponse.included

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }

                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }

                os_log("successfully decode %{public}@'s comment data", log: .default, type: .info, username)
                os_log("current page offset: %{public}d", log: .default, type: .info, currentPageOffset)
                os_log("has next page: %{public}@", log: .default, type: .info, String(describing: hasNextPage))
                os_log("has prev page: %{public}@", log: .default, type: .info, String(describing: hasPrevPage))
            }else{
                os_log("fetching user %{public}@ 's comments data failed", log: .default, type: .error, username)
            }

        } catch {
            os_log("Invalid user's comment Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}


/// 显示资产记录加载状态的视图。
/// 该视图在资产记录数据加载时显示加载状态。
struct MoneyConditionRecordContentLoader: View {
    /// 视图的主体内容。
    var body: some View {
        VStack{
            HStack{
                if avatarUrl != "" {
                    if isVIP{
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
                AsyncImage(url: URL(string: cover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 350)
                        .opacity(0.8)
                        .padding(.bottom)
                } placeholder: {
                }
            )
            
            List{
                if !cover.isEmpty{
                    Section("Bio"){
                        if isVIP{
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
                    LevelProgressView(isUserVip: isVIP, currentExp: self.Exp)
                } header: {
                    Text("Flarum Level").padding(.leading)
                }
                .listRowInsets(EdgeInsets())
                
                Section{
                    HStack {
                        Text("🎊 Username: ").foregroundStyle(.secondary)
                        Text("\(username)").bold()
                    }
                    HStack {
                        Text("用户ID：").foregroundStyle(.secondary)
                        Text("\(userId)").bold()
                    }
                    HStack {
                        Text("🎎 DisplayName: ").foregroundStyle(.secondary)
                        if isVIP{
                            Text("\(displayName)")
                                .multilineTextAlignment(.center)
                                .bold()
                                .overlay {
                                    LinearGradient(
                                        colors: [Color(hex: "7F7FD5"), Color(hex: "91EAE4")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text("\(displayName)")
                                            .multilineTextAlignment(.center)
                                            .bold()
                                    )
                                }
                        }else{
                            Text("\(displayName)")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    HStack {
                        Text("🎉 Join Time:").foregroundStyle(.secondary)
                        Text("\(joinTime)").bold()
                    }
                    HStack{
                        Text("🎀 Last seen at:").foregroundStyle(.secondary)
                        if lastSeenAt.isEmpty{
                            Text("Information has been hidden")
                                .bold()
                                .foregroundStyle(.secondary)
                        }else{
                            Text("\(lastSeenAt)").bold()
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                Section("Flarum Contributions"){
                    HStack {
                        Text("🏖️ Discussion Count: ").foregroundStyle(.secondary)
                        Text("\(discussionCount)").bold()
                    }
                    
                    HStack{
                        NavigationLink(value: commentCount){
                            Text("🧬 Comment Count: ").foregroundStyle(.secondary)
                            Text("\(commentCount)").bold()
                        }
                    }
                    .navigationDestination(for: Int.self) { number in
                        CommentsView(username: username, displayname: displayName, userCommentData: $userCommentData, userCommentInclude: $userCommentInclude, avatarUrl: avatarUrl, searchTerm: $searchTerm)
                    }
                    
                    
                    if self.money != -1 {
                        HStack {
                            NavigationLink(value: money){
                                Text("💰 money: ").foregroundStyle(.secondary)
                                if self.money.truncatingRemainder(dividingBy: 1) == 0 {
                                    Text(String(format: "%.0f", self.money)).bold()
                                } else {
                                    Text(String(format: "%.1f", self.money)).bold()
                                }
                            }
                        }
                        .navigationDestination(for: Double.self) { number in
                            MoneyConditionRecord(Usermoney: self.money, userId: String(userId))
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
                                            Button(action: {
                                            }) {
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
                                            .navigationDestination(for: UserInclude.self) { item in
                                                Text(item.attributes.description ?? "No Description")
                                            }
                                        }
  
                                    }
                                }
                            }
                            
//                            ForEach(groups, id: \.id) { item in
//                                NavigationLink(value: item) {
//                                    HStack{
//                                        Spacer()
//                                        
//                                        if let badgeName = item.attributes.name {
//                                            Text("🎖️ \(badgeName)")
//                                                .bold()
//                                                .foregroundColor(Color.white)
//                                                .font(.system(size: 12))
//                                                .padding()
//                                                .lineLimit(1)
//                                                .background(Color(hex: removeFirstCharacter(from: item.attributes.backgroundColor ?? "#6168d0")))
//                                                .frame(height: 36)
//                                                .cornerRadius(18)
//                                        }
//                                        
//                                        Spacer()
//                                    }
//                                    .navigationDestination(for: UserInclude.self) { item in
//                                        Text(item.attributes.description ?? "No Description")
//                                    }
//                                }
//                            }
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
            }
            .textSelection(.enabled)
        }
        .listStyle(.automatic)
        
        .navigationTitle("\(self.displayName)的主页")
        .task{
            await fetchOtherUserProfile()
            await fetchOtherUserPost()
        }
//        .alert(isPresented: $showLogoutAlert) {
//            Alert(
//                title: Text("Sign out"),
//                message: Text("Quit?"),
//                primaryButton: .default(Text("Confirm"), action: {
//                    logoutConfirmed()
//                }),
//                secondaryButton: .cancel(Text("Cancel"))
//            )
//        }
        .refreshable {
            await fetchOtherUserProfile()
        }
        .onAppear {
            newIntroduction = introduction
            newNickName = nickName
            Task{
                await fetchOtherUserProfile()
                await fetchOtherUserPost()
            }
        }
        .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color(hex: "780206"), Color(hex: "061161")]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color(hex: "A1FFCE"), Color(hex: "FAFFD1")]), startPoint: .leading, endPoint: .trailing))
    }

//    func saveProfile() {
//            showAlert = true
//            savePersonalProfile = true
//            showSaveAlert = true
//            nickName = newNickName
//            introduction = newIntroduction
//            
//            buttonText = "保存成功!"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                buttonText = "保存"
//                savePersonalProfile = false
//            }
//        }

//    func logoutConfirmed() {
//        appSettings.token = ""
//        showLoginPage.toggle()
//        appSettings.isLoggedIn = false
//    }
//    
//    
//    func logout() {
//        showAlert = true
//        showLogoutAlert = true
//    }
    
    private func fetchOtherUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(self.userId)") else{
                os_log("Invalid URL", log: .default, type: .error)
            return
        }
        os_log("Fetching User Info : at: %{public}@", log: .default, type: .info, url.absoluteString)
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
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
//                self.lastSeenAt =  calculateTimeDifference(from: decodedResponse.data.attributes.lastSeenAt)
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

                os_log("Successfully decoded user data", log: .default, type: .info)
                os_log("Username: %{public}@", log: .default, type: .info, self.username)
                os_log("Display Name: %{public}@", log: .default, type: .info, self.displayName)
                os_log("Avatar URL: %{public}@", log: .default, type: .info, self.avatarUrl)
                os_log("Join Time: %{public}@", log: .default, type: .info, self.joinTime)
                os_log("Last Seen At: %{public}@", log: .default, type: .info, self.lastSeenAt)
                os_log("Discussion Count: %{public}d", log: .default, type: .info, self.discussionCount)
                os_log("Comment Count: %{public}d", log: .default, type: .info, self.commentCount)
                os_log("money: %{public}@", log: .default, type: .info, String(describing: self.money))
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    private func isLoginUseProfile() -> Bool{
        return self.userId == appSettings.userId
    }
    
    private func fetchOtherUserPost() async {

        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts?filter%5Bauthor%5D=\(username)&sort=-createdAt&page%5Boffset%5D=\(currentPageOffset)") else{
            os_log("Invalid URL", log: .default, type: .error)
            return
        }

        do{
           os_log("fetching from %{public}@", log: .default, type: .info, url.absoluteString)
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data){
                self.userCommentData = decodedResponse.data
                self.userCommentInclude = decodedResponse.included

                if decodedResponse.links.next != nil{
                    self.hasNextPage = true
                }

                if decodedResponse.links.prev != nil && currentPageOffset != 1{
                    self.hasPrevPage = true
                }else{
                    self.hasPrevPage = false
                }

                os_log("successfully decode %{public}@'s comment data", log: .default, type: .info, username)
                os_log("current page offset: %{public}d", log: .default, type: .info, currentPageOffset)
                os_log("has next page: %{public}@", log: .default, type: .info, String(describing: hasNextPage))

