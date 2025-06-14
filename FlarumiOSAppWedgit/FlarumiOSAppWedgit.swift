//
//  FlarumiOSAppWidget.swift
//  FlarumiOSAppWidget
//
//  Created by 李正杰 on 2025/4/23.
//

import WidgetKit
import SwiftUI
import Combine

// 数据提供者，严格遵循 TimelineProvider 协议
struct Provider: TimelineProvider {
    // 占位条目（数据未准备时显示）
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            discussionsCount: 0,
            postsCount: 0,
            usersCount: 0,
            errorMessage: nil
        )
    }

    // 生成预览快照
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let previewEntry = SimpleEntry(
            date: Date(),
            discussionsCount: 72,
            postsCount: 198,
            usersCount: 55,
            errorMessage: nil
        )
        completion(previewEntry)
    }

    // 生成时间线数据
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let currentDate = Date()
        fetchRealData { discussions, posts, users, errorMessage in
            let entry = SimpleEntry(
                date: currentDate,
                discussionsCount: discussions,
                postsCount: posts,
                usersCount: users,
                errorMessage: errorMessage
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(currentDate.addingTimeInterval(3600))
            )
            completion(timeline)
        }
    }

    // 异步获取论坛统计数据
    private func fetchRealData(completion: @escaping (Int, Int, Int, String?) -> Void) {
        guard let url = URL(string: "https://brt.arw.pub/api?redirectjs=&redirectjs_sign=") else {
            completion(0, 0, 0, "无法构建有效的URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token pj4hguy4H0J1lwEMyaKrIyOJUfFr32Sdx9hGoDmq", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(0, 0, 0, "网络请求失败: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion(0, 0, 0, "未获取到有效数据")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("获取到的数据: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let forumData = try decoder.decode(ForumData.self, from: data)
                completion(
                    forumData.data.attributes.forumStatistics.discussionsCount,
                    forumData.data.attributes.forumStatistics.postsCount,
                    forumData.data.attributes.forumStatistics.usersCount,
                    nil
                )
            } catch let decodingError as DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("解码错误: 未找到键 \(key)，路径: \(context.codingPath)，调试信息: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("解码错误: 类型不匹配 \(type)，路径: \(context.codingPath)，调试信息: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("解码错误: 未找到值 \(type)，路径: \(context.codingPath)，调试信息: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("解码错误: 数据损坏，路径: \(context.codingPath)，调试信息: \(context.debugDescription)")
                @unknown default:
                    print("未知的解码错误: \(decodingError)")
                }
                completion(0, 0, 0, "数据解码错误: \(decodingError.localizedDescription)")
            } catch {
                print("未知错误: \(error)")
                completion(0, 0, 0, "数据解码错误: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// 时间线条目
struct SimpleEntry: TimelineEntry {
    let date: Date
    let discussionsCount: Int
    let postsCount: Int
    let usersCount: Int
    let errorMessage: String?
}

// MARK: - 严格匹配服务器数据的模型
struct ForumData: Codable {
    struct DataEntry: Codable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Codable {
        struct ForumStatistics: Codable {
            let discussionsCount: Int
            let postsCount: Int
            let usersCount: Int
        }

        enum CodingKeys: String, CodingKey {
            case forumStatistics = "fof-forum-statistics-widget"
        }

        let forumStatistics: ForumStatistics
    }

    let data: DataEntry
}

// 小组件内容视图
struct FlarumiOSAppWidgetEntryView: View {
    var entry: SimpleEntry
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        VStack {
            if let error = entry.errorMessage {
                ErrorView(message: error, date: entry.date)
            } else {
                StatisticsView(
                    discussions: entry.discussionsCount,
                    posts: entry.postsCount,
                    users: entry.usersCount,
                    date: entry.date
                )
            }
        }
       .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// 统计数据显示视图
struct StatisticsView: View {
    let discussions: Int
    let posts: Int
    let users: Int
    let date: Date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("论坛数据")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 8)

            StatItem(
                icon: "text.bubble",
                label: "主帖",
                value: discussions
            )
            StatItem(
                icon: "arrowshape.turn.up.left",
                label: "回复",
                value: posts
            )
            StatItem(
                icon: "person",
                label: "用户",
                value: users
            )

            Text("更新于 \(dateFormatter.string(from: date))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

// 统计项单元格
struct StatItem: View {
    let icon: String
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .imageScale(.small)

            Text("\(label): \(value)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// 错误信息显示视图
struct ErrorView: View {
    let message: String
    let date: Date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 12) {
            Text("数据加载失败")
                .font(.headline)
                .foregroundColor(.red)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Text("最后更新: \(dateFormatter.string(from: date))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

// 小组件定义
struct FlarumiOSAppWidget: Widget {
    let kind: String = "FlarumiOSAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlarumiOSAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("论坛统计小组件")
        .description("实时显示论坛主帖、回复和用户数量")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// 预览 - 正常数据状态
#Preview("Small Widget") {
    FlarumiOSAppWidgetEntryView(entry: SimpleEntry(
        date: Date(),
        discussionsCount: 72,
        postsCount: 198,
        usersCount: 55,
        errorMessage: nil
    ))
}

// 预览 - 错误状态
#Preview("Error State") {
    FlarumiOSAppWidgetEntryView(entry: SimpleEntry(
        date: Date(),
        discussionsCount: 0,
        postsCount: 0,
        usersCount: 0,
        errorMessage: "网络连接失败，请检查网络设置"
    ))
}
