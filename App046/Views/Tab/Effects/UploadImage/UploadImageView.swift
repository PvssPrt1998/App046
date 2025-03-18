import SwiftUI
import AVKit

struct UploadImageView: View {
    
    @EnvironmentObject var source: Source
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route.PreviewRoute.PhotoUploadRoute
    let effect: Effect
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    @State var showChoice = false
    @State var showCameraPicker = false
    
    @State private var showingImagePicker = false
    @State var inputImage: UIImage?
    
    @State var player: AVPlayer
    
    init(effect: Effect) {
        self.effect = effect
        
        if let localUrlStr = effect.localUrl, let url = URL(string: localUrlStr) {
           // print("Load local Preview from category")
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
                        .frame(maxHeight: .infinity)
                    
                    imageView
                        .frame(width: UIScreen.main.bounds.width - 32, height: 173)
                        .clipped()
                        .clipShape(.rect(cornerRadius: 8))
                    Button {
                        if !source.proSubscription {
                            showPaywall = true
                            print("SCOW PAYWALL")
                        } else {
                            var effect = effect
                            effect.image = inputImage
                            router.path.append(nextScreen.generate(effect))
                        }
                    } label: {
                        Text("Generate video")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: 48)
                            .background(inputImage == nil ? Color.accentGray : Color.cSecondary)
                            .clipShape(.rect(cornerRadius: 32))
                    }
                    .disabled(inputImage == nil)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 27, trailing: 16))
            }
            .frame(maxHeight: .infinity, alignment:.top)
            

        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraPickerView() { image in
                inputImage = image
            }
        }
        .confirmationDialog("Add a photo so we can do a cool effect with it", isPresented: $showChoice, titleVisibility: .automatic) {
                        Button("Take a photo") {
                            showCameraPicker = true
                        }

                        Button("Select from gallery") {
                            showingImagePicker = true
                        }
                    }
        .toolbar(.hidden)
        .onAppear {
            player.play()
        }
        .onDisappear {
            player.pause()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
    
    @ViewBuilder var imageView: some View {
        if let inputImage = inputImage {
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width - 32, height: 173)
                .clipped()
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    Button {
                        showChoice = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.textMain)
                            Text("Change")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.textMain)
                        }
                        .frame(width: 83, height: 32)
                        .background(Color.black.opacity(0.4))
                        .clipShape(.rect(cornerRadius: 4))
                    }
                    .padding(8)
                    //.frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    ,alignment: .bottomTrailing
                )
                
        } else {
            VStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.textMain)
                    .frame(width: 32, height: 32)
                Text("Upload image")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.textMain)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cSeparator, lineWidth: 1)
            )
            .onTapGesture {
                showChoice = true
            }
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
    UploadImageView(effect:
                    Effect(
        id: 1,
        ai: "pv",
        effect: "Popular",
        preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
        previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
    ))
        .environmentObject(EffectsV2Router())
}
