//
//  newReplyInvitation.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/28.
//

import SwiftUI
import UIKit
import MarkdownUI

struct newReply: View {
    @State private var isPreviewing = false // 控制预览弹窗显示
    @State private var isExpanding = false
    @State private var expandOrigin: CGPoint = .zero
    @State private var scale: CGFloat = 0.1
    let postID: String
    
    @Environment(\.dismiss) var dismiss
    @State private var succeessfullyReply = false
    @AppStorage("postContent") var replyContent: String = ""
    @State private var newReplyContent = ""
    @EnvironmentObject var appSettings: AppSettings
    @State private var isReplying = false
    
    var body: some View {
        return NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题部分
                    VStack(alignment:.leading, spacing: 5) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                            Text("Comment")
                                .font(.headline)
                                .opacity(0.8)
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.leading)
                    }
                    // 内容输入部分
                    VStack(alignment:.leading, spacing: 5) {
                        VStack {
                            TextEditor(text: $newReplyContent)
                            HStack {
                                Button("预览") {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        if let button = UIApplication.shared.windows.first?.rootViewController?.view.viewWithTag(1) as? UIButton {
                                            let origin = button.convert(CGPoint.zero, to: nil)
                                            expandOrigin = CGPoint(x: origin.x + button.bounds.width / 2, y: origin.y + button.bounds.height / 2)
                                        }
                                        isExpanding = true
                                    }
                                }
                                .tag(1)
                                // 原有提交按钮保持不变
                            }
                        }
                        .frame(minHeight: 150)
                        .sheet(isPresented: Binding(
                            get: { false },
                            set: { _ in }
                        )) {}
                        .sheet(isPresented: $isPreviewing) {
                            NavigationView {
                                ScrollView {
                                    Markdown(newReplyContent) // 使用已下载的Markdown库渲染
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
                        // 发布按钮
                        Button(action: {
                            saveReply {
                                success in
                                if success {
                                    // 这里可以根据成功情况进行更多处理，比如更新UI等
                                    newReplyContent = ""
                                    replyContent = ""
                                }
                            }
                        }) {
                            HStack {
                                Text(NSLocalizedString("post_button_text", comment: ""))
                                    .bold()
                                if isReplying{
                                    ProgressView().padding(.leading)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "565dd9"))
                        .padding(.horizontal)
                        .disabled(isReplying)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear{
                    newReplyContent = replyContent
                }
                .alert(isPresented: $succeessfullyReply) {
                    Alert(title: Text("Reply successfully posted"),
                          message: nil,
                          dismissButton: .default(Text("OK"), action: {
                        dismiss()
                    }))
                }
                .navigationTitle("New Reply")
            }
        }
        .overlay(
            ZStack {
                if isExpanding {
                    Color.white
                        .frame(width: UIScreen.main.bounds.width * scale, height: UIScreen.main.bounds.height * scale)
                        .position(expandOrigin)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                                scale = 10
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                scale = 0.1
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isExpanding = false
                                }
                            }
                        }
                        NavigationView {
                            ScrollView {
                                Markdown(newReplyContent) // 使用已下载的Markdown库渲染
                                    .padding()
                            }
                            .navigationTitle("Markdown预览")
                            .navigationBarItems(trailing: Button("关闭") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    scale = 0.1
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isExpanding = false
                                    }
                                }
                            })
                        }
                        .opacity(isExpanding ? 1 : 0)
                        .animation(.easeInOut.speed(1/0.3), value: isExpanding)
                }
            }
        )
        
        func saveReply(completion: @escaping (Bool) -> Void) {
            replyContent = newReplyContent
            
            // 显示进度视图
            isReplying = true
            
            sendPostRequest { success in
                // 隐藏进度视图
                isReplying = false
                
                if success {
                    // 请求成功时可以执行其他操作
                    DispatchQueue.main.async {
                        succeessfullyReply = true
                        appSettings.refreshComment()
                    }
                } else {
                    // 请求失败时可以执行其他操作或显示错误信息
                }
                
                // 调用回调闭包通知调用方请求完成，并传递成功状态
                completion(success)
            }
        }
        
func sendPostRequest(completion: @escaping (Bool) -> Void) {
            print("current Token: \(appSettings.token)")
            print("current FlarumUrl: \(appSettings.FlarumUrl)")
            
            guard let url = URL(string: "\(appSettings.FlarumUrl)/api/posts") else {
                print("invalid Url!")
                return
            }
            
            let parameters: [String: Any] = [
                "data": [
                    "type": "posts",
                    "attributes": [
                        "content": newReplyContent
                    ],
                    "relationships": [
                        "discussion": [
                            "data": [
                                "type": "discussions",
                                "id": postID
                            ]
                        ]
                    ]
                ]
            ]
            
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
                print("Failed to serialize comment to JSON!")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = httpBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if appSettings.token != ""{
                request.setValue("Token \(appSettings.token)", forHTTPHeaderField: "Authorization")
            }else{
                print("Invalid Token Or Not Logged in Yet!")
            }
            
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(false) // 请求失败时调用回调闭包并传递失败状态
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid response")
                    completion(false) // 请求失败时调用回调闭包并传递失败状态
                    return
                }
                
                completion(true) // 请求成功时调用回调闭包并传递成功状态
            }.resume()
        }
        
    }
}
