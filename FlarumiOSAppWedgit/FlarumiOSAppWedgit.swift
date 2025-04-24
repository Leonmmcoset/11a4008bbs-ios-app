//
//  FlarumiOSAppWidget.swift
//  FlarumiOSAppWidget
//
//  Created by 李正杰 on 2025/4/23.
//

import WidgetKit
import SwiftUI
import Combine

// 数据提供者，负责生成小组件展示的时间线数据
struct Provider: AppIntentTimelineProvider {
    // 提供占位条目，用于在数据尚未准备好时展示
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            discussionsCount: 0,
            postsCount: 0,
            usersCount: 0,
            errorMessage: nil
        )
    }

    // 提供用于预览的快照数据
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let mockEntry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            discussionsCount: 73,
            postsCount: 270,
            usersCount: 34,
            errorMessage: nil
        )
        return mockEntry
    }

    // 生成时间线数据，包含真实的论坛统计数据
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()

        // 异步获取真实数据
        let (discussions, posts, users, errorMessage) = await fetchRealData()

        // 生成包含数据的时间线条目
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            discussionsCount: discussions,
            postsCount: posts,
            usersCount: users,
            errorMessage: errorMessage
        )
        entries.append(entry)

        return Timeline(entries: entries, policy:.after(currentDate.addingTimeInterval(3600)))
    }

    // 异步获取真实数据的函数
    private func fetchRealData() async -> (Int, Int, Int, String?) {
        guard let url = URL(string: "https://brt.arw.pub/api") else {
            return (0, 0, 0, "无法构建有效的URL")
        }

        // 创建带有认证头的URL请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token pj4hguy4H0J1lwEMyaKrIyOJUfFr32Sdx9hGoDmq", forHTTPHeaderField: "Authorization")

        do {
            // 使用接受URLRequest的版本
            let (data, _) = try await URLSession.shared.data(for: request)
            // 打印原始数据
            if let dataString = String(data: data, encoding:.utf8) {
                print("API 返回的原始数据：\(dataString)")
            }
            let decoder = JSONDecoder()
            let forumData = try decoder.decode(ForumData.self, from: data)

            // 打印解码后的数据
            print("API 返回的数据：\(forumData)")

            return (
                forumData.data.attributes.forumStatistics.discussionsCount,
                forumData.data.attributes.forumStatistics.postsCount,
                forumData.data.attributes.forumStatistics.usersCount,
                nil
            )
        } catch {
            let errorMessage = "数据获取错误: \(error)"
            print(errorMessage)
            return (0, 0, 0, errorMessage)
        }
    }
}

// 时间线条目，包含日期、配置、论坛统计数据和错误信息
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let discussionsCount: Int
    let postsCount: Int
    let usersCount: Int
    let errorMessage: String?
}

// 论坛数据模型，用于解码API返回的JSON数据
struct ForumData: Codable {
    struct DataModel: Codable {
        struct Attributes: Codable {
            struct ForumStatistics: Codable {
                let discussionsCount: Int
                let postsCount: Int
                let usersCount: Int
            }

            // 修正属性名与JSON键的映射（使用CodingKeys）
            enum CodingKeys: String, CodingKey {
                case forumStatistics = "fof-forum-statistics-widget"
            }

            let forumStatistics: ForumStatistics
        }

        let attributes: Attributes
    }

    let data: DataModel
}

// 论坛统计数据模型
struct ForumStatistics: Codable {
    let discussionsCount: Int
    let postsCount: Int
    let usersCount: Int
}

// 小组件内容视图，展示论坛统计数据或错误信息
struct FlarumiOSAppWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        if #available(iOS 17.0, *) {
            content
               .containerBackground(.white, for:.widget)
        } else {
            content
        }
    }

    private var content: some View {
        if let errorMessage = entry.errorMessage {
            return AnyView(
                VStack(alignment:.center, spacing: 8) {
                    Text("数据获取失败")
                       .font(.headline)
                       .foregroundColor(.red)
                    Text(errorMessage)
                       .font(.subheadline)
                       .foregroundColor(.secondary)
                }
               .transition(.opacity)
            )
        } else {
            return AnyView(
                VStack(alignment:.leading, spacing: 8) {
                    // 小组件标题
                    Text("论坛数据")
                       .font(.headline)
                       .foregroundColor(.primary)
                       .transition(.scale) // 添加淡入淡出动画

                    // 讨论数
                    HStack {
                        Image(systemName: "text.bubble")
                           .foregroundColor(.accent)
                        Text("帖子: \(entry.discussionsCount)")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                    }
                   .transition(.opacity) // 添加渐变显示动画

                    // 帖子数
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left")
                           .foregroundColor(.accent)
                        Text("回复: \(entry.postsCount)")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                    }
                   .transition(.opacity) // 添加渐变显示动画

                    // 用户数
                    HStack {
                        Image(systemName: "person")
                           .foregroundColor(.accent)
                        Text("用户: \(entry.usersCount)")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                    }
                   .transition(.opacity) // 添加渐变显示动画

                    HStack {
                        Text("数据由11A4008论坛API获取")
                           .font(.system(size: 6))
                           .foregroundColor(.secondary)
                    }
                }
               .transition(.opacity)
            )
        }
    }
}

// 小组件定义
struct FlarumiOSAppWidget: Widget {
    let kind: String = "FlarumiOSAppWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FlarumiOSAppWidgetEntryView(entry: entry)
        }
       .configurationDisplayName("论坛统计小组件")
       .description("显示论坛实时讨论、帖子和用户数量")
       .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])
    }
}

#Preview(as:.systemSmall) {
    // 预览主体应为Widget本身
    FlarumiOSAppWidget()
} timeline: {
    // 提供符合TimelineEntry协议的条目数据
    SimpleEntry(
        date:.now,
        // 按理说这部分代码在真正APP中是会调用API获取数据的
        // 这里应该只是演示
        configuration: ConfigurationAppIntent(),
        discussionsCount: 73,
        postsCount: 270,
        usersCount: 34,
        errorMessage: nil
    )
}
