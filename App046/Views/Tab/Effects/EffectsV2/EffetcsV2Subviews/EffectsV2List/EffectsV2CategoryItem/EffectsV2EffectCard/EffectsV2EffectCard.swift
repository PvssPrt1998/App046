import SwiftUI
import AVKit

struct EffectsV2EffectCard: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route
    
    @State var player: AVPlayer
    @State var effect: Effect
    
    init(effect: Effect) {
        self.effect = effect
        if let localUrlStr = effect.localUrl, let url = URL(string: localUrlStr) {
            //print("Load local")
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else if let urlStr = effect.previewSmall, let url = URL(string: urlStr) {
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else {
            self.player = AVPlayer()
        }
    }
    
    var body: some View {
        Button {
            router.path.append(nextScreen.preview(effect))
        } label: {
            content
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                player.play()
            }
        }
        .onDisappear {
            self.player.pause()
        }
//        .onReceive(source.categoriesArrayChangedPublisher) {_ in
//            if let categoryIndex = source.categoriesArray.firstIndex(where: {$0.items.contains(where: {$0.id == effect.id})}),
//               let index = source.categoriesArray[categoryIndex].items.firstIndex(where: {$0.id == effect.id}) {
//                if effect.localUrl != source.categoriesArray[categoryIndex].items[index].localUrl {
//                    effect.localUrl = source.categoriesArray[categoryIndex].items[index].localUrl
//                }
//            }
//        }
    }
    
    @ViewBuilder private var content: some View {
        VStack(spacing: 14) {
            videoPreview
            effectHeader
        }
        .frame(width: 163)
    }
    
    private var effectHeader: some View {
        Text(effect.effect)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
    }
    
     private var videoPreview: some View {
         VideoPlayer(player: player)
             .disabled(true)
             .frame(width: 163 * 16 / 9, height: 204 * 16 / 9)
             .frame(width: 163, height: 204)
             .clipShape(.rect(cornerRadius: 16))
             .clipped()
             .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
             )
             .onReceive(NotificationCenter
                 .default
                 .publisher(
                     for: .AVPlayerItemDidPlayToEndTime,
                     object: player.currentItem),
                        perform: { _ in
                             player.seek(to: .zero)
                             player.play()
                         }
             )
    }
    
    private func setupPlayer() {
        if let urlStr = effect.previewSmall, let url = URL(string: urlStr) {
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else {
            self.player = AVPlayer()
        }
    }
}

#Preview {
    EffectsV2EffectCard(
        effect: Effect(
            id: 1,
            ai: "pv",
            effect: "Popular",
            preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
            previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
        )
    )
    .padding()
    .background(Color.black)
    .environmentObject(EffectsV2Router())
    .environmentObject(Source())
}
