//
//  HeaderSlideData.swift
//  FlarumiOSApp
//
//  Created by Romantic D on 2023/8/25.
//

import Foundation

// MARK: - HeaderSlideData
/// 表示头部轮播图的数据结构。
struct HeaderSlideData: Codable, Hashable {
    /// 轮播图切换时间。
    let transitionTime: String
    /// 轮播图列表数据。
    let list: [SlideData]
}

// MARK: - List
/// 表示单个轮播图的数据结构。
struct SlideData: Codable, Hashable {
    /// 轮播图的图片地址。
    let image: String
    /// 轮播图的链接地址。
    let link: String
}

