import SwiftUI
import _AVKit_SwiftUI
import Photos

struct HistoryResult: View {
    
    let documentManager = DocumentManager()
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    @State var showActionSheetGenerated = false
    let video: Video
    @State var player = AVPlayer()
    
    @State var alertUploaded = false
    @State var alertNotUploaded = false
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                
                contentView
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            load()
        }
        .toolbar(.hidden)
        .frame(maxHeight: .infinity)
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
        .confirmationDialog("", isPresented: $showActionSheetGenerated, titleVisibility: .hidden) {
                        Button("Download") {
                            downloadVideo()
                            showActionSheetGenerated = false
                        }

                        Button("Share") {
                            share()
                            showActionSheetGenerated = false
                        }

                        Button("Delete", role: .destructive) {
                            delete()
                            showActionSheetGenerated = false
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
            Menu {
                Button("Share", action: share)
            } label: {
//                Label("", systemImage: "ellipsis")
//                    .labelsHidden()
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.cSecondary)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .overlay(
            Text("Result")
                .font(.appFont(.BodyEmphasized))
                .foregroundStyle(.white)
        )
    }
    
    func load() {
        if let localUrlStr = fetchVideoFromDocuments(filename: video.id + ".mp4"), let url = URL(string: localUrlStr), let urlData = NSData(contentsOf: url)  {
            //print("Load local")
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else if let urlStr = video.url, let url = URL(string: urlStr) {
            reloadInDocuments()
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else {
            self.player = AVPlayer()
        }
    }
    
    func reloadInDocuments() {
        print("Handle unable local load")
        self.documentManager.removeVideoBy(filename: video.id + ".mp4")//Remove old From DOC
        guard let urlStr = video.url else { return }
        self.documentManager.downloadVideoGenerated(urlStr: urlStr, id: video.id) { str in
            print("SAVED TO LOCAL URL History: " + str)
        }
    }
    
    func fetchVideoFromDocuments(filename: String) -> String? {
        //guard let url: NSURL = NSURL(string: urlStr), let filename = url.lastPathComponent else { return nil }
        let newPath = "file:///" + documentsPathForFileName(name: "/" + filename)
        return newPath
    }
    
    func documentsPathForFileName(name: String) -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return documentsPath.appending(name)
    }
    
    private func delete() {
        source.removeVideo(id: video.id)
    }
    
    private var contentView: some View {
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
    
    private func share() {
        guard let urlStr = video.url,let urlShare = URL(string: urlStr)  else { return }
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
        // Убедимся, что URL корректный
        guard let videoUrlString = video.url, let videoUrl = URL(string: videoUrlString) else {
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
    
    
}
