//
//  ContentView.swift
//  LiangJianF
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI


struct LoginPageView: View {
    @EnvironmentObject var appsettings: AppSettings
    @AppStorage("username") private var storedUsername = ""
    @AppStorage("password") private var storedPassword = ""
    @AppStorage("rememberMe") private var rememberMeState = false
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername: CGFloat = 0
    @State private var token = ""
    @State private var userId = 0
    @State private var wrongPassword: CGFloat  = 0
    @State private var showingMainPageView = false
    @State private var isAnimating = false
    @State private var showingRegistrationView = false
    @State private var showingProgressView = false
    @State private var rememberMe = false
    @State private var showAlert = false
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedFlarumUrl = "https://bbs.cjlu.cc"
    
    // 新增动画相关状态变量
    @State private var emailFieldOffset: CGFloat = 0
    @State private var passwordFieldOffset: CGFloat = 0
    @State private var buttonScale: CGFloat = 1
    @State private var toggleTranslation: CGFloat = 0
    @State private var termsOpacity: Double = 0
    @State private var showLoginSuccessAlert = false
    @State private var alertTimer: Timer?
    @State private var isShowToast = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if colorScheme == .dark{
                    Color(hex: "A1C9CE")
                        .ignoresSafeArea()
                }else{
                    Color.flarumTheme2
                        .ignoresSafeArea()
                }
                
                Circle()
                    .scaleEffect(isAnimating ? 1.7 : 0.3)
                        .animation(.linear(duration: 0.6), value: isAnimating)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "A1C9CE") : Color(hex: "A1C9CE"))
                
                Circle()
                    .scaleEffect(isAnimating ? 1.35 : 0)
                        .animation(.spring(), value: isAnimating)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "0b2b4d") : Color(hex: "d3e8ff"))

                VStack {
                    Text(appSettings.FlarumName)
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                        .padding(.bottom, 30)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -50)
                        .animation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.2), value: isAnimating)
                        .onAppear {
                            withAnimation {
                                isAnimating = true
                            }
                        }
                  
                    TextFieldWithIcon(iconName: "person.fill", inputText: $username, label: NSLocalizedString("username", comment: ""), isAnimating: $isAnimating, wrongInputRedBorder: $wrongUsername)
                    .onAppear {
                        username = storedUsername
                        withAnimation(.timingCurve(0.2, 0.8, 0.4, 1)) {
                            emailFieldOffset = 30
                        }
                    }
                    .offset(x: wrongUsername != 0 ? (wrongUsername > 0 ? 10 : -10) : 0)
                    .rotationEffect(.degrees(Double(wrongUsername != 0 ? (wrongUsername > 0 ? 5 : -5) : 0)))
                    .animation(.timingCurve(0.5, -0.5, 0.5, 1.5).repeatCount(2), value: wrongUsername)
                    
                    SecureFieldWithIcon(passwordIconName: "key.fill", inputPassword: $password , passwordLabel: NSLocalizedString("password", comment: ""), isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongPassword)
                        .padding(.bottom)
                    .onAppear {
                        password = storedPassword
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeOut(duration: 0.6)) {
                                passwordFieldOffset = 30
                            }
                        }
                    }
                    .offset(y: passwordFieldOffset)

                    Button(action: {
                        withAnimation(.spring()) {
                            buttonScale = 0.95
                        }
                        authenticateUser { success in
                            withAnimation(.spring()) {
                                buttonScale = 1
                            }
                            if success {
                                // 添加带动画对勾的状态变量
                            @State var showCheckmark = false
                                // 显示对勾动画
                                withAnimation(.spring()) {
                                    showCheckmark = true
                                }
                                // 对勾动画视图，提前声明
                                // 这个地方放在这里就对了，不要删，即使报警告
                                let checkmark = VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.green)
                                        .opacity(showCheckmark ? 1 : 0)
                                        // 正确声明 checkmark 变量，需根据实际视图内容调整
                                    let checkmark = Text("✓") // 示例对勾视图，可根据实际调整
                                        .scaleEffect(showCheckmark ? 1 : 0.5)
                                }
                                // 将对勾视图添加到主视图中
                                // 移除重复声明，使用上方已声明的 checkmark 变量
                                .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                                // 展示对勾视图
                                Task{
                                    await fetchUserProfile()
                                }
                            } else {
                                showAlert.toggle()
                            }
                        }
                    }) {
                        Text("Sign in")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 350, height: 50)
                            .background(
                                Color(hex: "A1C9CE")
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                                    .scaleEffect(buttonScale)
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
//                    .navigationDestination(isPresented: $showingMainPageView, destination: {
//                        ContentView().environmentObject(appSettings).navigationBarBackButtonHidden(true)
//                    })
                    .opacity(isAnimating ? 0.9 : 0)
                    .offset(y: isAnimating ? 0 : 50)
                    .animation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.4), value: isAnimating)
                    .onDisappear {
                        storedUsername = username
                        storedPassword = password
                        rememberMeState = rememberMe
                    }
                    .hoverEffect(.lift)
                    
                    NavigationLink(destination: ContentView().environmentObject(appSettings).navigationBarBackButtonHidden(true), isActive: $showingMainPageView) {
                    }
                    .onTapGesture {
                        if !showingMainPageView{
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        }
                    }
                    
                    if showingProgressView{
                        ProgressView()
                            .padding(.top)
                    }

                    ZStack{
                        NavigationLink {
                            RegistrationView().environmentObject(appSettings).navigationBarBackButtonHidden(false)
                        } label: {
                            Text("Sign up")
                            .fontWeight(.bold)
                            .font(.system(size: 15))
                            .opacity(isAnimating ? 0.8 : 0)
                            .animation(.spring(), value: isAnimating)
                        }
                        
                        HStack {
                            Spacer()
                            Toggle(isOn: $rememberMe){
                                Text("Remember Me")
                                    .font(.system(size: 15))
                                    .opacity(0.8)
                                    .offset(x: toggleTranslation)
                            }
                            .toggleStyle(.button)
                            .tint(.mint)
                            .padding(.trailing, 20)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 50)
                            .animation(.easeOut(duration: 1.2).delay(0.6), value: isAnimating)
                            .onChange(of: rememberMe) { newValue in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    toggleTranslation = newValue ? 15 : -15
                                }
                            }
                            .onAppear {
                                rememberMe = rememberMeState
                                toggleTranslation = rememberMeState ? 15 : -15
                            }
                        }
                    }
                    
                    VStack {
                        Text("**服务条款** ｜ **[隐私政策](https://www.apple.com/legal/privacy/szh/)**").font(.system(size: 10))
                            .opacity(termsOpacity)
                            .offset(y: termsOpacity > 0 ? 0 : 20)
                            .animation(.easeOut(duration: 1.0).delay(1.0), value: termsOpacity)
                    }
                    .frame(width: 350)
                    .padding(.top)
                    .onAppear {
                        termsOpacity = 1
                    }
                }
                .onChange(of: selectedFlarumUrl) { newValue in
                    appSettings.FlarumUrl = newValue
                }
                .navigationTitle("Sign in")
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Failed to sign in"),
                        message: Text("Please check your username/password or check the Internet connetction"),
                        dismissButton: .default(Text("OK")) {
//                            clearInputField()
                        }
                    )
                }
                .alert(isPresented: $showLoginSuccessAlert) { 
                    Alert(
                        title: Text("登录成功").foregroundColor(.green).font(.headline).accessibilityLabel("登录成功"),
                        message: nil,
                        dismissButton: .default(Text("确定"))
                    )
                }
            }
            
            .navigationBarHidden(true)
        }
    }

    private func clearInputField(){
        wrongUsername = 0
        wrongPassword = 0
        password = ""
        username = ""
        storedPassword = ""
        storedUsername = ""
    }
    
    private func authenticateUser(completion: @escaping (Bool) -> Void) {
        showingProgressView = true
        sendLoginRequest { success in
            showingProgressView = false
            
            if success, token != "", userId != 0 {
                appSettings.resetTimer()
                wrongUsername = 0
                wrongPassword = 0
                showingMainPageView = true
                appSettings.isLoggedIn = true
                appSettings.token = token
                appSettings.userId = userId
                appSettings.identification = username
                appSettings.password = password
                // 移除原有的 AlertToast 调用
                // AlertToast.showToast(isShow: &isShowToast, "登录成功")
                // 移除原有的登录成功弹窗逻辑
                // showLoginSuccessAlert = true
                // alertTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [self] _ in
                //     self.showLoginSuccessAlert = false
                // }
                // 使用原生实现 Toast 效果
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
                        let alert = UIAlertController(title: "登录成功", message: "欢迎回来，\(username)！\n您的ID：\(userId)", preferredStyle: .alert)
                        window.rootViewController?.present(alert, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                if rememberMe{
                    rememberMeState = true
                }else{
                    clearInputField()
                    rememberMeState = false
                }
                print("Token: \(appSettings.token)")
                print("User ID: \(appSettings.userId)")
                completion(true) // Authentication success
            } else {
                
                wrongUsername = 2
                wrongPassword = 2
                
                completion(false) // Authentication failed
            }
        }
    }

    private func sendLoginRequest(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/token") else {
            print("Invalid URL!")
            completion(false)
            return
        }
        
        let parameters: [String: String] = [
            "identification": username,
            "password": password
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to convert username and password to JSON!")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response from post /api/token")
                completion(false)
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                    
                    self.token = tokenResponse.token
                    self.userId = tokenResponse.userId
                    
                    completion(true) // Authentication success
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }.resume()
    }
    
    private func fetchUserProfile() async {
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users/\(appSettings.userId)") else{
                print("Invalid URL")
            return
        }
        print("Fetching User Info at: \(url)")
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data){
                let username = decodedResponse.data.attributes.username
                appSettings.username = username
                
                appSettings.displayName = decodedResponse.data.attributes.displayName
                appSettings.joinTime = calculateTimeDifference(from: decodedResponse.data.attributes.joinTime)
                appSettings.discussionCount = decodedResponse.data.attributes.discussionCount
                appSettings.commentCount = decodedResponse.data.attributes.commentCount
                
                if let cover = decodedResponse.data.attributes.cover{
                    appSettings.cover = cover
                }
                
                if appSettings.vipUsernames.contains(username){
                    appSettings.isVIP = true
                }
                
                if let canCheckIn = decodedResponse.data.attributes.canCheckin{
                    appSettings.canCheckIn = canCheckIn
                }
                
                if let canCheckinContinuous = decodedResponse.data.attributes.canCheckinContinuous{
                    appSettings.canCheckinContinuous = canCheckinContinuous
                }
                
                if let totalContinuousCheckIn = decodedResponse.data.attributes.totalContinuousCheckIn{
                    appSettings.totalContinuousCheckIn = totalContinuousCheckIn
                }
                
                if let include = decodedResponse.included {
                    if include.contains(where: { $0.id == "1" && $0.type == "groups"}) {
                        appSettings.isAdmin = true
                    }
                }
                
                appSettings.userExp = getUserLevelExp(commentCount: decodedResponse.data.attributes.commentCount, discussionCount: decodedResponse.data.attributes.discussionCount)


                print("Successfully decoded user data when sign in success!")
                print("username : \(appSettings.username)")
                print("userId : \(appSettings.userId)")
                print("canCheckIn : \(appSettings.canCheckIn)")
                print("canCheckinContinuous : \(appSettings.canCheckinContinuous)")
                print("totalContinuousCheckIn : \(appSettings.totalContinuousCheckIn)")
                print("isAdmin : \(appSettings.isAdmin)")
            }
        } catch {
            print("Invalid user Data!" ,error)
        }
    }

}

struct TokenResponse: Codable {
    let token: String
    let userId: Int
}
    
