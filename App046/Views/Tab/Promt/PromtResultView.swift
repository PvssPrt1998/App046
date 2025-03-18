import SwiftUI
import StoreKit
import Lottie
import Photos
import AVKit

struct PromtResultView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @State var alertUploaded = false
    @State var alertNotUploaded = false
    
    @State var showActionSheetGenerating = false
    @State var showActionSheetGenerated = false
    
    @ObservedObject var generationViewHelper = GenerationViewHelper()
    @State var generating = true
    @State var player = AVPlayer()
    let text: String
    
    @State var videoGenerationErrorAlertShow = false
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                if generating {
                    generatingView
                } else {
                    resultView
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
        }
        .onAppear {
            if !generationViewHelper.onAppearCalled {
                generationViewHelper.onAppearCalled = true
                let defaults = UserDefaults.standard
                defaults.set(25, forKey: "Age")
                send()
            }
        }
        .toolbar(.hidden)
        .alert("Video generation error", isPresented: $videoGenerationErrorAlertShow) {
            Button("Cancel", role: .cancel) {
//                while router.path.count > 0 {
//                    router.path.removeLast()
//                }
                videoGenerationErrorAlertShow = false
                router.path = NavigationPath()
            }
            Button("Try again", role: .none) {
                videoGenerationErrorAlertShow = false
                send()
            }
        } message: {
            Text("Something went wrong or the server is not responding. Try again or do it later.")
        }
        .alert("Success", isPresented: $alertUploaded) {
            Button("OK", role: .cancel) {alertUploaded = false}
        } message: {
            Text("Video uploaded to gallery")
        }
        .alert("Error", isPresented: $alertNotUploaded) {
            Button("OK", role: .cancel) {alertNotUploaded = false}
            Button("Try again", role: .none) {
                self.downloadVideo()
                alertNotUploaded = false
            }
        } message: {
            Text("Video upload error")
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
            Menu {
                Button("Share", action: share)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.cSecondary)
            }
            .disabled(source.generationIdForDelete == nil)
            .opacity(source.generationIdForDelete == nil ? 0.3 : 1)
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .overlay(
            Text(generating ? "Generation" : "Result")
                .font(.appFont(.BodyEmphasized))
                .foregroundStyle(.white)
        )
    }
    
    func send() {
        source.createVideoText(text: text) { generationID in
            self.source.generationIdForDelete = generationID
            print("CreateVideo.generation id: " + generationID)
            self.checkVideoStatus(generationID) { status in
                print("ALL DONE GENERATION " + status)
                if status == "finished" {
//                    source.networking.getVideoURLSora(idVideo: generationID) { url in
//                        source.genIDArr.remove(generationID)
//                        print("Save completed from generate")
//                        source.saveCompletedVideo(generationID, status: status, url: url)
//                        self.prepareForShowVideo(urlStr: url)
//                    }
                    source.networking.videoById(id: generationID) { url in
                        source.genIDArr.remove(generationID)
                        print("Save completed from generate")
                        source.saveCompletedVideo(generationID, status: status, url: url.absoluteString)
                        self.prepareForShowVideo(urlStr: url.absoluteString)
                    } errorHandler: {
                        showErrorAlert()
                    }
                }
            } errorHandler: {
                showErrorAlert()
            }
        } errorHandler: {
            showErrorAlert()
        }
    }
    
    private func share() {
        guard let id = source.generationIdForDelete, let index = source.historyArray.firstIndex(where: {$0.id == id}) else { return }
        guard let urlStr = source.historyArray[index].url ,let urlShare = URL(string: urlStr)  else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        if #available(iOS 15.0, *) {
            UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController?
            .present(activityVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func downloadVideo() {
        guard let id = source.generationIdForDelete, let index = source.historyArray.firstIndex(where: {$0.id == id}) else { return }
        // Убедимся, что URL корректный
        guard let videoUrlString = source.historyArray[index].url, let videoUrl = URL(string: videoUrlString) else {
            print("Invalid video URL")
            return
        }
        
        // Скачиваем видео во временную директорию
        let tempFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedVideo.mp4")
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: videoUrl) { location, response, error in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                return
            }
            
            guard let location = location else {
                print("No file location")
                return
            }
            
            do {
                // Удаляем старый файл, если он существует
                if FileManager.default.fileExists(atPath: tempFilePath.path) {
                    try FileManager.default.removeItem(at: tempFilePath)
                }
                
                // Перемещаем загруженный файл во временную директорию с расширением .mp4
                try FileManager.default.moveItem(at: location, to: tempFilePath)
                
                // Сохраняем видео в галерею
                self.saveVideoToGallery(tempFilePath)
            } catch {
                print("Error handling file: \(error.localizedDescription)")
            }
        }
        
        downloadTask.resume()
    }

    private func saveVideoToGallery(_ fileUrl: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: fileUrl, options: nil)
        }) { success, error in
            // Используем self, чтобы предотвратить утечку памяти
            DispatchQueue.main.async {
                if success {
                    alertUploaded = true
                    print("Video saved to gallery successfully")
                } else if let error = error {
                    alertNotUploaded = true
                    print("Error saving video: \(error.localizedDescription)")
                } else {
                    alertNotUploaded = true
                    print("Unknown error occurred while saving video")
                }
            }
        }
    }
    
    func checkVideoStatus(_ generationID: String, completion: @escaping (String) -> Void, errorHandler: @escaping () -> Void) {
        self.source.genIDArr.insert(generationID)
        self.source.videoStatusText(generationID: generationID) { status in
            self.source.savePendingVideo(generationID, status: status, effect: "", image: Data())
            print(status)
            if status == "finished" {
                completion(status)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    checkVideoStatus(generationID) { status in
                        completion(status)
                    } errorHandler: {
                        errorHandler()
                    }
                }
            }
        } errorHandler: {
            errorHandler()
        }
    }
    
    func prepareForShowVideo(urlStr: String) {
        if let url = URL(string: urlStr) {
            print("GENERATED VIDEO URL" + urlStr)
            let player = AVPlayer(url: url)
            player.play()
            self.player = player
            self.generating = false
            //VIDEO_SAVE
        } else {
            //change status video to error VIDEO_ERROR
            showErrorAlert()
        }
    }
    
    func showErrorAlert() {
        videoGenerationErrorAlertShow = true
    }
    
    private var resultView: some View {
        VStack(spacing: 24) {
            VideoPlayer(player: player)
                .disabled(true)
                .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - 115)
                .clipShape(.rect(cornerRadius: 8))
                .clipped()
                .onAppear { player.play() }
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
                downloadVideo()
            } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: 48)
                    .background(Color.cSecondary)
                    .clipShape(.rect(cornerRadius: 32))
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
    }
    
    func requestReview() {
        if let numb = UserDefaults.standard.object(forKey: "Gen") as? Int {
            var a = numb + 1
            if a == 3 || a == 5 || a == 10 {
                SKStoreReviewController.requestReviewInCurrentScene()
            }
        } else {
            UserDefaults.standard.set(1, forKey: "Gen")
        }
    }
    
    private var generatingView: some View {
        VStack(spacing: 4) {
            LottieView(animation: .named("load2"))
                .playing()
                .looping()
                .frame(width: 250, height: 250)
            Text("Creating a video")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.white)
            Text("Wait a bit, the video will be ready soon")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.labelsSecondary)
        }
    }
}
