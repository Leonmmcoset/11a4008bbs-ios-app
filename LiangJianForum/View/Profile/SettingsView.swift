import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("isAutoCheckUpdate") private var storedAutoCheckUpdate = true
    @State private var isHelpViewPresented = false
    @State private var currentIcon: String?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private func setAppIcon(_ iconName: String?) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("设置图标失败: \(error.localizedDescription)")
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
        List {
            Section("更换图标") {
                HStack {
                    Text("当前图标")
                    Spacer()
                    if let currentIconName = currentIcon {
                        Image(uiImage: UIImage(named: currentIconName) ?? UIImage())
                           .resizable()
                           .frame(width: 40, height: 40)
                        Text(currentIconName)
                    } else {
                        Image(uiImage: UIImage(named: "新版图标") ?? UIImage())
                           .resizable()
                           .frame(width: 40, height: 40)
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
                            Image(uiImage: UIImage(named: iconName) ?? UIImage())
                               .resizable()
                               .frame(width: 40, height: 40)
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
            .listStyle(.automatic)
            .navigationTitle("设置")
            .onAppear {
                currentIcon = UIApplication.shared.alternateIconName
            }
        }
    }
}
