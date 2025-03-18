import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    @Binding var selection: Int
    @State var showPaywall = false
    @State var alertUploaded = false
    @State var alertNotUploaded = false
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Story")
                        .font(.appFont(.Title2Emphasized))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        showPaywall = true
                    } label: {
                        Image("ProButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 82, height: 32)
                    }
                    .disabled(source.proSubscription)
                    .opacity(source.proSubscription ? 0 : 1)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                if source.historyArray.isEmpty {
                    empty
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible(),spacing: 8), GridItem(.flexible())]) {
                            ForEach(source.historyArray, id: \.self) { video in
                                HistoryListCard(video: video)
                                    .clipped()
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .toolbar(.hidden)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
        
    }
    
    private var empty: some View {
        VStack(spacing: 2) {
            Image(systemName: "play.tv.fill")
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(.cSecondary)
                .frame(width: 64, height: 64)
            Text("It's empty here")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Create your first generation")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(.top, 60)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
//
//#Preview {
//    HistoryView(
//        category: Category(
//            header: "CategoryName",
//            items: [
//                Effect(
//                    id: 1,
//                    ai: "pv",
//                    effect: "Popular",
//                    preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
//                    previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
//                )
//            ]
//        )
//    )
//    .padding()
//    .background(Color.black)
//    .environmentObject(EffectsV2Router())
//}
