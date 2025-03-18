import Foundation
import CoreData

final class DataManager {
    private let modelName = "DataModel"
    
    lazy var coreDataStack = CoreDataStack(modelName: modelName)
    
    func savePreview(id: Int, url: String) {
        let preview = Preview(context: coreDataStack.managedContext)
        preview.id = Int32(id)
        preview.previewUrl = url
        coreDataStack.saveContext()
    }
    
    func editPreview(id: Int, url: String) {
        do {
            let previews = try coreDataStack.managedContext.fetch(Preview.fetchRequest())
            previews.forEach { preview in
                if preview.id == id {
                    preview.previewUrl = url
                }
            }
            coreDataStack.saveContext()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    func fetchPreviews() throws -> [Int: String] {
        var dict: [Int: String] = [:]
        let previews = try coreDataStack.managedContext.fetch(Preview.fetchRequest())
        previews.forEach { preview in
            dict.updateValue(preview.previewUrl, forKey: Int(preview.id))
        }
        return dict
    }
    func removePreview(id: Int) throws {
        let previews = try coreDataStack.managedContext.fetch(Preview.fetchRequest())
        guard let preview = previews.first(where: {$0.id == id}) else { return }
        coreDataStack.managedContext.delete(preview)
        coreDataStack.saveContext()
    }
    
    func saveVideo(_ id: String, effect: String, status: String, image: Data) {
        let videoCD = VideoCD(context: coreDataStack.managedContext)
        videoCD.videoID = id
        videoCD.effect = effect
        videoCD.status = status
        videoCD.image = image
        coreDataStack.saveContext()
    }
    
    func fetchVideoIds() throws -> Array<Video> {
        var array: Array<Video> = []
        let videos = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
        videos.forEach { videoCD in
            array.append(Video(id: videoCD.videoID, image: videoCD.image, effect: videoCD.effect, url: videoCD.url ?? nil, status: videoCD.status))
        }
        return array
    }
    
    func editVideo(_ id: String, url: String?, status: String) {
        do {
            let videosCD = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
            videosCD.forEach { vcd in
                if vcd.videoID == id {
                    vcd.status = status
                    vcd.url = url
                }
            }
            coreDataStack.saveContext()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func removeVideo(_ id: String) throws {
        let videosCD = try coreDataStack.managedContext.fetch(VideoCD.fetchRequest())
        guard let videoCD = videosCD.first(where: {$0.videoID == id}) else { return }
        coreDataStack.managedContext.delete(videoCD)
        coreDataStack.saveContext()
    }
}
