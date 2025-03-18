import Foundation
import AVFoundation
import UIKit
import Combine
import StoreKit
import Combine
import ApphudSDK
import Alamofire

@MainActor
final class Source: ObservableObject {
    
    @Published var tokens = 0 {
        didSet {
            tokenPublisher.send(true)
        }
    }
    
    @Published var proSubscription = true {
        didSet {
            purchaseSubscriptionPublisher.send(true)
        }
    }
    
    var generationIdForDelete: String?
    
    let purchaseManager = PurchaseManager()
    let documentManager = DocumentManager()
    let coreDataManager = DataManager()
    let networking = Networking()
    let dataflow = DataFlow()
    
    let tokenPublisher = PassthroughSubject<Bool,Never>()
    let purchaseSubscriptionPublisher = PassthroughSubject<Bool,Never>()
    let historyArrayChangedPublisher = PassthroughSubject<Bool, Never>()
    let categoriesArrayChangedPublisher = PassthroughSubject<Bool, Never>()
    
    lazy var generatedHistoryArr: [UserHistory] = DataFlow.loadHistoryArrFromFile() ?? []
    
    lazy var generatingInGenerationView: Array<String> = []
    
    @Published var historyArray: Array<Video> = [] {
        didSet {
            historyArrayChangedPublisher.send(true)
        }
    }
    var categoriesArray = Array<Category>() {
        didSet {
            categoriesArrayChangedPublisher.send(true)
        }
    }
    var genIDArr = Set<String>()
    
    var previewDict: [Int:String] = [:] //id previewSmall
    
    init() {
        
        purchaseManager.loadPaywalls {
            if Apphud.hasActiveSubscription() {
                self.proSubscription = true
                print("PRO SUBSCRIPTION \(self.proSubscription)")
            } else {
                self.proSubscription = false
                print("PRO SUBSCRIPTION \(self.proSubscription)")
            }
        }
        
        localLoad()
        load()
    }

    @MainActor
    func startPurchase(product: ApphudProduct, escaping: @escaping(Bool)->Void) {
        let selectedProduct = product
        Apphud.purchase(selectedProduct) { result in
            if let error = result.error {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            debugPrint(result)
            if let subscription = result.subscription, subscription.isActive() {
                escaping(true)
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                escaping(true)
            } else {
                if Apphud.hasActiveSubscription() {
                    escaping(true)
                }
            }
        }
    }

    
    func localLoad() {
        if let previewDict = try? coreDataManager.fetchPreviews() {
            self.previewDict = previewDict
        }
        if let historyArr = try? coreDataManager.fetchVideoIds() {
            print("Count: \(historyArr.count)")
            self.historyArray = historyArr
        }
    }
    
    func saveCompletedVideo(_ generationID: String, status: String, url: String) {
        print("Save CompletedVideo")
        if let index = historyArray.firstIndex(where: {generationID == $0.id}) {
            var video = historyArray[index]
            video.status = status
            video.url = url
            historyArray[index] = video
            coreDataManager.editVideo(generationID, url: url, status: status)
            self.documentManager.downloadVideoGenerated(urlStr: url, id: generationID) { str in
                //print("SAVED TO LOCAL URL Generated: " + str)
            }
        } else {
            coreDataManager.editVideo(generationID, url: url, status: status)
            self.documentManager.downloadVideoGenerated(urlStr: url, id: generationID) { str in
                //print("SAVED TO LOCAL URL Generated: " + str)
            }
        }
        
    }
    
    func saveOrEditCompletedVideo(_ generationID: String, status: String, url: String) {
        if let index = historyArray.firstIndex(where: {generationID == $0.id}) {
            var video = historyArray[index]
            video.status = status
            video.url = url
            historyArray[index] = video
        }
        coreDataManager.editVideo(generationID, url: url, status: status)
        self.documentManager.removeVideoBy(filename: generationID + ".mp4")
        self.documentManager.downloadVideoGenerated(urlStr: url, id: generationID) { str in
            //print("SAVED TO LOCAL URL Generated: " + str)
        }
    }
    
    func savePendingVideo(_ generationID: String, status: String, effect: String, image: Data) {
        if let index = historyArray.firstIndex(where: {$0.id == generationID}) {
            let video = Video(id: generationID, image: image, effect: effect, url: nil, status: status)
            historyArray[index] = video
            coreDataManager.editVideo(generationID, url: nil, status: status)
        } else {
            let video = Video(id: generationID, image: image, effect: effect, url: nil, status: status)
            historyArray.append(video)
            coreDataManager.saveVideo(generationID, effect: effect, status: status, image: image)
        }
    }
    
    func load() {
        networking.fetchTemplatesByCategory { templates in
            templates.data.forEach { categoryRemote in
                var effects: Array<Effect> = []
                categoryRemote.templates.forEach { effectRemote in
                    var localUrl: String?
                    if let url = self.previewDict[effectRemote.id] {
                        if url != effectRemote.previewSmall {
                            self.previewDict.updateValue(effectRemote.previewSmall, forKey: effectRemote.id)
                            self.coreDataManager.editPreview(id: effectRemote.id, url: effectRemote.previewSmall)
                            self.documentManager.removeVideoBy(filename: "\(effectRemote.id).mp4")//Remove old From DOC
                            self.documentManager.downloadVideo(urlStr: effectRemote.previewSmall, id: effectRemote.id) { str in
                                //print("SAVED TO LOCAL URL: " + str)
                                if let categoryIndex = self.categoriesArray.firstIndex(where: {$0.header == effectRemote.categoryTitleEn}), let effectIndex = self.categoriesArray[categoryIndex].items.firstIndex(where: {$0.id == effectRemote.id}) {
                                    self.categoriesArray[categoryIndex].items[effectIndex].localUrl = str
                                }
                                localUrl = str
                            }
                        } else {
                            if let urlStr = self.documentManager.fetchVideoFromDocuments(filename: "\(effectRemote.id).mp4"),
                               let url = URL(string: urlStr),
                               let urlData = NSData(contentsOf: url)
                            {
                                localUrl = urlStr
                            } else {
                                print("Handle unable local load")
                                self.documentManager.removeVideoBy(filename: "\(effectRemote.id).mp4")//Remove old From DOC
                                self.documentManager.downloadVideo(urlStr: effectRemote.previewSmall, id: effectRemote.id) { str in
                                    //print("SAVED TO LOCAL URL: " + str)
                                    if let categoryIndex = self.categoriesArray.firstIndex(where: {$0.header == effectRemote.categoryTitleEn}), let effectIndex = self.categoriesArray[categoryIndex].items.firstIndex(where: {$0.id == effectRemote.id}) {
                                        self.categoriesArray[categoryIndex].items[effectIndex].localUrl = str
                                    }
                                    localUrl = str
                                }
                                localUrl = nil
                            }
                        }
                    } else {
                        self.previewDict.updateValue(effectRemote.previewSmall, forKey: effectRemote.id)
                        self.coreDataManager.savePreview(id: effectRemote.id, url: effectRemote.previewSmall)
                        self.documentManager.downloadVideo(urlStr: effectRemote.previewSmall, id: effectRemote.id) { str in
                            //print("SAVED TO LOCAL URL: " + str)
                            if let categoryIndex = self.categoriesArray.firstIndex(where: {$0.header == effectRemote.categoryTitleEn}), let effectIndex = self.categoriesArray[categoryIndex].items.firstIndex(where: {$0.id == effectRemote.id}) {
                                self.categoriesArray[categoryIndex].items[effectIndex].localUrl = str
                            }
                            localUrl = str
                        }
                    }
                    effects.append(Effect(id: effectRemote.id, ai: effectRemote.ai.rawValue, effect: effectRemote.effect, preview: effectRemote.preview, previewSmall: effectRemote.previewSmall, localUrl: localUrl))
                }
                self.categoriesArray.append(Category(header: categoryRemote.categoryTitleEn, items: effects))
            }
            let index = self.categoriesArray.firstIndex(where: {$0.header == "Popular"})
            if let index = index {
                let val = self.categoriesArray[index]
                self.categoriesArray.remove(at: index)
                self.categoriesArray.insert(val, at: 0)
            }
            self.objectWillChange.send()
        } errorHandler: {
            print("Cannot load categories")
        }
    }
    
    func removeVideo(id: String) {
        historyArray.removeAll(where: {$0.id == id})
        try? coreDataManager.removeVideo(id)
        self.documentManager.removeVideoBy(filename: id + ".mp4")
    }
    
    //MARK: - Requests
    func createVideo(image: Data, effectID: Int, effectName: String, completion: @escaping (String) -> Void, errorHandler: @escaping () -> Void) {
        networking.createVideo(data: image, idEffect: "\(effectID)") { idGenerate in
            if idGenerate == "error" {
                errorHandler()
            } else {
                completion(idGenerate)
            }
        }
    }
    
    func createVideoText(text: String, completion: @escaping (String) -> Void, errorHandler: @escaping () -> Void) {
        networking.loadSora(promt: text) { id in
            print(id)
            if id == "error" {
                errorHandler()
            } else {
                completion(id)
            }
        }
    }
    
    func videoStatusText(generationID: String, completion: @escaping (String) -> Void, errorHandler: @escaping () -> Void) {
        networking.checkSora(idVideo: generationID) { status in //45afa945-0b67-441f-abc2-e23be14f42a1
            print("videoStatus " + status)
            if status == "error" {
                errorHandler()
            } else {
                if status == "pending" {
                    //save status to coredata for history load element
                    //save status to historyArray for history load element
                    completion("pending")
                } else if status == "finished" { //completed
                    //save status to coredata for history load element, save url to coredata, save video to documents by id as title .mp4
                    //save status to historyArray for history load element
                    completion("finished")
                } else { //completed but chanded "finished" string on server
                    //save status to coredata for history load element, save url to coredata, save video to documents by id as title .mp4
                    //save status to historyArray for history load element
                    completion("finished")
                }
            }
        }
    }
    
    func videoStatus(generationID: String, completion: @escaping (String, String) -> Void, errorHandler: @escaping () -> Void) {
        networking.getStatus(itemId: generationID) { status, url in //45afa945-0b67-441f-abc2-e23be14f42a1
            print("videoStatus " + status)
            if status == "error" || url == "error" {
                errorHandler()
            } else {
                if status == "pending" || status == "queued" {
                    //save status to coredata for history load element
                    //save status to historyArray for history load element
                    completion("pending", "pending")
                } else if status == "finished" { //completed
                    //save status to coredata for history load element, save url to coredata, save video to documents by id as title .mp4
                    //save status to historyArray for history load element
                    completion("finished", url)
                } else { //completed but chanded "finished" string on server
                    //save status to coredata for history load element, save url to coredata, save video to documents by id as title .mp4
                    //save status to historyArray for history load element
                    completion("finished", url)
                }
            }
        }
    }
    
    var timers: [String: Timer] = [:]
    
    func createGenerate(image: Data, idEffect: Int, nameEffect: String, escaping: @escaping(String) -> Void) {
        networking.createVideo(data: image, idEffect: "\(idEffect)") { idGenerate in
            if idGenerate == "error" {
                escaping("error")
            } else {
                let item = UserHistory(nameEffect: nameEffect, idEffect: idEffect, imageOne: image, status: nil, generateID: idGenerate, videoUrl: nil)
                self.generatedHistoryArr.append(item)
                self.saveHistoryArr()
                escaping(idGenerate)
            }
        }
    }
    
    func saveHistoryArr() {
        do {
            let data = try JSONEncoder().encode(generatedHistoryArr)
            try DataFlow.saveHistoryToFile(data: data)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    func checkStatus(id: String) {
        
        let timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.retryCheckStatus(for: id)
        }
        
//        genIDArr.removeAll()
//        //timers.removeAll()
//        print(generatedHistoryArr)
//        for i in generatedHistoryArr {
//            if i.status != "error" && (i.videoUrl == nil || i.videoUrl == "noVideo") {
//                genIDArr.append(i.generateID ?? "")
//            }
//        }
//        for id in genIDArr {
//            startRetryTimer(for: id)
//        }
    }
    
    private func startRetryTimer(for id: String) {
        if timers[id] == nil {
            let timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
                self?.retryCheckStatus(for: id)
            }
            timers[id] = timer
        }
    }
    
    private func retryCheckStatus(for id: String) {
        self.networking.getStatus(itemId: id) { status, urlVideo in
            DispatchQueue.main.async {
                if status != "error" {
                    if urlVideo == "noVideo" {
                        print("Видео всё ещё нет. Повторная проверка через 5 секунд для \(id)")
                    } else {
                        print("Видео найдено: \(status), \(urlVideo), \(id)")
                        self.removeTimer(for: id)
                        self.setStatusData(genID: id, status: status, videoURL: urlVideo)
                        //self.generatePublisher.send((id))
                    }
                } else {
                    print("Ошибка при получении статуса: \(status), \(urlVideo), \(id)")
                    self.removeTimer(for: id)
                    self.setStatusData(genID: id, status: status, videoURL: urlVideo)
                    //self.generatePublisher.send((id))
                }
            }
        }
    }
    
    private func removeTimer(for id: String) {
        if let timer = timers[id] {
            timer.invalidate()
            timers.removeValue(forKey: id)
        }
    }
    
    private func setStatusData(genID: String, status: String, videoURL: String?) {
        if let index = generatedHistoryArr.firstIndex(where: { $0.generateID == genID }) {
            generatedHistoryArr[index].status = status
            generatedHistoryArr[index].videoUrl = videoURL
            saveHistoryArr()
        }
    }
    
    
    //MARK: - PAYWALL
    

    @MainActor
    func dateSubscribe() -> String {
        if let subscription = Apphud.subscription() {
            let expirationDate = subscription.expiresDate // Здесь используется напрямую

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            let formattedDate = dateFormatter.string(from: expirationDate)
            
            return "until \(formattedDate)"
        }
        
        return "No active subscription"
    }

    
    @MainActor func startPurchase(produst: ApphudProduct, escaping: @escaping(Bool) -> Void) {
        let selectedProduct = produst
        Apphud.purchase(selectedProduct) { result in
            if let error = result.error {
                debugPrint("Ошибка покупки: \(error.localizedDescription)")
                escaping(false)
            } else if result.success {
                if let nonRenewingPurchase = result.nonRenewingPurchase {
                    debugPrint("покупка успешна: \(nonRenewingPurchase.productId)")
                    escaping(true)
                } else {
                    debugPrint("Покупка успешна, но покупка не обнаружена")
                    escaping(false)
                }
            } else {
                debugPrint("Покупка не прошла")
                escaping(false)
            }
        }
    }
    
    @MainActor func restorePurchase(escaping: @escaping(Bool) -> Void) {
        print("restore")
        Apphud.restorePurchases {  subscriptions, _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                escaping(false)
                return
            }
            if subscriptions?.first?.isActive() ?? false {
                escaping(true)
                return
            }
            
            if Apphud.hasActiveSubscription() {
                escaping(true)
                return
            }
            
            escaping(false)
        }
    }
}
