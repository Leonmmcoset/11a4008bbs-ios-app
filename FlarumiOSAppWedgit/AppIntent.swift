//
//  AppIntent.swift
//  FlarumiOSAppWedgit
//
//  Created by 李正杰 on 2025/4/23.
//

import WidgetKit
import AppIntents

/// 小部件配置意图结构体。
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    /// 小部件配置的标题。
    static var title: LocalizedStringResource { "Configuration" }
    /// 小部件配置的描述。
    static var description: IntentDescription { "This is an example widget." }
}
