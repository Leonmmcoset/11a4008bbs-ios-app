//
//  LikedCommentsView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/9/9.
//

import SwiftUI
import os

struct LikedCommentsView: View {
    let userId : String

    @Environment(\.colorScheme) var colorScheme
    @State private var userCommentData = [Datum8]()
    @State private var isLoadingData = true
    @Binding var userCommentInclude: [Included8]
    @Binding var searchTerm: String
    @EnvironmentObject var appsettings: AppSettings
    @State private var currentPageOffset = 0
    @State private var isLoading = false
    @State private var hasNextPage = false
    @State private var hasPrevPage = false
    @State private var copiedText: String?
    
//    private var isUserVIP: Bool {
//        return appsettings.vipUsernames.contains(username)
//    }
    
    var filteredCommentData : [Datum8] {
        var filteredItems: [Datum8] = []
        
        guard !searchTerm.isEmpty else { return userCommentData }
        
        for item in userCommentData {
            if let contentHtml = item.attributes.contentHTML {
                if contentHtml.htmlConvertedWithoutUrl.localizedCaseInsensitiveContains(searchTerm){
                    filteredItems.append(item)
                }
            }
        }
        return filteredItems
    }
        
    var body: some View {
        VStack{
            PaginationView(hasPrevPage: hasPrevPage,
                           hasNextPage: hasNextPage,
                           currentPage: $currentPageOffset,
                           isLoading: $isLoading,
                           fetchDiscussion: nil,
                           fetchUserInfo: fetchUserLikedCommentsData(completion:),
                           mode: .offset
            )
            
            ScrollViewReader { proxy in
                if isLoadingData{
                    CommentsViewContentLoader()
                }else{
                    List{
                        ForEach(filteredCommentData, id: \.id)  {item in
                            let DiscussionId = item.relationships.discussion.data.id
                            let DiscussionTitle = findDiscussionTitle(id: item.relationships.discussion.data.id)
                            var CommentCount = 0
                            let sectionTitle = NSLocalizedString("🍾 In", comment: "") + " \"" + DiscussionTitle + "\""
                            
//                            @State var userInfo = getUserInfo(item: item)

                            
                            if item.attributes.contentType == "comment"{
                                Section(sectionTitle){
                                    if let contentHtml = item.attributes.contentHTML{
                                        NavigationLink(value: item){
                                            VStack{
                                                HStack{
                                                    Image(systemName: "heart.fill")
                                                        .font(.system(size: 8))
                                                        .foregroundColor(.red)
                                                    
//                                                    Text(userInfo.username)
//                                                    Text(userInfo.displayName)
//                                                    Text(userInfo.avatarUrl)
    //                                                if avatarUrl != ""{
    //                                                    if isUserVIP{
    //                                                        AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 50, lineWidth: 1.2, shadow: 3, strokeColor : Color(hex: "FFD700"))
    //                                                            .padding(.top, 10)
    //                                                    }else{
    //                                                        AvatarAsyncImage(url: URL(string: avatarUrl), frameSize: 50, lineWidth: 1, shadow: 3)
    //                                                            .padding(.top, 10)
    //                                                    }
    //                                                } else {
    //                                                    CircleImage(image: Image(systemName: "person.circle.fill"), widthAndHeight: 50, lineWidth: 0.7, shadow: 2)
    //                                                        .opacity(0.3)
    //                                                        .padding(.top, 10)
    //                                                }
    //
    //                                                if let displayname = self.displayname{
    //                                                    Text(displayname)
    //                                                        .font(.system(size: 12))
    //                                                        .bold()
    //                                                        .padding(.leading, 3)
    //                                                        .foregroundColor(colorScheme == .dark ? .white : .black)
    //                                                }else{
    //                                                    Text(username)
    //                                                        .font(.system(size: 12))
    //                                                        .bold()
    //                                                        .padding(.leading, 3)
    //                                                        .foregroundColor(colorScheme == .dark ? .white : .black)
    //                                                }
                                                    
                                                    Text(calculateTimeDifference(from: item.attributes.createdAt))
                                                        .font(.system(size: 8))
                                                        .foregroundColor(.gray)
                                                    
                                                    if let editedTime = item.attributes.editedAt{
                                                        Text("Edited")
                                                            .font(.system(size: 8))
                                                            .foregroundColor(.gray)
                                                            .italic()
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                }
                                                .task{
                                                    CommentCount = await fetchCommentCount(DiscussionId)
//                                                    userInfo = await fetchUserProfile(userId: getUserId(item: item))
//                                                    print(userInfo.username)
//                                                    print(userInfo.displayName)
//                                                    print(userInfo.avatarUrl)
                                                }
                                                
                                                CommentDisplayView(copiedText: $copiedText, contentHTML: item.attributes.contentHTML)

                                            }
                                            .navigationDestination(for: Datum8.self){item in
                                                PostDetailView(
                                                    postTitle: findDiscussionTitle(id: item.relationships.discussion.data.id),
                                                    postID: item.relationships.discussion.data.id,
                                                    commentCount: CommentCount
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .id("AllUserComments")
                    }
                    .listStyle(.automatic)

                    .onChange(of: currentPageOffset){ _ in
                        withAnimation {
                            proxy.scrollTo("AllUserComments", anchor: .top)
                        }
                    }
    //                .searchable(text: $searchTerm, prompt: "Search")
                }
            }
            .navigationTitle("点赞评论")
        }
        .refreshable {
            isLoading = true
            fetchUserLikedCommentsData{success in
                if success{
                    isLoading = false
                }else{
                    
                }
            }
        }
        .onAppear{
            isLoadingData = true
            fetchUserLikedCommentsData{success in
                if success{
                    isLoadingData = false
                    isLoading = false
                }else{
                    
                }
            }
        }
        
    }
        
    private func findDiscussionTitle(id: String) -> String{
        var title = ""
        for item in userCommentInclude{
            if item.type == "discussions" && item.id == id{
                if let titleIn = item.attributes.title{
                    title = titleIn
                }
            }
        }
        return title
    }
        
    private func fetchCommentCount(_ id: String) async -> Int{
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/discussions/\(id)") else{
            os_log("Invalid URL", log: .default, type: .error)
            return 0
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(DiscussionDataWithId.self, from: data){
                return decodedResponse.data.attributes.commentCount
            }
            
        } catch {
            os_log("Invalid Discussions Data In method fetchCommentCount()! %{public}@", log: .default, type: .error, String(describing: error))
        }
        
        return 0
    }
    
    private func fetchUserLikedCommentsData(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/posts?filter%5Btype%5D=comment&filter%5BlikedBy%5D=\(self.userId)&page%5Boffset%5D=\(currentPageOffset)&page%5Blimit%5D=20&sort=-createdAt") else {
            os_log("Invalid URL", log: .default, type: .error)
            completion(false)
            return
        }
        
        // 创建URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 使用GET方法
        
        // 设置请求头
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if appsettings.token != "" {
            request.setValue("Token \(appsettings.token)", forHTTPHeaderField: "Authorization")
        } else {
            os_log("Invalid Token or Not Logged in Yet!", log: .default, type: .error)
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
                os_log("fetching from %{public}@", log: .default, type: .info, url.absoluteString)
                os_log("In CommentsView", log: .default, type: .info)
                
                if let decodedResponse = try? JSONDecoder().decode(UserCommentData.self, from: data) {
                    self.userCommentData = decodedResponse.data
                    self.userCommentInclude = decodedResponse.included

                    if decodedResponse.links.next == nil || decodedResponse.links.next == "" {
                        self.hasNextPage = false
                    } else {
                        self.hasNextPage = true
                    }
                    
                    if decodedResponse.links.prev != nil && currentPageOffset != 0 {
                        self.hasPrevPage = true
                    } else {
                        self.hasPrevPage = false
                    }

                    os_log("successfully decode user's liked comment data", log: .default, type: .info)
                    os_log("current page offset: %{public}d", log: .default, type: .info, currentPageOffset)
                    os_log("has next page: %{public}@", log: .default, type: .info, String(describing: hasNextPage))
                    os_log("has prev page: %{public}@", log: .default, type: .info, String(describing: hasPrevPage))
                } else {
                    os_log("Invalid user's comment Data!", log: .default, type: .error)
                }
            }
            
            // 请求成功后调用回调
            completion(true)
            
        }.resume()
    }
    
    private func getUserId(item : Datum8) -> String{
        return item.relationships.user.data.id
    }
    
    private func getUserInfo(item : Datum8) -> UserInfo{
        var userInfo = UserInfo(username: "", displayName: "", avatarUrl: "")
        Task{
          userInfo = await fetchUserProfile(userId: getUserId(item: item))
        }
        
        return userInfo
    }
    
    private func fetchUserProfile(userId: String) async -> UserInfo {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/users/\(userId)") else {
            os_log("Invalid URL", log: .default, type: .error)
            return UserInfo(username: "", displayName: "", avatarUrl: "")
        }
        os_log("Fetching User Info at: %{public}@ at LikedCommentsView", log: .default, type: .info, url.absoluteString)

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data) {
                let username = decodedResponse.data.attributes.username
                let displayName = decodedResponse.data.attributes.displayName
                let avatarUrl = decodedResponse.data.attributes.avatarURL ?? "" // Handle optional value

                os_log("Successfully decoded user data", log: .default, type: .info)
                os_log("Username: %{public}@", log: .default, type: .info, username)
                os_log("Display Name: %{public}@", log: .default, type: .info, displayName)
                os_log("Avatar URL: %{public}@", log: .default, type: .info, avatarUrl)

                return UserInfo(username: username, displayName: displayName, avatarUrl: avatarUrl)
            }
        } catch {
            os_log("Invalid user Data! %{public}@", log: .default, type: .error, String(describing: error))
        }

        return UserInfo(username: "", displayName: "", avatarUrl: "")
    }
}

struct UserInfo {
    let username: String
    let displayName: String
    let avatarUrl: String
}

