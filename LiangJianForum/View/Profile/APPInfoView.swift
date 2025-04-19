//
//  APPInfoView.swift
//  FlarumiOSApp
//
//  Created by 李正杰 on 2025/2/20.
//

import UIKit
import SwiftUI
import WebKit

struct APPInfoView: View {
    // 获取应用版本号
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    // 获取应用构建版本号
    let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"

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
                        NavigationLink {
                            OriginalGitHubView()
                        } label: {
                            HStack {
                                Text("原GitHub页面")
                                   .bold()
                                Spacer()
                            }
                        }
                       .padding(.vertical, 8)
                        NavigationLink {
                            YinSIZhengCeView()
                        } label: {
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
        }
    }
}

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
