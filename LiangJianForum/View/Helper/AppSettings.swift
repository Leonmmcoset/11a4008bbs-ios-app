//
//  AppSettings.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/28.
//

import Foundation
import SwiftUI

enum ThemeMode: String, CaseIterable {
    case system
    case light
    case dark
}

class AppSettings: ObservableObject {
    @Published var isAutoCheckUpdate = true // 自动检查更新开关，默认开启
    @Published var themeMode: ThemeMode = .system // 暗黑模式设置
    @Published var completedVotes: [Int: [String]] = [:]
    @Published var refreshPostView = false
    @Published var refreshReplyView = false
    @Published var refreshProfileView = false
    @Published var isLoggedIn = true
    @Published var isAdmin = false
    @Published var isVIP = false
//    @Published var FlarumUrl = "http://leonmmcoset.jjmm.ink:1000/web/bbs/public/"
    @Published var FlarumUrl = "https://11a.arw.pub/"
    @Published var FlarumName = NSLocalizedString("LeonMMcoset论坛", comment: "")
//    @Published var FlarumToken = "zak7BvaaraQfAhni4uO5ngAPkT0THF94d6GlDCcF"//Your flarum API key, used in regisgration
    @Published var FlarumToken = "pj4hguy4H0J1lwEMyaKrIyOJUfFr32Sdx9hGoDmq"
    @Published var token = ""
    @Published var username = ""
    @Published var displayName = ""
    @Published var avatarUrl = ""
    @Published var identification = ""
    @Published var password = ""
    @Published var joinTime = ""
    @Published var lastSeenAt = ""
    @Published var cover = ""
    @Published var discussionCount = 0
    @Published var commentCount = 0
    @Published var userId = 0
    @Published var userExp = 0
    @Published var vipUsernames: [String] = []
    @Published var canCheckIn = false
    @Published var canCheckinContinuous = false
    @Published var totalContinuousCheckIn = 0
    private var timer: Timer?
    private let themeKey = "ThemeMode"

    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = ThemeMode(rawValue: savedTheme) {
            self.themeMode = theme
        }
        vipUsernames.append(contentsOf: ["Your username"])
    }

    func saveThemeSettings() {
        UserDefaults.standard.set(themeMode.rawValue, forKey: themeKey)
    }
    
    func refreshPost() {
        refreshPostView.toggle()
    }
    
    func refreshComment() {
        refreshReplyView.toggle()
    }
    func refreshProfile() {
        refreshProfileView.toggle()
    }
    
    func startTimer() {
        print("Timer Start")
        //cookie will expire
        timer = Timer.scheduledTimer(withTimeInterval: 55 * 60, repeats: false) { [weak self] _ in
            print("Time out")
            self?.isLoggedIn = false
        }
    }

    func resetTimer() {
        // Reset the timer
        timer?.invalidate()
        startTimer()
    }
    
    func stopTimer() {
        // Stop the timer
        timer?.invalidate()
    }
    @Published var hasCancelledUpdate = false // 记录是否曾取消更新
}

extension String{
var htmlConvertedString : String{
    let string = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    return string
}}

extension String {
    var htmlConvertedWithoutUrl: String {
        // Remove the specific content
        let contentToRemove = "\n                    if(window.hljsLoader && !document.currentScript.parentNode.hasAttribute('data-s9e-livepreview-onupdate')) {\n                        window.hljsLoader.highlightBlocks(document.currentScript.parentNode);\n                    }\n                "
        var stringWithoutContent = self.replacingOccurrences(of: contentToRemove, with: "")
        
        // Remove JavaScript code
        stringWithoutContent = stringWithoutContent.replacingOccurrences(of: "<script[^>]*?>.*?</script>", with: "", options: .regularExpression, range: nil)
        
        // Remove HTML tags
        let htmlRemovedString = stringWithoutContent.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        // Preserve Markdown code
        let markdownPreservedString = htmlRemovedString.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression, range: nil)
        
        return markdownPreservedString
    }
}





func extractImageURLs(from htmlString: String) -> [String]? {
    var imageURLs: [String] = []
    
    let pattern = "<img[^>]+src\\s*=\\s*\"([^\"]+)\"[^>]*>"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count))
    
    for match in matches {
        let range = match.range(at: 1)
        if let urlRange = Range(range, in: htmlString) {
            let url = String(htmlString[urlRange])
            imageURLs.append(url)
        }
    }
    
    return imageURLs
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, opacity: 1.0)
    }
}

func formatIconString(_ input: String?) -> String? {
    guard let input = input else {
        return nil
    }
    
    var formattedString = ""
    var capitalizeNext = true
    
    for char in input {
        if char == "-" {
            capitalizeNext = true
        } else {
            if capitalizeNext {
                formattedString.append(char.uppercased())
                capitalizeNext = false
            } else {
                formattedString.append(char)
            }
        }
    }

    if let firstChar = formattedString.first {
        formattedString = String(firstChar.lowercased()) + formattedString.suffix(from: formattedString.index(after: formattedString.startIndex))
    }
    
    return formattedString
}


func getIconNameFromFetching(from inputString: String?) -> String? {
    if let input = inputString{
        do {
            let regex = try NSRegularExpression(pattern: "fas fa-(\\w+[-\\w]*)")
            let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
            
            if let match = matches.first, match.numberOfRanges >= 2 {
                let range = match.range(at: 1)
                if let swiftRange = Range(range, in: input) {
                    return String(input[swiftRange])
                }
            }
        } catch {
            print("regex error：\(error)")
            // 可以添加更多错误处理逻辑，如显示提示框给用户
            // showAlert(message: "正则表达式处理失败，请检查输入")
        }
    }

    return nil
}


