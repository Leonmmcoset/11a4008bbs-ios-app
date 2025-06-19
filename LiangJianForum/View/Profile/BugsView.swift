//
//  BugsView.swift
//  FlarumiOSApp
//
//  Created by 李正杰 on 2025/2/22.
//

import SwiftUI

struct BugsView: View {
    let listItems = [
        NSLocalizedString("在发送帖子时无法选择标签", comment: ""),
        NSLocalizedString("注册只能用户名和昵称一样", comment: ""),
        NSLocalizedString("无法查看资产记录", comment: ""),
        NSLocalizedString("有些按钮无法点击", comment: "")
    ]

    var body: some View {
        NavigationStack {
            VStack {
                Text("已知问题")
                   .font(.title)
                   .padding(.top, 20)
                   .padding(.bottom, 10)
                List(0..<listItems.count, id: \.self) { index in
                    HStack {
                        Text("\(index + 1).")
                           .foregroundColor(.secondary)
                           .font(.subheadline)
                        Text(listItems[index])
                           .font(.body)
                    }
                   .padding(.vertical, 10)
                }
               .listStyle(.automatic)
               .background(Color(UIColor.systemGroupedBackground))
               .cornerRadius(10)
               .padding()
            }
        }
    }
}
