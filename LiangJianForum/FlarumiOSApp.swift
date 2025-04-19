import SwiftUI
import BackgroundTasks

@main
struct FlarumiOSApp: App {
    @StateObject private var appSettings = AppSettings()
    @State private var showPrivacySheet = false // 用于跟踪是否显示隐私提示 Sheet

    var body: some Scene {
        // 创建 URL 请求
        let url = URLRequest(url: URL(string: "https://baidu.com")!)
        WindowGroup {
            LoginPageView()
               .environmentObject(appSettings)
               .onAppear {
                    // 检查是否是第一次打开 app
                    if !UserDefaults.standard.bool(forKey: "hasAcceptedPrivacyPolicy") {
                        showPrivacySheet = true
                    }
                }
               .sheet(isPresented: $showPrivacySheet) {
                    PrivacyPolicySheet(
                        isPresented: $showPrivacySheet,
                        onAccept: {
                            // 用户同意隐私条款，记录到 UserDefaults
                            UserDefaults.standard.set(true, forKey: "hasAcceptedPrivacyPolicy")
                        }
                    )
                   .presentationDetents([.large]) // 设置为大尺寸，无其他可拖动的尺寸
                   .interactiveDismissDisabled() // 禁用交互式关闭
                }
        }
       .backgroundTask(.appRefresh("checkSessionAfterOneHour")) {
            scheduleAppRefresh()
            await refreshUser()
        }
       .backgroundTask(.urlSession("refreshUser")) {

        }
    }

    private func refreshUser() async {
        print("Refresh user token in Background...")
        print("user identification : \(appSettings.identification)")
        print("user password : \(appSettings.password)")

        let config = URLSessionConfiguration.background(withIdentifier: "refreshUser")
        config.sessionSendsLaunchEvents = true
        let session = URLSession(configuration: config)

        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/token") else {
            print("Invalid URL!")
            return
        }

        let parameters: [String: String] = [
            "identification": appSettings.identification,
            "password": appSettings.password
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to convert username and password to JSON!")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let (data, _) = try? await session.data(for: request) {
            let decoder = JSONDecoder()
            do {
                let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                appSettings.token = tokenResponse.token
                appSettings.userId = tokenResponse.userId
            } catch {
                print("Failed to decode token response: \(error)")
            }
        }
    }
}

func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "checkSessionAfterOneHour")
    // Fetch no earlier than about 1 hour from now.
    request.earliestBeginDate = Date(timeIntervalSinceNow: 55 * 60)

    do {
        try BGTaskScheduler.shared.submit(request)
        print("Scheduled app refresh for one hour later.")
    } catch {
        print("Error scheduling app refresh: \(error)")
    }
}

// 自定义的隐私政策 Sheet 视图
struct PrivacyPolicySheet: View {
    @Binding var isPresented: Bool
    var onAccept: () -> Void
    // 获取应用版本号
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    // 获取应用构建版本号
    let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"

    var body: some View {
        VStack {
            Spacer()
            Image(.bbsLogo)
               .padding(.top, 20)
               .frame(width: 120, height: 100)
            
            Text("欢迎使用LeonMMcoset论坛APP")
               .font(.system(size: 22))
               .padding()
               .bold()
            
            VStack(alignment:.leading) {
                Text("请允许隐私条款中的内容以使用此APP")
                Link("隐私条款", destination: URL(string: "https://brt.arw.pub/p/2-privacyagreement")!)
                Text("")
                Text("如有Bug，请在论坛汇报并@LeonMMcoset")
                // 显示版本和构建版本信息
                Text("版本: \(appVersion) (构建版本: \(appBuild))")
                Text("请注意")
                    .bold()
                Text("此APP并不支持IPad，只是对Ipad屏幕做适配，对于Ipad的Bug不修！")
                Text("建议使用最新的iOS版本使用此APP")
            }
            
            Button(NSLocalizedString("moneyauthor", comment: ""), action: {
                UIApplication.shared.open(URL(string: "https://afdian.com/a/leonmmcoset")!)
            })
            .foregroundColor(Color.blue)
                .frame(maxWidth:.infinity)
                .padding()
//                .background(Color.blue)
//                .cornerRadius(10)
                .padding([.leading, .trailing], 20)
            
            Button("打开应用设置", action: {
                openAppSettings()
            })
            .foregroundColor(Color.blue)
                .frame(maxWidth:.infinity)
                .padding()
//                .background(Color.blue)
//                .cornerRadius(10)
                .padding([.leading, .trailing], 20)

            Spacer()
            
            Button("同意") {
                onAccept()
                isPresented = false
            }
           .foregroundColor(.white)
           .frame(maxWidth:.infinity)
           .padding()
           .background(Color.blue)
           .cornerRadius(10)
           .padding([.leading, .trailing], 20)
        }
    }
    // MARK: - Open APP settings
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
    
