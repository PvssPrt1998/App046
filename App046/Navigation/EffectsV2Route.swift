import Foundation

enum EffectsV2Route: Hashable {
    
    case preview(Effect)
    case categoryList(Category)
    case historyResult(Video)
    case promt(String)
    
    enum PreviewRoute: Hashable {
        case photoUpload(Effect)
        case photoUploadDouble(Effect)
        
        enum PhotoUploadRoute: Hashable {
            case generate(Effect)
        }
        
        enum PhotoUploadDoubleRoute: Hashable {
            case generate(Effect)
        }
    }
    
    enum CategoryListRoute: Hashable {
        case preview(Effect)
        
        enum PreviewRoute: Hashable {
            case photoUpload(Effect)
            case photoUploadDouble(Effect)
            
            enum PhotoUploadRoute: Hashable {
                case generate(Effect)
            }
            
            enum PhotoUploadDoubleRoute: Hashable {
                case generate(Effect)
            }
        }
    }
}
