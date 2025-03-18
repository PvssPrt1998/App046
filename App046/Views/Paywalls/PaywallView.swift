
import SwiftUI
import ApphudSDK

struct PaywallView: View {
    
    @Binding var show: Bool
    @Environment(\.openURL) var openURL
    @EnvironmentObject var source: Source
    @State var isYear = true
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            Image("PaywallImage")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                
                title
                    .padding(.horizontal, 16)
                purposeList
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 0) {
                    LinearGradient(colors: [.bgMain.opacity(0), .bgMain], startPoint: .top, endPoint: .bottom)
                        .frame(height: 30)
                    selection
                        .background(Color.bgMain)
                    bottomBar
                        .padding(.horizontal, 16)
                        .background(Color.bgMain)
                }
                
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Button {
                source.startPurchase(product: isYear ? source.purchaseManager.productsApphud[1] : source.purchaseManager.productsApphud[0]) { bool in
                    if bool {
                        print("Subscription purchased")
                        source.proSubscription = true
                    }
                    withAnimation {
                        show = false
                    }
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(.cSecondary)
                    .clipShape(.rect(cornerRadius: 32))
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
                            show = false
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
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
        Text("Unreal videos with PRO")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var selection: some View {
        VStack(spacing: 8) {
            yearly
            week
        }
        .padding(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
    }
    
    private var emptyCircle: some View {
        Image(systemName: "circle")
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(Color.white.opacity(0.28))
    }
    
    private var fillCircle: some View {
        Image(systemName: "circle")
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(Color.white)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .padding(3)
            )
    }
    
    @ViewBuilder private var yearly: some View {
        HStack {
            if isYear {
                fillCircle
            } else {
                emptyCircle
            }
            
            VStack(spacing: 2) {
                Text(source.purchaseManager.returnName(product: source.purchaseManager.productsApphud[0]))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(source.purchaseManager.returnPriceSign(product: source.purchaseManager.productsApphud[0]) + source.purchaseManager.returnPrice(product: source.purchaseManager.productsApphud[1]))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Save 40%")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 21)
                    .background(Color.cSecondary)
                    .clipShape(.rect(cornerRadius: 8))
                
                Text("\(source.purchaseManager.returnPriceSign(product: source.purchaseManager.productsApphud[0]))" + "\(Double(String(format: "%.2f", getSubscriptionPrice(for: source.purchaseManager.productsApphud[0]) / 52)) ?? 0.0)" + "/per week")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
        }
        .frame(height: 71)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.08))
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isYear ? Color.accentSecondary : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            isYear = true
        }
    }
                     
     private func getSubscriptionPrice(for product: ApphudProduct) -> Double {
         if let price = product.skProduct?.price {
             return Double(truncating: price)
         } else {
             return 0
         }
     }
    
    private var purposeList: some View {
        HStack(spacing: 8) {
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.cSecondary)
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.cSecondary)
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.cSecondary)
            }
            VStack(alignment: .leading, spacing: 16) {
                Text("Access to all effects")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Unlimited generation")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Access to all functions")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
    
    @ViewBuilder private var week: some View {
        HStack {
            if !isYear {
                fillCircle
            } else {
                emptyCircle
            }
            Text(source.purchaseManager.returnName(product: source.purchaseManager.productsApphud[1]))
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(source.purchaseManager.returnPriceSign(product: source.purchaseManager.productsApphud[1]) + source.purchaseManager.returnPrice(product: source.purchaseManager.productsApphud[1]) + " per week")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .frame(height: 71)
        .background(Color.white.opacity(0.08))
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(!isYear ? Color.accentSecondary : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            isYear = false
        }
    }
}

struct PaywallView_Preview: PreviewProvider {
    
    @State static var show = true
    
    static var previews: some View {
        PaywallView(show: $show)
            .environmentObject(Source())
    }
}
