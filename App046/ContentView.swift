import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var router = EffectsV2Router()
    
    @AppStorage("showOnboarding") var showOnboarding = true
    
    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            Tab()
                .environmentObject(router)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Source())
}
