import SwiftUI
import AVKit

struct PreviewView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route.PreviewRoute
    let effect: Effect
    @State var player: AVPlayer
    @State var showPaywallToken = false
    @State var showPaywall = false
    
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
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                VStack(spacing: 8) {
                    VideoPlayer(player: player)
                        .disabled(true)
                        .clipShape(.rect(cornerRadius: 8))
                        .onAppear { player.play() }
                        .onDisappear{ player.pause() }
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
                    
                    Button {
                        if effect.id == 81 || effect.id == 86 {
                            router.path.append(nextScreen.photoUploadDouble(effect))
                        } else {
                            router.path.append(nextScreen.photoUpload(effect))
                        }
                    } label: {
                        Text("Create")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: 48)
                            .background(Color.cSecondary)
                            .clipShape(.rect(cornerRadius: 32))
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 27, trailing: 16))
            }
            
        }
        .toolbar(.hidden)
        .onAppear {
            player.play()
        }
        .onDisappear {
            player.pause()
        }
        .fullScreenCover(isPresented: $showPaywallToken) {
            TokensPaywall(show: $showPaywallToken)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
    
    private var header: some View {
        HStack(spacing: 6) {
            Button {
                router.path = NavigationPath()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")//make it button
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.cSecondary)
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
            Text(effect.effect)
                .font(.appFont(.BodyEmphasized))
                .foregroundStyle(.white)
        )
    }
    
}

#Preview {
    PreviewView(effect:
                    Effect(
        id: 1,
        ai: "pv",
        effect: "Popular",
        preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
        previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
    ))
        .environmentObject(EffectsV2Router())
}
