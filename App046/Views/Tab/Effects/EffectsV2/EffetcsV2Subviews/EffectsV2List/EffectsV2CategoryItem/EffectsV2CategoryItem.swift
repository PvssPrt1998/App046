import SwiftUI

struct EffectsV2CategoryItem: View {
    
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route
    
    let category: Category
    
    var body: some View {
        VStack(spacing: 8) {
            categoryHeader
            effectCards
        }
    }
    
    private var categoryHeader: some View {
        HStack(spacing: 0) {
            Text(category.header)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.textMain)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                router.path.append(nextScreen.categoryList(category))
            } label: {
                Text("See all")
                    .font(.appFont(.FootnoteRegular))
                    .tint(.cSecondary)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(height: 26)
        .padding(.horizontal, 16)
    }
    
    private var effectCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(category.items, id: \.self) { effect in
                    EffectsV2EffectCard(effect: effect)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 248)
    }
}

#Preview {
    EffectsV2CategoryItem(
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
