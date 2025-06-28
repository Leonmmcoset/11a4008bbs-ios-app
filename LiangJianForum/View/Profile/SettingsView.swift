import SwiftUI
import UIKit
import os

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("isAutoCheckUpdate") private var storedAutoCheckUpdate = true
    @State private var isHelpViewPresented = false
    @State private var currentIcon: String?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var showDebugView = false

    private func setAppIcon(_ iconName: String?) {
        UIApplication.shared.setAlternateIconName(iconName) {
            error in
            if let error = error {
                os_log("设置图标失败: %{public}@", log: .default, type: .error, error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.currentIcon = iconName
                }
            }
        }
    }

    private func getAvailableIcons() -> [String] {
        var iconNames: [String] = []
        if let iconsDict = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any] {
            if let alternateIcons = iconsDict["CFBundleAlternateIcons"] as? [String: Any] {
                iconNames = Array(alternateIcons.keys)
            }
        }
        return iconNames
    }

    var body: some View {
        NavigationView {
            List {
                Section("更换图标") {
                    HStack {
                        Text("当前图标")
                        Spacer()
                        if let currentIconName = currentIcon {
                            if let icon = UIImage(named: currentIconName) ?? UIImage(named: "新版图标.appiconset/".appending(currentIconName)) {
                                Image(uiImage: icon)
                                   .resizable()
                                   .frame(width: 40, height: 40)
                            }
                            Text(currentIconName)
                        } else {
                            if let icon = UIImage(named: "新版图标") ?? UIImage(named: "新版图标.appiconset/bbsicon-iOS-Default-1024x1024@1x.png") {
                                Image(uiImage: icon)
                                   .resizable()
                                   .frame(width: 40, height: 40)
                            }
                            Text("新版图标")
                        }
                    }

                    ForEach(getAvailableIcons(), id: \.self) {
 iconName in
                        Button {
                            feedbackGenerator.impactOccurred()
                            setAppIcon(iconName)
                        } label: {
                            HStack {
                                if let icon = UIImage(named: iconName) ?? UIImage(named: "新版图标.appiconset/".appending(iconName)) {
                                    Image(uiImage: icon)
                                       .resizable()
                                       .frame(width: 40, height: 40)
                                }
                                Text(iconName)
                            }
                        }
                    }
                    Picker("主题模式", selection: Binding(get: { self.appSettings.themeMode }, set: { newTheme in
                        feedbackGenerator.impactOccurred()
                        self.appSettings.themeMode = newTheme
                        self.appSettings.saveThemeSettings()
                    })) {
                        Text("系统默认").tag(ThemeMode.system)
                        Text("浅色模式").tag(ThemeMode.light)
                        Text("深色模式").tag(ThemeMode.dark)
                    }
                    Toggle("自动检查更新", isOn: Binding(get: { self.appSettings.hasCancelledUpdate ? false : self.appSettings.isAutoCheckUpdate }, set: { 
                        feedbackGenerator.impactOccurred()
                        self.appSettings.isAutoCheckUpdate = $0
                    }))
                    .onTapGesture {
                        showDebugView = true
                    }
                    Button("检查更新") {
                        feedbackGenerator.impactOccurred()
                        checkManualVersionUpdate()
                    }
                    Button("论坛帮助文档") {
                        feedbackGenerator.impactOccurred()
                        isHelpViewPresented = true
                    }
                    .sheet(isPresented: $isHelpViewPresented) {
                        FlarumHelpView()
                    }
                }
            }
            .listStyle(.automatic)
            .navigationTitle("设置")
            .onAppear {
                currentIcon = UIApplication.shared.alternateIconName
            }
            .sheet(isPresented: $showDebugView) {
                DebugView()
            }
        }
    }
}
