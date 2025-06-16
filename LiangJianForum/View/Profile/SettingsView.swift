import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appsettings: ViewAppSettings

    var body: some View {
        List {
            Toggle("自动检查更新", isOn: $appsettings.isAutoCheckUpdate)
                .padding(.vertical, 8)
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}