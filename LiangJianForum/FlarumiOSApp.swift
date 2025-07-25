import BackgroundTasks

import SwiftUI
import os



@main
struct FlarumiOSApp: App {
    @StateObject private var appSettings = AppSettings()
    @State private var showPrivacySheet = false // 用于跟踪是否显示隐私提示 Sheet

    var body: some Scene {
        WindowGroup {
            LoginPageView()
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.themeMode == .light ? .light : appSettings.themeMode == .dark ? .dark : nil)
                .onAppear {
                    // 检查是否是第一次打开 app
                    if !UserDefaults.standard.bool(forKey: "hasAcceptedPrivacyPolicy") {
                        showPrivacySheet = true
                    }
                    if appSettings.isAutoCheckUpdate {
                    checkAutomaticVersionUpdate()
                } else {
                    os_log("自动检查更新已关闭，跳过检查。", log: .default, type: .info)
                    }
                    os_log("rootViewController 状态: %{public}@ 的根视图控制器 %{public}@", log: .default, type: .info, String(describing: UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene), String(describing: (UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.windows.first?.rootViewController))
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
        os_log("Refresh user token in Background...", log: .default, type: .info)
        os_log("user identification : %{public}@", log: .default, type: .info, appSettings.identification)
        os_log("user password : %{public}@", log: .default, type: .info, appSettings.password)

        let config = URLSessionConfiguration.background(withIdentifier: "refreshUser")
        config.sessionSendsLaunchEvents = true
        let session = URLSession(configuration: config)

        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/token") else {
            os_log("Invalid URL!", log: .default, type: .error)
            return
        }

        let parameters: [String: String] = [
            "identification": appSettings.identification,
            "password": appSettings.password
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            os_log("Failed to convert username and password to JSON!", log: .default, type: .error)
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
                os_log("Failed to decode token response: %{public}@", log: .default, type: .error, String(describing: error))
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
        os_log("Scheduled app refresh for one hour later.", log: .default, type: .info)
    } catch {
        os_log("Error scheduling app refresh: %{public}@", log: .default, type: .error, String(describing: error))
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
            Image(.welcometoapp)
//                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 400)
                .foregroundColor(Color(.systemBlue))
                .padding(.top, 32)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text("欢迎使用LeonMMcoset论坛APP")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.label))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("请允许隐私条款中的内容以使用此APP")
                    .font(.subheadline)
                    .foregroundColor(Color(.label))
                
                Link("隐私条款", destination: URL(string: "https://11a.arw.pub/p/2-privacyagreement")!)
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
    os_log("开始执行自动版本检查函数", log: .default, type: .info)
    let neverRemind = UserDefaults.standard.bool(forKey: "neverRemindVersionUpdate")
    if neverRemind {
        os_log("用户已设置永不提醒，自动检查不弹出提示", log: .default, type: .info)
        return
    }
    guard let url = URL(string: "http://leonmmcoset.jjmm.ink:1000/web/update/11a4008bbsiosapp.json") else {
        os_log("版本检查URL无效，函数退出", log: .default, type: .error)
        return
    }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            os_log("版本检查出错: %{public}@", log: .default, type: .error, String(describing: error))
            return
        }
        if let data = data {
            do {
                let decoder = JSONDecoder()
                os_log("获取到的JSON数据: %{public}@", log: .default, type: .info, String(data: data, encoding: .utf8) ?? "无数据")
                let versionInfo = try decoder.decode(VersionInfo.self, from: data)
                let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
                if versionInfo.version != currentVersion {
                    DispatchQueue.main.async {
                        if let webUrl = versionInfo.web {
    showVersionUpdateAlert(webUrl, versionInfo.version)
                        }
                    }
                } else {
                    os_log("自动检测到无更新，不弹出提示框", log: .default, type: .info)
                }
            } catch {
                os_log("解析版本信息出错: %{public}@", log: .default, type: .error, String(describing: error))
            }
        }
    }
    task.resume()
}

public func checkManualVersionUpdate() {
    os_log("开始执行手动版本检查函数", log: .default, type: .info)
    // 手动检查时忽略永不提醒设置
    guard let url = URL(string: "http://leonmmcoset.jjmm.ink:1000/web/update/11a4008bbsiosapp.json") else {
        os_log("版本检查URL无效，函数退出", log: .default, type: .error)
        return
    }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            os_log("版本检查出错: %{public}@", log: .default, type: .error, String(describing: error))
            return
        }
        if let data = data {
            do {
                let decoder = JSONDecoder()
                os_log("获取到的JSON数据: %{public}@", log: .default, type: .info, String(data: data, encoding: .utf8) ?? "无数据")
                let versionInfo = try decoder.decode(VersionInfo.self, from: data)
                let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
                if versionInfo.version != currentVersion {
                    DispatchQueue.main.async {
                        if let webUrl = versionInfo.web {
                            showVersionUpdateAlert(webUrl, versionInfo.version, isManualCheck: true)
                        }
                    }
                } else {
                    os_log("手动检测到无更新，准备弹出提示框", log: .default, type: .info)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "提示", message: "现在无更新", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default))
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(alert, animated: true)
                        }
                    }
                }
            } catch {
                os_log("解析版本信息出错: %{public}@", log: .default, type: .error, String(describing: error))
            }
        }
    }
    task.resume()
}

func showVersionUpdateAlert(_ updateUrl: String, _ newVersion: String, isManualCheck: Bool = false) {
    let alert = UIAlertController(title: "发现新版本", message: "发现新版本 \(newVersion)，是否更新到最新版本？", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "进入更新网站", style: .default) {
        _ in
        if let url = URL(string: updateUrl) {
            UIApplication.shared.open(url)
        }
    })
    alert.addAction(UIAlertAction(title: "我知道了", style: .cancel))
    if !isManualCheck {
        alert.addAction(UIAlertAction(title: "永不提醒", style: .destructive) {
            _ in
            // 记录用户选择，后续不再提醒
            UserDefaults.standard.set(true, forKey: "neverRemindVersionUpdate")
        })
    }
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(alert, animated: true)
    }
}

    func checkVersionReminder() {
        // 检查是否设置了永不提醒
        let neverRemind = UserDefaults.standard.bool(forKey: "neverRemindVersionUpdate")
        if neverRemind {
            os_log("用户已设置永不提醒版本更新，跳过检查。", log: .default, type: .info)
            return
        }
    }
