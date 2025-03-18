import SwiftUI
import StoreKit

struct OnboardingView: View {
    @State var selection = 0
    //@Environment(\.safeAreaInsets) private var safeAreaInsets
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            TabView(selection: $selection) {
                onboardingImage("onboarding1")
                    .tag(0)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding2")
                    .tag(1)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding3")
                    .tag(2)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding4")
                    .tag(3)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding5")
                    .tag(4)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            .gesture(DragGesture())
            .overlay(
                VStack(spacing: 0) {
                    Text(titleForSelection)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16))
                    
                    VStack(spacing: 16) {
                        
                            Button {
                                if selection == 4 {
                                    withAnimation {
                                        showOnboarding = false
                                    }
                                } else {
                                    if selection == 3 {
                                        SKStoreReviewController.requestReviewInCurrentScene()
                                    }
                                    withAnimation {
                                        selection += 1
                                    }
                                }
                            } label: {
                                Text("Next")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.cSecondary)
                                    .clipShape(.rect(cornerRadius: 32))
                            }
                            .padding(.horizontal, 16)
                        
                        indicators
                        
                    }
                }
                
                ,alignment: .bottom
            )
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    private func onboardingImage(_ title: String) -> some View {
        Image(title)
            .resizable()
            .scaledToFit()
            //.padding(EdgeInsets(top: 0, leading: 16, bottom: 250, trailing: 16))
            .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var indicators: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(selection == 0 ? Color.white : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 1 ? Color.white : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 2 ? Color.white : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 3 ? Color.white : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 4 ? Color.white : Color.white.opacity(0.2))
        }
        .frame(height: 8)
    }
    
    private var titleForSelection: String {
        switch selection {
        case 0: return "Kiss and Hug AI effects"
        case 1: return "Text to Video AI Generator"
        case 2: return "Muscle Surge AI"
        case 3: return "Rate our app in the AppStore"
        case 4: return "Don't miss new trends"
        default: return "Don't miss new trends ⭐"
        }
    }
}
