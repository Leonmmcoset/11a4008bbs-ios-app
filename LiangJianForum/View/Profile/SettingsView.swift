import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("isAutoCheckUpdate") private var storedAutoCheckUpdate = true
    @State private var isHelpViewPresented = false

    var body: some View {
        List {
            Picker("主题模式", selection: Binding(get: { self.appSettings.themeMode }, set: { newTheme in
                self.appSettings.themeMode = newTheme
                self.appSettings.saveThemeSettings()
            })) {
                Text("系统默认").tag(ThemeMode.system)
                Text("浅色模式").tag(ThemeMode.light)
                Text("深色模式").tag(ThemeMode.dark)
            }
            Toggle("自动检查更新", isOn: Binding(get: { self.appSettings.hasCancelledUpdate ? false : self.appSettings.isAutoCheckUpdate }, set: { self.appSettings.isAutoCheckUpdate = $0 }))
                Button("检查更新") {
                checkManualVersionUpdate()
            }
            Button("论坛帮助文档") {
                isHelpViewPresented = true
            }
            .sheet(isPresented: $isHelpViewPresented) {
                FlarumHelpView()
            }
            
        }
        .listStyle(.automatic)
        .navigationTitle("设置")
    }
}
