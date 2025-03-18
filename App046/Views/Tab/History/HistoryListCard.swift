import SwiftUI
import Photos
import AVKit

struct HistoryListCard: View {
    
    @ObservedObject var doubleLoadHelper = DoubleLoadHelper()
    let documentManager = DocumentManager()
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    @State var alertUploaded = false
    @State var alertNotUploaded = false
    
    enum GenerationState {
        case pending
        case completed
        case error
    }
    
    @State var generationState: GenerationState
    
    @State var player: AVPlayer
    @State var video: Video
    
    init(video: Video) {
        print(video)
        self.video = video
        if video.status == "finished" {
            generationState = .completed
        } else if video.status == "error" {
            generationState = .error
        } else {
            generationState = .pending
        }
        player = AVPlayer()
    }
    
    func load() {
        if video.status != "error"{
            if video.status != "finished" {
                if !source.genIDArr.contains(video.id) {
                    self.checkVideoStatus(video.id) { status, url in
                        self.generationState = .completed
                        if let index = source.historyArray.firstIndex(where: {$0.id == video.id}) {
                            source.historyArray[index].status = status
                            source.historyArray[index].url = url
                        }
                        
                    } errorHandler: {
                        self.generationState = .error
                    }
                }
            } else {
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
    
    var body: some View {
        bodyContent
            .clipShape(.rect(cornerRadius: 8))
            .onAppear {
                if !doubleLoadHelper.loaded {
                    doubleLoadHelper.loaded = true
                    load()
                }
                player.play()
            }
            .onDisappear {
                player.pause()
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
            .contextMenu {
                    Button {
                        downloadVideo()
                    } label: {
                        Label("Save to gallery", systemImage: "arrow.down.to.line")
                    }

                    Button {
                        source.removeVideo(id: video.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
    }
    
    @ViewBuilder var bodyContent: some View {
        switch generationState {
        case .completed: content
        case .pending: pendingContent
        case .error: errorComponent
        }
    }
    
    func checkVideoStatus(_ generationID: String, completion: @escaping (String, String) -> Void, errorHandler: @escaping () -> Void) {
        self.source.videoStatus(generationID: generationID) { status, url in
            print(status)
            if status == "finished" {
                source.genIDArr.remove(generationID)
                video.status = status
                video.url = url
                source.saveCompletedVideo(generationID, status: status, url: url)
                completion(status, url)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    checkVideoStatus(generationID) { status, url in
                        completion(status, url)
                    } errorHandler: {
                        errorHandler()
                    }
                }
            }
        } errorHandler: {
            errorHandler()
        }
    }
    
    private var pendingContent: some View {
        ZStack {
            if let image = imageFromData {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: (UIScreen.main.bounds.width - 40)/2, height: 260)
                    .clipped()
                LinearGradient(colors: [.black.opacity(0.7), .black.opacity(0)], startPoint: .bottom, endPoint: .top)
                    .frame(height: 20)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                Rectangle()
                    .fill(.white.opacity(0.3))
            }
            
            VStack(spacing: 6) {
                ProgressView()
                    .tint(.cSecondary)
                Text("Generation usually takes\nabout a minute")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 154, height: 72)
            .clipShape(.rect(cornerRadius: 8))
            .blur(radius: 20)
            
            Text(video.effect)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(width: (UIScreen.main.bounds.width - 40)/2, height: 260)
        .clipShape(.rect(cornerRadius: 8))
    }
    
    private var errorComponent: some View {
        Rectangle()
            .fill(.white.opacity(0.3))
            .overlay(
                VStack(spacing: 6) {
                    Text("Generation error")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.textMain)
                    Button {
                        source.removeVideo(id: video.id)
                    } label: {
                        Text("Delete")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.red)
                            .frame(width: 70, height: 30)
                    }
                }
            )
            .frame(width: (UIScreen.main.bounds.width - 40)/2, height: 260)
            .clipShape(.rect(cornerRadius: 8))
    }
    
    private var imageFromData: Image? {
        if let uiImage = UIImage(data: video.image) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    private var content: some View {
        Button {
            if video.status == "finished" {
                router.path.append(EffectsV2Route.historyResult(video))
            }
        } label: {
            ZStack {
                videoPreview
                    .clipShape(.rect(cornerRadius: 8))
                
                LinearGradient(colors: [.black.opacity(0.7), .black.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 25)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .overlay(
                        effectHeader
                            .padding(4)
                        ,alignment: .bottomLeading
                    )
                
            }
            .frame(width: (UIScreen.main.bounds.width - 40)/2, height: 260)
        }
        .clipShape(.rect(cornerRadius: 8))
        
        
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
    
    private var effectHeader: some View {
        Text(video.effect)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(.textMain)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
    }
    
     private var videoPreview: some View {
         VideoPlayer(player: player)
             .disabled(true)
             .frame(width: (UIScreen.main.bounds.width - 40)/2 * 16 / 9, height: 260 * 16 / 9)
             .frame(width: (UIScreen.main.bounds.width - 40)/2, height: 260)
             .clipShape(.rect(cornerRadius: 8))
             .clipped()
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
}

//#Preview {
//    HistoryListCard(
//        effect: Effect(
//            id: 1,
//            ai: "pv",
//            effect: "Popular",
//            preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
//            previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
//        )
//    )
//    .padding()
//    .background(Color.black)
//    .environmentObject(EffectsV2Router())
//}

final class DoubleLoadHelper: ObservableObject {
    var loaded = false
    
}
