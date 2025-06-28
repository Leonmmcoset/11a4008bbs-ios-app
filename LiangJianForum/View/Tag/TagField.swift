//
//  TagField.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/26.
//
import SwiftUI
import os

struct TagField: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var tags = [Datum6]()
    @State private var searchTerm = ""
    
    var filteredTags : [Datum6] {
        var filteredItems: [Datum6] = []
        
        guard !searchTerm.isEmpty else { return getParentTagsFromFetching(from: tags) }
        
        for item in getParentTagsFromFetching(from: tags) {
            if item.attributes.name.localizedCaseInsensitiveContains(searchTerm){
                filteredItems.append(item)
            }
        }
        return filteredItems
    }
    
    var body: some View {
        VStack {
            NavigationStack {
                if tags.isEmpty {
                    TagFieldContentLoader()
                } else {
                    List {
                        ForEach(filteredTags, id: \.id) { tag in
                            if getChildTags(parentTag: tag, dataFetched: tags).isEmpty {
                                NavigationLink(value: tag) {
                                    HStack {
                                        TagElement(tag: tag, fontSize: 20)
                                           .padding(8)
                                        Spacer()
                                    }
                                   .contentShape(Rectangle())
                                }
                            } else {
                                NavigationLink(value: getChildTags(parentTag: tag, dataFetched: tags)) {
                                    HStack {
                                        TagElement(tag: tag, fontSize: 20)
                                           .padding(8)
                                        Spacer()
                                    }
                                   .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .listStyle(.automatic)
                   .searchable(text: $searchTerm, prompt: "Search")
                   .navigationTitle("All Tags")
                   .navigationDestination(for: Datum6.self) { tag in
                        TagDetail(selectedTag: tag)
                    }
                   .navigationDestination(for: [Datum6].self) { tagsArray in
                        List {
                            ForEach(tagsArray, id: \.id) { tag in
                                NavigationLink(value: tag) {
                                    HStack {
                                        TagElement(tag: tag, fontSize: 20)
                                           .padding(8)
                                        Spacer()
                                    }
                                   .contentShape(Rectangle())
                                }
                            }
                        }
                       .listStyle(.grouped)
                       .navigationDestination(for: Datum6.self) { tag in
                            TagDetail(selectedTag: tag)
                        }
                    }
                }
            }
        }
       .onAppear {
            fetchTags { success in
                if success {
                    os_log("successfully decode tags data in TagField!", log: .default, type: .info)
                }
            }
        }
    }
    
    private func fetchTags(completion: @escaping (Bool) -> Void) {
        // clearData()
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/tags") else {
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
                if let decodedResponse = try? JSONDecoder().decode(TagsData.self, from: data) {
                    os_log("Successfully decoding use TagsData.self", log: .default, type: .info)
                    self.tags = decodedResponse.data
                } else {
                    os_log("Decoding to TagsData Failed!", log: .default, type: .error)
                }
            }
            
            // 请求成功后调用回调
            completion(true)
        }.resume()
    }
}
