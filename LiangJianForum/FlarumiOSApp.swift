import SwiftUI
import BackgroundTasks

@main
struct FlarumiOSApp: App {
    @StateObject private var appSettings = AppSettings()
    @State private var showPrivacySheet = false // 用于跟踪是否显示隐私提示 Sheet

    var body: some Scene {
        WindowGroup {
            LoginPageView()
               .environmentObject(appSettings)
               .onAppear {
                    // 检查是否是第一次打开 app
                    if !UserDefaults.standard.bool(forKey: "hasAcceptedPrivacyPolicy") {
                        showPrivacySheet = true
                    }
                    checkAutomaticVersionUpdate()
                    print("rootViewController 状态: ", UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene, "的根视图控制器 ", (UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.windows.first?.rootViewController)
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

// 自定义的隐私政策 Sheet 视图（优化后符合苹果原生UI）
struct PrivacyPolicySheet: View {
    @Binding var isPresented: Bool
    var onAccept: () -> Void
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"

    var body: some View {
        VStack(spacing: 24) {
            Image(.bbsLogo)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(Color(.systemBlue))
                .padding(.top, 32)
            
            Text("欢迎使用LeonMMcoset论坛APP")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.label))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("请允许隐私条款中的内容以使用此APP")
                    .font(.subheadline)
                    .foregroundColor(Color(.label))
                
                Link("隐私条款", destination: URL(string: "https://brt.arw.pub/p/2-privacyagreement")!)
                    .font(.subheadline)
                    .foregroundColor(Color(.systemBlue))
                    .underline()
                
                Text("如有Bug，请在论坛汇报并@LeonMMcoset")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                
                Text("版本: \(appVersion) (构建版本: \(appBuild))")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                
                Text("请注意")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.label))
                
                Text("此APP并不支持IPad，只是对Ipad屏幕做适配，对于Ipad的Bug不修！")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                
                Text("建议使用最新的iOS版本使用此APP")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                Button(NSLocalizedString("moneyauthor", comment: ""), action: {
                    UIApplication.shared.open(URL(string: "https://afdian.com/a/leonmmcoset")!)
                })
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemBlue), lineWidth: 1)
                )
                .foregroundColor(Color(.systemBlue))
                .font(.subheadline)
                .fontWeight(.semibold)
                .contentShape(RoundedRectangle(cornerRadius: 16))
                
                Button("打开应用设置", action: openAppSettings)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color(.systemGray6))
                    .foregroundColor(Color(.label))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .cornerRadius(16)
                    .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            
            Button("同意") {
                onAccept()
                isPresented = false
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBlue))
            .foregroundColor(.white)
            .font(.subheadline)
            .fontWeight(.semibold)
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
    }

    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}

struct VersionInfo: Codable {
    let version: String
    let web: String?
}

public func checkAutomaticVersionUpdate() {
    print("开始执行自动版本检查函数")
    guard let url = URL(string: "http://leonmmcoset.jjmm.ink:1000/web/update/11a4008bbsiosapp.json") else {
        print("版本检查URL无效，函数退出")
        return
    }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("版本检查出错: \(error)")
            return
        }
        if let data = data {
            do {
                let decoder = JSONDecoder()
                print("获取到的JSON数据: \(String(data: data, encoding: .utf8) ?? "无数据")")
                let versionInfo = try decoder.decode(VersionInfo.self, from: data)
                let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
                if versionInfo.version != currentVersion {
                    DispatchQueue.main.async {
                        if let webUrl = versionInfo.web {
                            showVersionUpdateAlert(webUrl, versionInfo.version)
                        }
                    }
                } else {
                    print("自动检测到无更新，不弹出提示框")
                }
            } catch {
                print("解析版本信息出错: \(error)")
            }
        }
    }
    task.resume()
}

public func checkManualVersionUpdate() {
    print("开始执行手动版本检查函数")
    guard let url = URL(string: "http://leonmmcoset.jjmm.ink:1000/web/update/11a4008bbsiosapp.json") else {
        print("版本检查URL无效，函数退出")
        return
    }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("版本检查出错: \(error)")
            return
        }
        if let data = data {
            do {
                let decoder = JSONDecoder()
                print("获取到的JSON数据: \(String(data: data, encoding: .utf8) ?? "无数据")")
                let versionInfo = try decoder.decode(VersionInfo.self, from: data)
                let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
                if versionInfo.version != currentVersion {
                    DispatchQueue.main.async {
                        if let webUrl = versionInfo.web {
                            showVersionUpdateAlert(webUrl, versionInfo.version)
                        }
                    }
                } else {
                    print("手动检测到无更新，准备弹出提示框")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "提示", message: "现在无更新", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default))
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(alert, animated: true)
                        }
                    }
                }
            } catch {
                print("解析版本信息出错: \(error)")
            }
        }
    }
    task.resume()
}

func showVersionUpdateAlert(_ updateUrl: String, _ newVersion: String) {
    let alert = UIAlertController(title: "发现新版本", message: "发现新版本 \(newVersion)，是否更新到最新版本？", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "进入更新网站", style: .default) {
        _ in
        if let url = URL(string: updateUrl) {
            UIApplication.shared.open(url)
        }
    })
    alert.addAction(UIAlertAction(title: "下次打开APP时提醒", style: .cancel))
    alert.addAction(UIAlertAction(title: "永不提醒", style: .destructive) {
        _ in
        // 记录用户选择，后续不再提醒
        UserDefaults.standard.set(true, forKey: "neverRemindVersionUpdate")
    })
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(alert, animated: true)
    }
}

    func checkVersionReminder() {
        // 检查是否设置了永不提醒
        let neverRemind = UserDefaults.standard.bool(forKey: "neverRemindVersionUpdate")
        if neverRemind {
            print("用户已设置永不提醒版本更新，跳过检查。")
            return
        }
    }
