import SwiftUI

struct Tab: View {
    
    @EnvironmentObject var router: EffectsV2Router
    @EnvironmentObject var source: Source
    @State var selection = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4)]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor.bgSecond
        appearance.shadowColor = .white.withAlphaComponent(0.15)
        appearance.shadowImage = UIImage(named: "tab-shadow")?.withRenderingMode(.alwaysTemplate)
        //UITabBar.appearance().backgroundColor = UIColor.bgSecond
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            tab
                .navigationDestination(for: EffectsV2Route.self) { route in
                    switch route {
                    case .promt(let text): PromtResultView(text: text).environmentObject(router)
                    case .categoryList(let category): CategoryListView(category: category).environmentObject(router)
                    case .preview(let effect): PreviewView(effect: effect).environmentObject(router)
                    case .historyResult(let video): HistoryResult(video: video)
                    }
                }
                .navigationDestination(for: EffectsV2Route.PreviewRoute.self) { route in
                    switch route {
                    case .photoUpload(let effect): UploadImageView(effect: effect)
                    case .photoUploadDouble(let effect): UploadImageViewDouble(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.PreviewRoute.PhotoUploadRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.PreviewRoute.PhotoUploadDoubleRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.self) { route in
                    switch route {
                    case .preview(let effect): PreviewView(effect: effect).environmentObject(router)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.PreviewRoute.self) { route in
                    switch route {
                    case .photoUpload(let effect): UploadImageView(effect: effect)
                    case .photoUploadDouble(let effect): UploadImageViewDouble(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.PreviewRoute.PhotoUploadRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.PreviewRoute.PhotoUploadDoubleRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
        }
    }
    
    private var tab: some View {
        TabView(selection: $selection) {
            EffectsV2View()
                .tabItem { VStack {
                    tabViewImage("video.fill")
                    Text("Video").font(.system(size: 10, weight: .medium))
                } }
                .tag(0)
            PromtView()
                .tabItem { VStack {
                    tabViewImage("wand.and.stars")
                    Text("Promt").font(.system(size: 10, weight: .medium))
                } }
                .tag(1)
            HistoryView(selection: $selection)
                .tabItem { VStack {
                    tabViewImage("book.pages.fill")
                    Text("Story").font(.system(size: 10, weight: .medium))
                } }
                .tag(2)
            SettingsView()
                .tabItem {
                    VStack {
                        tabViewImage("gearshape.fill")
                        Text("Settings") .font(.system(size: 10, weight: .medium))
                    }
                }
                .tag(3)
        }
        
    }
    
//    @ViewBuilder var generateView: some View {
//        switch tabScreen {
//        case .generationChoice:
//            GenerationChoice(screen: $tabScreen)
//        case .videoImageGenerator:
//            VideoImageGenerator(screen: $tabScreen)
//        case .videoResult:
//            GenerationResult(screen: $tabScreen)
//        case .promtResult:
//            PromtGenerationView(screen: $tabScreen)
//        }
//    }
    
    @ViewBuilder func tabViewImage(_ systemName: String) -> some View {
        if #available(iOS 15.0, *) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .environment(\.symbolVariants, .none)
        } else {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
        }
    }
}

struct Tab_Preview: PreviewProvider {

    static var previews: some View {
        Tab()
            .environmentObject(Source())
    }
}

extension UIColor {
   convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {

     let redPart: CGFloat = CGFloat(red) / 255
     let greenPart: CGFloat = CGFloat(green) / 255
     let bluePart: CGFloat = CGFloat(blue) / 255

     self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
   }
}

extension UITabBarController {
    var height: CGFloat {
        return self.tabBar.frame.size.height
    }
    
    var width: CGFloat {
        return self.tabBar.frame.size.width
    }
}
