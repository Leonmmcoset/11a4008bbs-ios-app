import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appsettings: AppSettings

    var body: some View {
        List {
            Toggle("自动检查更新", isOn: Binding(get: { self.appsettings.hasCancelledUpdate ? false : self.appsettings.isAutoCheckUpdate }, set: { self.appsettings.isAutoCheckUpdate = $0 }))
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}
