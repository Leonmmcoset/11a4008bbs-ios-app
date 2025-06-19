import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appsettings: AppSettings

    var body: some View {
        List {
            Toggle("自动检查更新", isOn: Binding(get: { self.appsettings.hasCancelledUpdate ? false : self.appsettings.isAutoCheckUpdate }, set: { self.appsettings.isAutoCheckUpdate = $0 }))
                Button("检查更新") {
                checkManualVersionUpdate()
            }
            
            @State var isHelpViewPresented = false

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
