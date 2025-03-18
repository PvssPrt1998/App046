import SwiftUI

struct EffectsV2View: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    
    @State var showPro = true
    @State var showPaywall = false
    
    private var header: some View {
        HStack(spacing: 6) {
            Text("Video")
                .font(.appFont(.Title2Emphasized))
                .foregroundStyle(.white)
            Spacer()
            Button {
                showPaywall = true
            } label: {
                Image("ProButton")//make it button
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 32)
            }
            
                .disabled(source.proSubscription == true)
                .opacity(source.proSubscription ? 0 : 1)
            
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
    
    var body: some View {
        ZStack {
            Color.bgSecond.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Video")
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
                    .disabled(source.proSubscription == true)
                    .opacity(source.proSubscription ? 0 : 1)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Color.bgSecond)
                EffectsV2List(categories: source.categoriesArray)
            }
        }
        
        .toolbar(.hidden)
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(show: $showPaywall)
            }
            .onAppear {
                if showPro != source.proSubscription {
                    showPro = source.proSubscription
                }
            }
    }
}

#Preview {
    EffectsV2View()
        .environmentObject(Source())
        .environmentObject(EffectsV2Router())
}
