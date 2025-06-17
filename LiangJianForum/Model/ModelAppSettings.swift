import SwiftUI

class ModelAppSettings: ObservableObject {
    @Published var isLoggedIn = false
    @Published var FlarumUrl = "https://discuss.flarum.org"
    @Published var userId = ""
    @Published var username = ""
    @Published var displayName = ""
    @Published var avatarUrl: String?
    @Published var token = ""
    @Published var identification = ""
    @Published var password = ""
    @Published var isAutoCheckUpdate = true // 自动检查更新开关，默认开启
}