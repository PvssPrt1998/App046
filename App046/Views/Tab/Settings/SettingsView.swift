import SwiftUI
import StoreKit


struct SettingsView: View {
    
    @EnvironmentObject var source: Source
    @Environment(\.openURL) var openURL
    @State var tokens = 0
    
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    var body: some View {
        ZStack {
            Color
                .bgSecond
                .ignoresSafeArea()
            VStack(spacing: 0) {
                header
                    .background(Color.bgSecond)
                
                content
                    .background(Color.bgMain)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
    
    private var header: some View {
        HStack {
            Text("Settings")
                .font(.appFont(.Title2Emphasized))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                showPaywall = true
            } label: {
                Image("ProButton")//make it button
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 32)
            }
            .disabled(source.proSubscription)
            .opacity(source.proSubscription ? 0 : 1)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
    
    private var content: some View {
        VStack(spacing: 28) {
            supportUs
            purchasesAndActions
            infoAndLegal
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment:. top)
    }
    
    private var supportUs: some View {
        VStack(spacing: 8) {
            Text("Support us")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                SKStoreReviewController.requestReviewInCurrentScene()
            } label: {
                button(imageTitle: "star", title: "Rate app")
            }
            Button {
                 share()
            } label: {
                button(imageTitle: "square.and.arrow.up", title: "Share with friends")
            }
        }
    }
    
    private var purchasesAndActions: some View {
        VStack(spacing: 8) {
            Text("Purchases & actions")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                showPaywall = true
            } label: {
                button(imageTitle: "sparkles", title: "Upgrade plan")
            }
            Button {
                source.restorePurchase { bool in
                    source.proSubscription = false
                }
            } label: {
                button(imageTitle: "arrow.counterclockwise.icloud", title: "Restore purchases")
            }
        }
    }
    
    private var infoAndLegal: some View {
        VStack(spacing: 8) {
            Text("Info & legal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSd1OW3z5XvJJDVoMzjjMA-yw7BfVx_eW33ZoZpO9_c6i01e6g/viewform?usp=dialog") {
                    openURL(url)
                }
            } label: {
                button(imageTitle: "text.bubble", title: "Contact us")
            }
            Button {
                if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSd1OW3z5XvJJDVoMzjjMA-yw7BfVx_eW33ZoZpO9_c6i01e6g/viewform?usp=dialog") {
                    openURL(url)
                }
            } label: {
                button(imageTitle: "folder.badge.person.crop", title: "Privacy Policy")
            }
            Button {
                if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSd1OW3z5XvJJDVoMzjjMA-yw7BfVx_eW33ZoZpO9_c6i01e6g/viewform?usp=dialog") {
                    openURL(url)
                }
            } label: {
                button(imageTitle: "doc.text", title: "Usage Policy")
            }
        }
    }
    
    func share() {
        let urlStr = "https://apps.apple.com/app/id6739883934"
        guard let urlShare = URL(string: urlStr)  else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        if #available(iOS 15.0, *) {
            UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController?
            .present(activityVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func button(imageTitle: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: imageTitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.white.opacity(0.14))
        .clipShape(.rect(cornerRadius: 24))
    }
    
}
