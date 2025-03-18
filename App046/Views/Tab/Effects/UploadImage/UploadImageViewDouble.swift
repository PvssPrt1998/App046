import SwiftUI
import AVKit

struct UploadImageViewDouble: View {
    
    @EnvironmentObject var source: Source
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route.PreviewRoute.PhotoUploadRoute
    let effect: Effect
    
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    @State var imageMergeAlertShow = false
    
    @State var showCameraPicker = false
    @State var showChoice = false
    @State var showCameraPicker1 = false
    @State var showChoice1 = false
    
    @State private var showingImagePicker = false
    @State private var showingImagePicker1 = false
    @State var inputImage: UIImage?
    @State var inputImage1: UIImage?
    
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
                    HStack(spacing: 8) {
                        imageView
                            .frame(width: (UIScreen.main.bounds.width - 40) / 2, height: 173)
                            .clipped()
                            .clipShape(.rect(cornerRadius: 8))
                        imageView1
                            .frame(width: (UIScreen.main.bounds.width - 40) / 2, height: 173)
                            .clipped()
                            .clipShape(.rect(cornerRadius: 8))
                    }
                    
                    Button {
                        if !source.proSubscription {
                            showPaywall = true
                        } else {
                            if let image1 = inputImage, let image2 = inputImage1, let image = combineImagesWithBlur(image1, image2) {
                                var effect = effect
                                effect.image = image
                                router.path.append(nextScreen.generate(effect))
                            } else {
                                imageMergeAlertShow = true
                            }
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
                    .disabled(inputImage == nil || inputImage1 == nil)
                    .alert("Merge images error", isPresented: $imageMergeAlertShow) {
                        Button("OK", role: .cancel) {imageMergeAlertShow = false}
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 27, trailing: 16))
            }
            .frame(maxHeight: .infinity, alignment:.top)
            
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
        .fullScreenCover(isPresented: $showCameraPicker1) {
            CameraPickerView() { image in
                inputImage1 = image
            }
        }
        .confirmationDialog("Add a photo so we can do a cool effect with it", isPresented: $showChoice1, titleVisibility: .automatic) {
                        Button("Take a photo") {
                            showCameraPicker1 = true
                        }

                        Button("Select from gallery") {
                            showingImagePicker1 = true
                        }
                    }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showingImagePicker1) {
            ImagePicker(image: $inputImage1)
                .ignoresSafeArea()
        }
        .toolbar(.hidden)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
    
    func combineImagesWithBlur(_ leftImage: UIImage, _ rightImage: UIImage) -> UIImage? {
        // Определяем максимальную высоту
        let maxHeight = max(leftImage.size.height, rightImage.size.height)
        
        // Масштабируем обе картинки, чтобы их высота совпадала с maxHeight
        let leftScale = maxHeight / leftImage.size.height
        let rightScale = maxHeight / rightImage.size.height
        
        let scaledLeftWidth = leftImage.size.width * leftScale
        let scaledRightWidth = rightImage.size.width * rightScale
        
        // Общая ширина
        let totalWidth = scaledLeftWidth + scaledRightWidth
        
        // Создаем контекст с нужными размерами
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: maxHeight), false, 0.0)
        
        // Масштабируем и рисуем левое изображение
        let leftRect = CGRect(x: 0, y: 0, width: scaledLeftWidth, height: maxHeight)
        leftImage.draw(in: leftRect)
        
        // Масштабируем и рисуем правое изображение
        let rightRect = CGRect(x: scaledLeftWidth, y: 0, width: scaledRightWidth, height: maxHeight)
        rightImage.draw(in: rightRect)
        
        // Создаем градиент на стыке изображений
        let gradientWidth: CGFloat = 20.0 // Ширина размытия
        let gradientStartX = scaledLeftWidth - gradientWidth / 2
        let gradientEndX = scaledLeftWidth + gradientWidth / 2
        
        if let context = UIGraphicsGetCurrentContext() {
            let colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor
            ]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
            
            let gradientRect = CGRect(x: gradientStartX, y: 0, width: gradientWidth, height: maxHeight)
            context.saveGState()
            context.clip(to: gradientRect)
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: gradientStartX, y: 0),
                end: CGPoint(x: gradientEndX, y: 0),
                options: []
            )
            context.restoreGState()
        }
        
        // Получаем результирующее изображение
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
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
    
    @ViewBuilder var imageView: some View {
        if let inputImage = inputImage {
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: 173)
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
                    ,alignment: .bottomTrailing
                )
                .frame(maxHeight: .infinity, alignment: .center)
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
            .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: 173)
            .background(Color.white.opacity(0.08))
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cSeparator, lineWidth: 1)
            )
            .onTapGesture {
                showChoice = true
            }
        }
    }
    
    @ViewBuilder private var imageView1: some View {
        if let inputImage1 = inputImage1 {
            Image(uiImage: inputImage1)
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: 173)
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    Button {
                        showChoice1 = true
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
                .frame(maxHeight: .infinity, alignment: .center)
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
            .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: 173)
            .background(Color.white.opacity(0.08))
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cSeparator, lineWidth: 1)
            )
            .onTapGesture {
                showChoice1 = true
            }
        }
    }
}

#Preview {
    UploadImageViewDouble(effect:
                    Effect(
        id: 1,
        ai: "pv",
        effect: "Popular",
        preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
        previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
    ))
        .environmentObject(EffectsV2Router())
}
