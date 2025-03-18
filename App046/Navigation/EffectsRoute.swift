import Foundation

enum EffectsRoute: Hashable {
    
    case preview(PreviewRoute)
    
    enum PreviewRoute: Hashable {
        case photoUpload
        case photoUploadDouble
        
        enum Generate: Hashable {
            case generate
        }
    }
}
