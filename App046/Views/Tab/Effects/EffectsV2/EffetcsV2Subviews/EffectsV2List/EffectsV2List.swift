import SwiftUI
import Combine

struct EffectsV2List: View {
    
    @EnvironmentObject var source: Source
    
    @State var categories: Array<Category>
    
    init(categories: Array<Category>) {
        self.categories = categories
    }
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(source.categoriesArray, id: \.self) { category in
                        EffectsV2CategoryItem(category: category)
                    }
                }
                .padding(.vertical, 5)
            }
        }
//        .onReceive(source.categoriesArrayChangedPublisher) {_ in 
//            categories = source.categoriesArray
//        }
    }
}

#Preview {
    EffectsV2List(categories: [])
        .environmentObject(Source())
}
