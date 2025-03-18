import SwiftUI

final class EffectsV2Router: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
}
