//
//  newPostView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI
import UIKit
import MarkdownUI

struct newPostView: View {
    @State private var isPreviewing = false // 控制预览弹窗显示
    @Environment(\.dismiss) var dismiss
    @State private var succeessfullyPosted = false
    @State private var selectedRow: Int? = nil
    @AppStorage("postTitle") var postTitle: String = ""
    @AppStorage("postContent") var postContent: String = ""
    @State private var newPostTitle = ""
    @State private var newPostContent = ""
    @State private var message = NSLocalizedString("post_button_text", comment: "")
    @EnvironmentObject var appSettings: AppSettings
    @State private var tags = [Datum6]()
    @State private var selectedButtonIds: [String] = []
    @State private var isPosting = false
    
    var body: some View {
        return
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // 标题输入部分
                    VStack(alignment:.leading, spacing: 5) {
                        HStack {
                            Image(systemName: "rectangle.and.text.magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                            Text("Title")
                                .font(.headline)
                                .opacity(0.8)
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.leading)
                        TextField("Enter a title", text: $newPostTitle, axis:.vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .padding(.horizontal)
                    }
                    // 内容输入部分
                    VStack(alignment:.leading, spacing: 5) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                            Text("Content")
                                .font(.headline)
                                .opacity(0.8)
                            Spacer()
                        }
                        .padding(.leading)
                        VStack {
                            TextEditor(text: $newPostContent)
                            HStack {
                                Button("预览") { isPreviewing = true }
                                    .padding(.horizontal)
                                // 原有提交按钮保持不变
                            }
                        }
                        .frame(minHeight: 150)
                        .sheet(isPresented: $isPreviewing) {
                            NavigationView {
                                ScrollView {
                                    Markdown(newPostContent) // 使用已下载的Markdown库渲染
                                        .padding()
                                }
                                .navigationTitle("Markdown预览")
                                .navigationBarItems(trailing: Button("关闭") { isPreviewing = false })
                            }
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .disableAutocorrection(true)
                            .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                        // 标签选择部分
                        VStack(alignment:.leading, spacing: 5) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("Select Tags")
                                    .font(.headline)
                                    .opacity(0.8)
                                Spacer()
                            }
                            .padding(.leading)
                            ForEach(getParentTagsFromFetching(from: tags), id: \.id) { tag in
                                if getChildTags(parentTag: tag, dataFetched: tags).isEmpty {
                                    HStack {
                                        TagButton(id: tag.id,
                                                  tagColor: tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)),
                                                  title: tag.attributes.name,
                                                  parentId: nil,
                                                  childTagsId: getChildTagsId(parentTag: tag, dataFetched: tags),
                                                  selectedButtonIds: $selectedButtonIds
                                        )
                                        .padding(.leading)
                                        .scaleEffect(selectedButtonIds.contains(tag.id) ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedButtonIds.contains(tag.id))
                                        Spacer()
                                    }
                                } else {
                                    VStack(alignment:.leading) {
                                        TagButton(id: tag.id,
                                                  tagColor: tag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: tag.attributes.color)),
                                                  title: tag.attributes.name,
                                                  parentId: nil,
                                                  childTagsId: getChildTagsId(parentTag: tag, dataFetched: tags),
                                                  selectedButtonIds: $selectedButtonIds
                                        )
                                        .padding(.leading)
                                        .scaleEffect(selectedButtonIds.contains(tag.id) ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedButtonIds.contains(tag.id))
                                        if selectedButtonIds.contains(tag.id) {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack {
                                                    ForEach(getChildTags(parentTag: tag, dataFetched: tags), id: \.id) { childTag in
                                                        TagButton(id: childTag.id,
                                                                  tagColor: childTag.attributes.color.isEmpty ? Color.gray : Color(hex: removeFirstCharacter(from: childTag.attributes.color)),
                                                                  title: childTag.attributes.name,
                                                                  parentId: tag.id,
                                                                  childTagsId: getChildTagsId(parentTag: tag, dataFetched: tags),
                                                                  selectedButtonIds: $selectedButtonIds
                                                        )
                                                        .padding(.leading)
                                                        .scaleEffect(selectedButtonIds.contains(childTag.id) ? 1.1 : 1.0)
                                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedButtonIds.contains(childTag.id))
                                                        .opacity(selectedButtonIds.contains(tag.id) ? 1.0 : 0.0)
                                                        .animation(.easeInOut(duration: 0.3), value: selectedButtonIds.contains(tag.id))
                                                    }
                                                }
                                                .padding(.vertical, 1)
                                            }
                                            .opacity(selectedButtonIds.contains(tag.id) ? 1.0 : 0.0)
                                            .animation(.easeInOut(duration: 0.3), value: selectedButtonIds.contains(tag.id))
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        // 发布按钮
                        Button(action: saveNewPost) {
                            HStack {
                                Text(message)
                                    .bold()
                                if isPosting {
                                    ProgressView()
                                        .padding(.leading)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "565dd9"))
                        .padding(.horizontal)
                        .disabled(isPosting)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .task {
                    await fetchTagsData()
                }
                .onAppear {
                    newPostTitle = postTitle
                    newPostContent = postContent
                }
                .alert(isPresented: $succeessfullyPosted) {
                    Alert(title: Text("Post successfully published"),
                          message: nil,
                          dismissButton:.default(Text("OK"), action: {
                        dismiss()
                    }))
                }
                .navigationTitle("New Post")
            }
        }
        
func clearData() {
            newPostTitle = ""
            postTitle = ""
            newPostContent = ""
            postContent = ""
        }
        
        func saveNewPost() {
            // 在按钮点击后设置isPosting为true，禁用按钮
            isPosting = true
            
            postTitle = newPostTitle
            postContent = newPostContent
            
            if newPostTitle.count <= 3 {
                isPosting = false // 恢复按钮可用性
                message = NSLocalizedString("title_too_short_message", comment: "")
                
                DispatchQueue.main.asyncAfter(deadline:.now() + 1.0) {
                    message = NSLocalizedString("post_button_text", comment: "")
                }
                return
            }
            
            if newPostContent.count <= 3 {
                isPosting = false // 恢复按钮可用性
                message = NSLocalizedString("content_too_short_message", comment: "")
                
                DispatchQueue.main.asyncAfter(deadline:.now() + 1.0) {
                    message = NSLocalizedString("post_button_text", comment: "")
                }
                return
            }
            
            if newPostTitle.count > 50 {
                isPosting = false // 恢复按钮可用性
                message = NSLocalizedString("title_too_long_message", comment: "")
                
                DispatchQueue.main.asyncAfter(deadline:.now() + 1.0) {
                    message = NSLocalizedString("post_button_text", comment: "")
                }
                
                return
            }
            
            sendPostRequest { success in
                if success {
                    // 发送成功的处理逻辑
                    succeessfullyPosted = true
                    isPosting = false // 恢复按钮可用性
                    clearData()
                    appSettings.refreshPost()
                } else {
                    // 发送失败的处理逻辑
                    showMessageAndEnableButton(message: NSLocalizedString("post_tags_exceed_limit", comment: ""))
                }
                
                // 无论成功或失败，都在回调中恢复按钮可用性
                isPosting = false
            }
        }
        
    func sendPostRequest(completion: @escaping (Bool) -> Void) {
            print("current Token: \(appSettings.token)")
            print("current FlarumUrl: \(appSettings.FlarumUrl)")
            
            guard let url = URL(string: "\(appSettings.FlarumUrl)/api/discussions") else {
                print("invalid Url!")
                completion(false)
                return
            }
            
            var selectedTags: [[String: Any]] = []
            
            for tagId in selectedButtonIds {
                selectedTags.append(["type": "tags", "id": tagId])
            }
            
            let parameters: [String: Any] = [
                "data": [
                    "type": "discussions",
                    "attributes": [
                        "title": newPostTitle,
                        "content": newPostContent
                    ],
                    "relationships": [
                        "tags": [
                            "data": selectedTags
                        ]
                    ]
                ]
            ]
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
                print("Failed to serialize post data to JSON!")
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = httpBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if appSettings.token != "" {
                request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
            } else {
                print("Invalid Token Or Not Logged in Yet!")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid response")
                    completion(false)
                    return
                }
                
                completion(true)
            }.resume()
        }
        
func fetchTagsData() async {
            guard let url = URL(string: "\(appSettings.FlarumUrl)/api/tags") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let decodedResponse = try? JSONDecoder().decode(TagsData.self, from: data) {
                    self.tags = decodedResponse.data
                }
            } catch {
                print("Invalid Tags Data!", error)
            }
        }
        
func showMessageAndEnableButton(message: String) {
            isPosting = false // 恢复按钮可用性
            self.message = message
            
            DispatchQueue.main.asyncAfter(deadline:.now() + 1.0) {
                self.message = NSLocalizedString("post_button_text", comment: "")
            }
        }
    }
}
