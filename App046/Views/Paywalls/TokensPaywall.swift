
import SwiftUI
import ApphudSDK

struct TokensPaywall: View {
    
    @Binding var show: Bool
    @Environment(\.openURL) var openURL
    @EnvironmentObject var source: Source
    @State var selectionToken = 0
    
    init(show: Binding<Bool>) {
        self._show = show
    }
    
    var body: some View {
        ZStack {
            Color.bgPaywall.ignoresSafeArea()
            
            Image("PaywallImage")
                .scaledToFit()
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                title
                purposeList
                ScrollView(.vertical) {
                    selection
                }
                .frame(height: 300)
                
                bottomBar
                    .padding(.horizontal, 16)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            
            Button {
                withAnimation {
                    show = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.32))
                    .clipShape(.rect(cornerRadius: 10))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Button {
                source.startPurchase(product:source.purchaseManager.productsApphud1[selectionToken]) { bool in
                    if bool {
//                        self.source.networking.fetchCurrentTokens(apphudId: userID) { tokens in
//                            print("Available tokens \(tokens)")
//                            self.source.tokens = tokens
//                        } errorHandler: {
//                            
//                        }
                    }
                    withAnimation {
                        show = false
                    }
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(.cSecondary)
                    .clipShape(.rect(cornerRadius: 8))
            }
            .padding(.vertical, 2)
            
            HStack(spacing: 12) {
                Button {
                    if let url = URL(string: "https://docs.google.com/document/d/1Bzr1G22pUKtzDY6VxoiaMAHtEqgTSpYbuXhtMZ4I-Cw/edit?usp=sharing") {
                        openURL(url)
                    }
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
                Button {
                    source.restorePurchase { bool in
                        if bool {
                            source.proSubscription = false
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .hidden()
                Spacer()
                Button {
                    if let url = URL(string: "https://docs.google.com/document/d/13JXlS7pZorpyb5H5V6nCiATAVDWDyenf0wSs3KRGQf4/edit?usp=sharing") {
                        openURL(url)
                    }
                } label: {
                    Text("Terms of Use")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 12, trailing: 0))
        }
    }
    
    private var title: some View {
        Text("Out of tokens?")
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
    }
    
    private var selection: some View {
        VStack(spacing: 8) {
            ForEach(0..<source.purchaseManager.productsApphud1.count, id: \.self) { index in
                token(selection: index)
            }
        }
        .padding(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
    }
    
    private var purposeList: some View {
        Text("Top up your balance and keep creating!")
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.white.opacity(0.8))
            .padding(8)
    }
    
    func getTokenAmount(token: ApphudProduct) -> String {
        var amount = token.skProduct?.localizedTitle ?? "Error"
        amount = amount.replacingOccurrences(of: " Tokens", with: "")
        return amount
    }
    
    private func getSubscriptionPrice(for product: ApphudProduct) -> Double {
        if let price = product.skProduct?.price {
            return Double(truncating: price).roundToPlaces(2)
        } else {
            return 0
        }
    }
    
    private func token(selection: Int) -> some View {
        HStack {
            HStack(spacing: 4) {
                Text(getTokenAmount(token: source.purchaseManager.productsApphud1[selection]))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60)
                Text("Tokens")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(getSubscriptionPrice(for: source.purchaseManager.productsApphud1[selection]))" + source.purchaseManager.returnPriceSign(product: source.purchaseManager.productsApphud1[selection]))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color.bgLight)
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(self.selectionToken == selection ? Color.cSecondary : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            self.selectionToken = selection
        }
    }
}

#Preview {
    //PaywallView()
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    func cutOffDecimalsAfter(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self*divisor).rounded(.towardZero) / divisor
    }
}
