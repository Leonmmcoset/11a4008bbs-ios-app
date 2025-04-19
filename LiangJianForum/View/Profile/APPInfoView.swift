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
    var body: some View {
        NavigationStack {
            VStack(alignment:.leading, spacing: 20) {
                Text("此APP原作者为Romantic D")
                    .font(.headline)
                Text("由LeonMMcoset修改")
                    .font(.subheadline)
                Divider()
                Text("使用此APP代表您同意隐私条款")
                    .font(.caption)
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
        let req = URLRequest(url: URL(string: "https://brt.arw.pub/2")!)
        uiView.load(req)
    }
}
