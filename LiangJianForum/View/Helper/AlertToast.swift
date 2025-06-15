import SwiftUI

public struct AlertToast: View {
    static var tootTitle : String = ""
    static var tootMsg : String = ""

    static func showToast( isShow : inout Bool , _ title : String , _ msg : String = "" ) {
        AlertToast.tootTitle = title
        AlertToast.tootMsg = msg
        isShow = true
    }

    public enum BannerAnimation {
        case slide, pop
    }

    /// Determine how the alert will be display
    public enum DisplayMode: Equatable {
        ///Present at the center of the screen
        case alert
        ///Drop from the top of the screen
        case hud
        ///Banner from the bottom of the view
        case banner(_ transition: BannerAnimation)
    }

    /// Determine what the alert will display
    public enum AlertType: Equatable {
        ///Animated checkmark
        case complete(_ color: Color)
    }
}