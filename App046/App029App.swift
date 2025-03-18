import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

var userID = ""

@main
struct App029App: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Source())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Apphud.start(apiKey: "app_n9sweReqv86URTwoNh2kmdqYsSH1ET")
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
        userID = Apphud.userID()
        fetchIDFA()
        return true
    }
    
    func fetchIDFA() {
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    guard status == .authorized else { return }
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                    userID = Apphud.userID()
                }
            }
        }
    }
}
