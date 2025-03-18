import Foundation
import Alamofire

class DocumentManager: NSObject, URLSessionDelegate {
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func downloadVideo(urlStr: String, id: Int, completion: @escaping (String) -> Void) {
        AF.request(urlStr).responseData { (response) in
            //print(response)
            switch response.result {
                case .success(let value):
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsURL.appendingPathComponent("\(id).mp4")
                do {
                    try value.write(to: destinationURL)
                    completion(destinationURL.absoluteString)
                    } catch {
                    print("Something went wrong!")
                }
                //print(destinationURL)
                case .failure(let error): break
                
                }
        }
    }
    
    func downloadVideoGenerated(urlStr: String, id: String, completion: @escaping (String) -> Void) {
        AF.request(urlStr).responseData { (response) in
            //print(response)
            switch response.result {
                case .success(let value):
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsURL.appendingPathComponent(id + ".mp4")
                do {
                    try value.write(to: destinationURL)
                    completion(destinationURL.absoluteString)
                    } catch {
                    print("Something went wrong!")
                }
                //print(destinationURL)
                case .failure(let error): break
                }
        }
    }
    
    func removeVideoBy(filename: String) {
        let fileManager = FileManager.default
        let newPath = "file:///" + documentsPathForFileName(name: "/" + filename)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if fileManager.fileExists(atPath: newPath) {
            do {
                try fileManager.removeItem(atPath: newPath)
            } catch let error {
                print("error occurred, here are the details:\n \(error)")
            }
        }
    }
    
//    func saveVideoToDocuments(effect: Effect) {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let destinationURL = documentsURL.appendingPathComponent("\(effect.id).mp4")
//
//        do {
//            //try responseData.write(to: destinationURL)
//        } catch {
//            print("Error saving file:", error)
//            //errorHandler()
//        }
//    }
    
    func fetchVideoFromDocuments(filename: String) -> String? {
        //guard let url: NSURL = NSURL(string: urlStr), let filename = url.lastPathComponent else { return nil }
        let newPath = "file:///" + documentsPathForFileName(name: "/" + filename)
        return newPath
    }
    
    func documentsPathForFileName(name: String) -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return documentsPath.appending(name)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let data = try? Data(contentsOf: location) else {
            return
        }
        print("Location")
        print(location)
        
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let destinationURL = documentsURL.appendingPathComponent("myVideo.mp4")
//        do {
//            try data.write(to: destinationURL)
//            //saveVideoToAlbum(videoURL: destinationURL, albumName: "MyAlbum")
//        } catch {
//            print("Error saving file:", error)
//        }
    }
}
