//
//  RegistrationView.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/17.
//

import SwiftUI

struct RegistrationView: View {
    @State private var username = ""
    @State private var displayname = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var email = ""
    @State private var wrongUsername: CGFloat = 0
    @State private var wrongDisplayrname: CGFloat = 0
    @State private var wrongPassword: CGFloat  = 0
    @State private var wrongRepeatPassword: CGFloat  = 0
    @State private var wrongEmail: CGFloat  = 0
    @State private var registrationSuccess = false
    @State private var backToLoginPage = false
    @State private var isAnimating = false
    @State private var showingRegistrationView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var errors: [String] = []
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme
    
    // 新增动画相关状态变量（与LoginPage风格统一）
    @State private var usernameFieldOffset: CGFloat = 0
    @State private var displaynameFieldOffset: CGFloat = 0
    @State private var passwordFieldOffset: CGFloat = 0
    @State private var repeatPasswordFieldOffset: CGFloat = 0
    @State private var emailFieldOffset: CGFloat = 0
    @State private var buttonScale: CGFloat = 1
    @State private var termsOpacity: Double = 0
    
    var body: some View {
        ZStack {
            if colorScheme == .dark{
                Color(hex: "A1C9CE")
                    .ignoresSafeArea(.all, edges: .bottom)
            }else{
                Color.flarumTheme2
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            
            Circle()
                .scaleEffect(isAnimating ? 1.7 : 0.3)
                    .animation(.easeInOut(duration: 0.6), value: isAnimating)
                    .foregroundColor(colorScheme == .dark ? Color(hex: "A1C9CE") : Color(hex: "A1C9CE"))
            
            Circle()
                .scaleEffect(isAnimating ? 1.35 : 0)
                    .animation(.easeInOut(duration: 1), value: isAnimating)
                    .foregroundColor(colorScheme == .dark ? Color(hex: "0b2b4d") : Color(hex: "d3e8ff"))
            
            VStack {
                Text(NSLocalizedString("\(appSettings.FlarumName)·注册", comment: ""))
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(colorScheme == .dark ? Color(hex: "EFEFEF") : .black)
                    .padding(.bottom, 30)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : -50)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                    .onAppear {
                        withAnimation {
                            isAnimating = true
                        }
                    }
                
                TextFieldWithIcon(iconName: "person.fill", inputText: $username, label: NSLocalizedString("用户名(登录用 数字或字母组合)", comment: ""), isAnimating: $isAnimating, wrongInputRedBorder: $wrongUsername)
                    .offset(y: usernameFieldOffset)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                            usernameFieldOffset = 30
                        }
                    }
                    .offset(x: wrongUsername != 0 ? (wrongUsername > 0 ? 10 : -10) : 0)
                    .rotationEffect(.degrees(Double(wrongUsername != 0 ? (wrongUsername > 0 ? 5 : -5) : 0)))
                    .animation(.easeInOut(duration: 0.2).repeatCount(2), value: wrongUsername)
                
//                TextFieldWithIcon(iconName: "person.crop.square.filled.and.at.rectangle", inputText: $displayname, label: "昵称(对外显示)", isAnimating: $isAnimating, wrongInputRedBorder: $wrongDisplayrname)
                // 显示昵称输入框时可添加类似动画，当前注释状态下暂不处理
                
                SecureFieldWithIcon(passwordIconName: "key.fill", inputPassword: $password , passwordLabel: NSLocalizedString("密码", comment: ""), isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongPassword)
                    .offset(y: passwordFieldOffset)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                            passwordFieldOffset = 30
                        }
                    }
                
                SecureFieldWithIcon(passwordIconName: nil, inputPassword: $repeatPassword , passwordLabel: NSLocalizedString("确认密码", comment: ""), isAnimatingNow: $isAnimating, wrongPasswordRedBorder: $wrongRepeatPassword)
                    .offset(y: repeatPasswordFieldOffset)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                            repeatPasswordFieldOffset = 30
                        }
                    }
                
                TextFieldWithIcon(iconName: "envelope.fill", inputText: $email, label: NSLocalizedString("邮箱", comment: ""), isAnimating: $isAnimating, wrongInputRedBorder: $wrongEmail)
                    .padding(.bottom)
                    .offset(y: emailFieldOffset)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                            emailFieldOffset = 30
                        }
                    }
                    .offset(x: wrongEmail != 0 ? (wrongEmail > 0 ? 10 : -10) : 0)
                    .rotationEffect(.degrees(Double(wrongEmail != 0 ? (wrongEmail > 0 ? 5 : -5) : 0)))
                    .animation(.easeInOut(duration: 0.2).repeatCount(2), value: wrongEmail)
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        buttonScale = 0.95
                    }
                    clearErrorMessage()
                    let vertificationResult = registrationVerification(username: username, password: password, repeatPassword: repeatPassword, email: email)
                    sendRegistrationRequest(inputFieldValid: vertificationResult) { success in
                        withAnimation(.easeIn(duration: 0.3)) {
                            buttonScale = 1
                        }
                        if success{
                            registrationSuccess = true
                            showAlert(message: NSLocalizedString("注册成功，请及时完成邮件及统一平台认证", comment: ""))
                        }else{
                            showAlert(message: errors.joined(separator: "\n"))
                        }
                    }
                }) {
                    Text("注册")
                        .fontWeight(.bold)
                }
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
                .opacity(isAnimating ? 0.9 : 0)
                .offset(y: isAnimating ? 0 : 50)
                .animation(.easeOut(duration: 1.2).delay(0.5), value: isAnimating)
                .hoverEffect(.lift)
                .alert(isPresented: $showAlert) {
                    if registrationSuccess {
                        return Alert(
                            title: Text("注册成功，即将返回登录页"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("确定")) {
                                backToLoginPage = true
//                                clearFields()
                            }
                        )
                    } else {
                        return Alert(
                            title: Text("注册失败"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("确定")) {
//                                clearFields()
                            }
                        )
                    }
                }


                NavigationLink(destination: LoginPageView().navigationBarBackButtonHidden(true), isActive: $backToLoginPage) {}
                
                VStack {
                    Text("**[隐私政策](http://leonmmcoset.jjmm.ink:1000/web/bbs/public/p/3-yinsizhengce)**").font(.system(size: 12))
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
        }
    }
    
    // 原有验证和网络请求方法保持不变
    
    private func sendRegistrationRequest(inputFieldValid: Bool, completion: @escaping (Bool) -> Void) {
        if !inputFieldValid {
            completion(false)
        }
        
        guard let url = URL(string: "\(appSettings.FlarumUrl)/api/users") else {
            print("Invalid URL!")
            completion(false)
            return
        }
        
        let parameters: [String: Any] = [
            "data": [
                "attributes": [
                    "username": username,
                    "email": email,
                    "password": password
                ]
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to convert registraton info to JSON!")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(appSettings.FlarumToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(RegistrationResponse.self, from: data)
                    
                    if response.errors == nil{
                        //registration succeeded
                        completion(true)
                    }else{
                        if let errorInfo = response.errors{
                            for errorMessage in errorInfo{
                                self.errors.append(errorMessage.detail)
                            }
                        }
                    }
                    
                    completion(false)
                } catch {
                    print("Error decoding JSON when decoding RegistrationResponse")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }.resume()
    }
    
    
    private func registrationVerification(username: String, password: String, repeatPassword: String, email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isEmailValid = emailPredicate.evaluate(with: email)
        
        errors.removeAll() // 清空旧错误信息
        
        if username.isEmpty {
            errors.append(NSLocalizedString("请输入用户名", comment: ""))
            wrongUsername = 2
        } else {
            wrongUsername = 0
        }
        
        if password.isEmpty {
            errors.append(NSLocalizedString("请输入密码", comment: ""))
            wrongPassword = 2
        } else {
            wrongPassword = 0
            
            if repeatPassword != password {
                errors.append(NSLocalizedString("两次输入的密码不匹配", comment: ""))
                wrongPassword = 2
                wrongRepeatPassword = 2
            } else {
                wrongRepeatPassword = 0
            }
        }
        
        if !isEmailValid {
            errors.append(NSLocalizedString("请输入有效的邮箱地址", comment: ""))
            wrongEmail = 2
        } else {
            wrongEmail = 0
        }
        
        return errors.isEmpty
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func clearErrorMessage(){
        self.errors = []
    }
    
    private func clearFields() {
        username = ""
        displayname = ""
        password = ""
        repeatPassword = ""
        email = ""
        wrongUsername = 0
        wrongDisplayrname = 0
        wrongPassword = 0
        wrongRepeatPassword = 0
        wrongEmail = 0
    }

}

// MARK: - RegistrationResponse
struct RegistrationResponse: Codable {
    let errors: [RegistrationError]?
}

// MARK: - Error
struct RegistrationError: Codable {
    let status, code, detail: String
    let source: RegistrationErrorSource
}

// MARK: - Source
struct RegistrationErrorSource: Codable {
    let pointer: String
}