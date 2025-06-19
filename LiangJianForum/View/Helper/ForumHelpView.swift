import SwiftUI

struct FlarumHelpView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationView {
                        VStack {
                
                List {
                    ForEach(searchResults, id: \.self) {
 item in
                        switch item {
                        case "忘记密码如何找回？":
                            NavigationLink(destination: Text("若忘记密码，可在账号登录页面点击“忘记密码”，输入可能注册过的账号，获取验证码后设定新密码。也能尝试使用第三方快捷登录验证。")) {
                                Text(item)
                            }
                        case "登录论坛的方法有哪些？":
                            NavigationLink(destination: Text("可通过 PC 端在论坛首页或官网右上角点击“登录”，输入手机号和密码登录；手机端可在浏览器搜索论坛进入登录页面登录。部分平台还支持第三方快捷登录。")) {
                                Text(item)
                            }
                        case "论坛有哪些功能？":
                            NavigationLink(destination: Text("论坛支持密码和网页登录，可管理多个论坛和账户。有热点话题更新功能，能按标签、类别等过滤排序内容，支持快速回复和富文本发帖，还支持内嵌图像渲染和数据保护模式。")) {
                                Text(item)
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
            }
           .searchable(text: $searchText, prompt: "搜索问题")
           .listStyle(.automatic)
           .navigationTitle("论坛帮助文档")
        }
    }

    private var allQuestions = ["忘记密码如何找回？", "登录论坛的方法有哪些？", "论坛有哪些功能？"]

    private var searchResults: [String] {
        if searchText.isEmpty {
            return allQuestions
        } else {
            return allQuestions.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    
}

struct FlarumHelpView_Previews: PreviewProvider {
    static var previews: some View {
        FlarumHelpView()
    }
}
