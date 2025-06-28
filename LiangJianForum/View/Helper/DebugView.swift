//
//  DebugView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2024/10/1.
//

import SwiftUI
import Foundation
import os
import os.log
#if canImport(AppKit)
import AppKit
#endif
#if os(iOS) || os(iPadOS)
@available(iOS 10.0, *)
#endif
struct DebugView: View {
    @State private var logContent = "" 
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("调试页面")
                .font(.largeTitle)
                .padding()

            Button("查看日志") {
                loadLogs()
            }
            .padding()
            .buttonStyle(.borderedProminent)

            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    Text(logContent)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadLogs() {
        isLoading = true
        Task { 
            do { 
#if canImport(AppKit) 
                let task = Process() 
                task.executableURL = URL(fileURLWithPath: "/usr/bin/log") 
                task.arguments = ["show", "--predicate", "process == \"LiangJianForum\"", "--style", "syslog"] 

                let pipe = Pipe() 
                task.standardOutput = pipe 
                try task.run() 
                task.waitUntilExit() 

                let data = pipe.fileHandleForReading.readDataToEndOfFile() 
                if let logs = String(data: data, encoding: .utf8) { 
                    await MainActor.run { 
                        logContent = logs 
                        isLoading = false 
                    } 
                } 
#else
                // iOS环境不支持OSLogStore，使用文件日志记录
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent("app_logs.txt")
                    do {
                        let logText = try String(contentsOf: fileURL, encoding: .utf8)
                        await MainActor.run { 
                            logContent = "日志已保存到本地文件，路径：\(fileURL.path)\n\n内容：\(logText)"
                            isLoading = false 
                        }
                    } catch {
                        await MainActor.run { 
                            logContent = "未找到日志文件或读取失败：\(error.localizedDescription)"
                            isLoading = false 
                        }
                    }
                }
#endif 
            } catch { 
                await MainActor.run { 
                    logContent = "获取日志失败: \(error.localizedDescription)" 
                    isLoading = false 
                } 
            } 
        } 
    } 
}
