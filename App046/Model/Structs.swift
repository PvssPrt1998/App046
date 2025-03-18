import SwiftUI

struct Category: Codable, Hashable {
    let header: String
    var items: [Effect]
}

struct Effect: Codable, Hashable {
    var id: Int
    var ai: String
    var effect: String
    var preview: String?
    var previewSmall: String?
    var localUrl: String?
    var previewImage: UIImage?
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ai
        case effect
        case preview
        case previewSmall
        case localUrl
    }
}

//MARK: Video
struct Video: Hashable {
    let id: String
    let image: Data
    let effect: String
    var url: String?
    var status: String // 0 - generating, 1 - completed, 2 - error
}
