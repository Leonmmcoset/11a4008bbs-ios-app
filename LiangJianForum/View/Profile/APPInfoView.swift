//
//  APPInfoView.swift
//  FlarumiOSApp
//
//  Created by 李正杰 on 2025/2/20.
//

import UIKit
import SwiftUI
import WebKit
import SafariServices

struct APPInfoView: View {
    // 获取应用版本号
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    // 获取应用构建版本号
    let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    
    @State private var isOriginalGitHubPresented = false
    @State private var isPrivacyPolicyPresented = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment:.leading, spacing: 20) {
                Text("此APP原作者为Romantic D")
                   .font(.headline)
                Text("由LeonMMcoset修改")
                   .font(.subheadline)
                Divider()
                Text("使用此APP代表您同意隐私条款")
                    .font(.subheadline)
                Divider()
                // 显示版本和构建版本信息
                Text("版本: \(appVersion) (构建版本: \(appBuild))")
                    .font(.subheadline)
                List {
                    Section {
                        Button(action: {
                            isOriginalGitHubPresented = true
                        }) {
                            HStack {
                                Text("原GitHub页面")
                                   .bold()
                                Spacer()
                            }
                        }
                       .padding(.vertical, 8)
                        Button(action: {
                            isPrivacyPolicyPresented = true
                        }) {
                            HStack {
                                Text("隐私政策")
                                   .bold()
                                Spacer()
                            }
                        }
                       .padding(.vertical, 8)
                    }
                }
            }
           .padding()
           .sheet(isPresented: $isOriginalGitHubPresented) {
                SafariView(url: URL(string: "https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo")!)
            }
           .sheet(isPresented: $isPrivacyPolicyPresented) {
                SafariView(url: URL(string: "https://brt.arw.pub/p/2-privacyagreement")!)
            }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // 无需更新操作
    }
}

// 后面的代码看起来没用了
// 就先放这里吧（懒得删）
struct OriginalGitHubView : UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let req = URLRequest(url: URL(string: "https://github.com/RomanticD/Flarum-iOS-App-UnofficialDemo")!)
        uiView.load(req)
    }
}

struct YinSIZhengCeView : UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let req = URLRequest(url: URL(string: "https://brt.arw.pub/p/2-privacyagreement")!)
        uiView.load(req)
    }
}
