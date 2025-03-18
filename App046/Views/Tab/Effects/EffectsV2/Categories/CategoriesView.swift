import SwiftUI

struct CategoryListView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreens = EffectsV2Route.CategoryListRoute
    let category: Category
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(category.items, id: \.self) { effect in
                            CategoryListCard(effect: effect)
                                .frame(height: 236)
                        }
                    }
                    .padding(16)
                }
            }
            .frame(maxHeight:.infinity, alignment: .top)
        }
        .toolbar(.hidden)
    }
    
    private var header: some View {
        HStack(spacing: 6) {
            Button {
                router.path = NavigationPath()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")//make it button
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Back")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.cSecondary)
                }
            }
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
        .overlay(
            Text(category.header)
                .font(.appFont(.BodyEmphasized))
                .foregroundStyle(.white)
        )
    }
}

#Preview {
    CategoryListView(
        category: Category(
            header: "CategoryName",
            items: [
                Effect(
                    id: 1,
                    ai: "pv",
                    effect: "Popular",
                    preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
                    previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
                )
            ]
        )
    )
    .padding()
    .background(Color.black)
    .environmentObject(EffectsV2Router())
}
