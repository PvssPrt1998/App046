import Foundation
import Alamofire

final class Networking {
    func fetchTemplatesByCategory(completion: @escaping (TemplatesByCategory) -> Void, errorHandler: @escaping () -> Void) {
        let token = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        
        let header: HTTPHeaders = [(.authorization(bearerToken: token))]
        let parameters: Parameters = ["isNew" : "true", "appName" : "com.andrai.seahalart", "ai[0]": ["pv"], "ai[1]": ["pika"]]
        
        AF.request("https://webbapperyes.shop/api/templatesByCategories", method: .get, parameters: parameters, headers: header).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let templates = try JSONDecoder().decode(TemplatesByCategory.self, from: data)
                    //print(templates.data.first?.categoryTitleEn)
                    completion(templates)
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    errorHandler()
                }
            case  .failure(_):
                errorHandler()
            }
        }
    }
    
    func createVideo(data: Data, idEffect: String, escaping: @escaping (String) -> Void) {
        let token = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        
        let headers: HTTPHeaders = [(.authorization(bearerToken: token))]
        
        let param: Parameters = ["templateId": idEffect, "image" : data, "userId": userID, "appId": Bundle.main.bundleIdentifier ?? "com.andrai.seahalart"]
        
        //print(data, "param")
               
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(Data(idEffect.utf8), withName: "templateId")
            multipartFormData.append(data, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            multipartFormData.append(Data(userID.utf8), withName: "userId")
            multipartFormData.append(Data((Bundle.main.bundleIdentifier ?? "com.dmyver.skp1l3n").utf8), withName: "appId")
        }, to: "https://webbapperyes.shop/api/generate", headers: headers)
        .responseData { response in
            
            switch response.result {
            case .success(let data):
                do {
                    let effects = try JSONDecoder().decode(Generate.self, from: data)
                    print(effects)
                    escaping(effects.data.generationId)
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    escaping("error")
                }
                
            case .failure(let error):
                print("Ошибка запроса:", error.localizedDescription)
                escaping("error")
            }
        }
    }
    
    func getStatus(itemId: String, escaping: @escaping(String, String) -> Void) {
        
        let token = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        
        let header: HTTPHeaders = [(.authorization(bearerToken: token)),
                                    HTTPHeader(name: "AppId", value: Bundle.main.bundleIdentifier ?? "com.andrai.seahalart")]
        
        let param: Parameters = ["generationId": itemId, "appId": Bundle.main.bundleIdentifier ?? "com.andrai.seahalart"]

        
        AF.request("https://webbapperyes.shop/api/generationStatus", method: .get, parameters: param, headers: header).responseData { response in
            //debugPrint(response, "statusGettttt")
            switch response.result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(Status.self, from: data)
                    if let status = item.data?.status {
                        print("networking.getStatus " + status + " " + (item.data?.resultUrl ?? "noVideo"))
                        escaping(status, item.data?.resultUrl ?? "noVideo")
                    } else {
                        escaping("error", "error")
                    }
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    escaping("error", "error")
                }
            case  .failure(_):
                print("ошибка в запросе")
                escaping("error", "error")
            }
        }
        
    }
    
    func loadSora(promt: String, escaping: @escaping(String) -> Void) {
        let token = "c82d075d-b216-4e24-acbb-5f70db5dd864"//"1a96177d-9b79-4a25-9dec-67434274a625"
        
        
        let header: HTTPHeaders = [
            "access-token": token
        ]
        let param: Parameters = ["user_id": userID,
                                 "app_bundle": Bundle.main.bundleIdentifier ?? "com.andrai.seahalart",
                                 "prompt": promt]
        print("Load sora")
        AF.request("https://teremappol.shop/video/text", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header).responseData { response in
            print(response.response)
            
            
           // debugPrint(response, "statusGettttt")
            switch response.result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(VideoResponse.self, from: data)
                   
                    print(item)
                    if item.isInvalid {
                        escaping("error")
                    } else {
                        escaping(item.id)
                    }
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    escaping("error")
                }
            case  .failure(_):
                print("ошибка в запросе")
                escaping("error")
            }
        }
    }
    
    func checkSora(idVideo: String, escaping: @escaping(String) -> Void) {
        let token = "c82d075d-b216-4e24-acbb-5f70db5dd864" //"1a96177d-9b79-4a25-9dec-67434274a625"
        
        
        let header: HTTPHeaders = [
            "access-token": token
        ]
        let param: Parameters = ["video_id": idVideo]
        
        AF.request("https://teremappol.shop/video/\(idVideo)", method: .get,  encoding: JSONEncoding.default, headers: header).responseData { response in
            debugPrint(response, "statusGettttt")
            switch response.result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(VideoStatus.self, from: data)
                    if item.isInvalid {
                        escaping("error")
                    } else {
                        if item.isFinished {
                            escaping("finished")
                        } else {
                            escaping("pending")
                        }
                    }
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    escaping("error")
                }
            case  .failure(_):
                print("ошибка в запросе")
                escaping("error")
            }
        }
    }
    
    
    func getVideoURLSora(idVideo: String, escaping: @escaping(String) -> Void) {
        let token = "c82d075d-b216-4e24-acbb-5f70db5dd864"//"1a96177d-9b79-4a25-9dec-67434274a625"

        AF.request("https://teremappol.shop/video//file/\(idVideo)", method: .get,  encoding: JSONEncoding.default).responseData { response in
            debugPrint(response, "statusVIDEOOEOEOOEOE")
            switch response.result {
            case .success(let data):
                escaping("https://backend.webbapperyes.shop/video/file/\(idVideo)")
            case  .failure(_):
                print("ошибка в запросе")
                escaping("error")
            }
        }
    }
    
    func videoById(id: String, completion: @escaping (URL) -> (), errorHandler: @escaping () -> Void) {
        guard let url =  URL(string: "https://teremappol.shop/video" + "/file/" + id) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue("c82d075d-b216-4e24-acbb-5f70db5dd864", forHTTPHeaderField: "access-token")
        request.httpMethod = "GET"
        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                print(error)
                errorHandler()
                return
            }
          // ensure there is valid response code returned from this HTTP response
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
          else {
            print("Invalid Response received from the server")
            errorHandler()
            return
          }
          // ensure there is data returned
          guard let responseData = data else {
              errorHandler()
            print("nil Data received from the server")
            return
          }
            print("RESPONSE DATA")
            print(responseData)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(id + ".mp4")
            do {
                try responseData.write(to: destinationURL)
                DispatchQueue.main.async {
                    //self.videoIDs[index].url = response
                }
                completion(destinationURL)
                //self.saveVideoToAlbum(videoURL: destinationURL, albumName: "MyAlbum")
                print(destinationURL)
            } catch {
                print("Error saving file:", error)
                errorHandler()
            }
        }
        task.resume()
    }
}
