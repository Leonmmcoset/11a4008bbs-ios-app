//
//  ImageTest.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/29.
//

import SwiftUI

struct AvatarAsyncImage: View {
    let url: URL?
    let frameSize: CGFloat
    let lineWidth: CGFloat
    let shadow: CGFloat
    var strokeColor: Color?
    @State private var isLoading = true
    
    // 预加载的占位符图像，确保UI立即渲染而不等待网络请求
    private let placeholderImage: Image = Image(systemName: "person.circle.fill")
        
    init(url: URL?, frameSize: CGFloat, lineWidth: CGFloat, shadow: CGFloat, strokeColor: Color? = nil) {
        self.url = url
        self.frameSize = frameSize
        self.lineWidth = lineWidth
        self.shadow = shadow
        self.strokeColor = strokeColor
    }

    
    var body: some View {
        Group {
            if let url = url {
                // 使用缓存图像，但优化渲染流程
                // 首先显示占位符，然后异步加载实际图像
                ZStack {
                    // 立即显示占位符，确保UI不等待
                    placeholderAvatar
                    
                    // 异步加载实际图像，加载完成后自动覆盖占位符
                    CachedImage(url: url.absoluteString,
                                animation: .spring(response: 0.3, dampingFraction: 0.8),
                                transition: .opacity) { phase in
                         
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: frameSize, height: frameSize)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().stroke(strokeColor ?? .white, lineWidth: lineWidth)
                                }
                                .shadow(radius: shadow)
                                .onAppear { isLoading = false }
                             
                        case .failure(_), .empty:
                            // 加载失败或空状态时，保持占位符可见
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // 加载指示器，在加载过程中显示
                    if isLoading {
                        ZStack {
                            Color.gray.opacity(0.3)
                                .frame(width: frameSize, height: frameSize)
                                .clipShape(Circle())
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(0.7)
                        }
                        .transition(.opacity)
                    }
                }
            } else {
                // 没有URL时显示占位符
                placeholderAvatar
            }
        }
        // 确保视图尺寸固定，避免布局闪烁
        .frame(width: frameSize, height: frameSize)
    }
    
    // 预加载的占位符头像
    private var placeholderAvatar: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .frame(width: frameSize, height: frameSize)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(strokeColor ?? .white, lineWidth: lineWidth)
                }
            
            placeholderImage
                .resizable()
                .frame(width: frameSize * 0.6, height: frameSize * 0.6)
                .foregroundColor(.gray)
        }
        .shadow(radius: shadow)
    }
}
