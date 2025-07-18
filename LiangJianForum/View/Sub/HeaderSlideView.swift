//
//  HeaderSlideView.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/25.
//

import SwiftUI
import UIKit
import os

/// 用于展示头部轮播图的视图。
/// 该视图会从网络获取轮播图数据并展示，如果数据为空则显示骨架屏。
struct HeaderSlideView: View {
    @EnvironmentObject var appsettings: AppSettings
    @State private var slidedata = [SlideData]()
    @State private var transitionTime = "2"

    /// 视图的主体内容。
    /// 根据 `slidedata` 是否为空，显示轮播图或骨架屏。
    var body: some View {
        VStack {
            if !slidedata.isEmpty {
                SliderView(slides: filterSlidesWithNonEmptyImages(slides: slidedata), transitionTime: $transitionTime)
            } else {
                ShimmerEffectBox().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await fetchHeaderSlide()
        }
    }

    /// 异步获取头部轮播图数据。
    /// 从指定 URL 获取数据并解析，若成功则更新轮播图数据和切换时间。
    private func fetchHeaderSlide() async {
        guard let url = URL(string: "\(appsettings.FlarumUrl)/api/header-slideshow/list") else {
            os_log("Invalid URL", log: .default, type: .error)
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                os_log("HeaderSlide Exists", log: .default, type: .info)

                if let decodedResponse = try? JSONDecoder().decode(HeaderSlideData.self, from: data) {
                    self.transitionTime = decodedResponse.transitionTime
                    self.slidedata = decodedResponse.list
                }
            }
        } catch {
            os_log("Error fetching Header Slide Data! %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    
    func filterSlidesWithNonEmptyImages(slides: [SlideData]) -> [SlideData] {
        var filteredSlides: [SlideData] = []

        for slide in slides {
            if slide.image != ""{
                filteredSlides.append(slide)
            }
        }

        return filteredSlides
    }

}

struct SliderView: View {
    let slides: [SlideData]
    @Binding var transitionTime: String
    @State private var selection = 0
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGray5)

            TabView(selection: $selection) {
                ForEach(0..<slides.count) { i in
//                    AsyncImage(url: URL(string: slides[i].image)) { image in
//                        image
//                            .resizable()
//                            .scaledToFill()
//                    } placeholder: {
//                        ShimmerEffectBox()
//                    }
                    
                    CachedImage(url: slides[i].image,
                                animation: .spring(),
                                transition: .scale.combined(with: .opacity)) { phase in
                        
                        switch phase {
                        case .empty:
                            ShimmerEffectBox()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                            
                        case .failure(let error):
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .ignoresSafeArea()
                    .onTapGesture {
                        Task {
                            feedbackGenerator.impactOccurred()
                        }
                        if let url = URL(string: slides[i].link) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
            .onReceive(Timer.publish(every: Double(transitionTime) ?? 2, on: .main, in: .common).autoconnect(), perform: { _ in
                withAnimation{
                    selection = selection < slides.count - 1 ? selection + 1 : 0
                }
            })
        }
        .ignoresSafeArea()
    }
}

