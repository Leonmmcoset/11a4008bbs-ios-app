//
//  AppIntent.swift
//  FlarumiOSAppWedgit
//
//  Created by 李正杰 on 2025/4/23.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }
}
