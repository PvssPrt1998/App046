import SwiftUI

extension Font {
    static func appFont(_ font: AppFont) -> Font {
        return font.font
    }
}

enum AppFont {
    case LargeTitleRegular
    case LargeTitleEmphasized
    
    case Title1Regular
    case Title1Emphasized
    
    case Title2Regular
    case Title2Emphasized
    
    case Title3Regular
    case Title3Emphasized
    
    case HeadlineRegular
    case HeadlineEmphasized
    
    case BodyRegular
    case BodyEmphasized
    
    case CalloutRegular
    case CalloutEmphasized
    
    case SubheadlineRegular
    case SubheadlineEmphasized
    
    case FootnoteRegular
    case FootnoteEmphasized
    
    case Caption1Regular
    case Caption1Emphasized
    
    case Caption2Regular
    case Caption2Emphasized
    
    var font: Font {
        switch self {
        case .LargeTitleRegular:
            return .system(size: 34, weight: .regular)
        case .LargeTitleEmphasized:
            return .system(size: 34, weight: .bold)
        case .Title1Regular:
            return .system(size: 28, weight: .regular)
        case .Title1Emphasized:
            return .system(size: 28, weight: .bold)
        case .Title2Regular:
            return .system(size: 22, weight: .regular)
        case .Title2Emphasized:
            return .system(size: 22, weight: .bold)
        case .Title3Regular:
            return .system(size: 20, weight: .regular)
        case .Title3Emphasized:
            return .system(size: 20, weight: .bold)
        case .HeadlineRegular:
            return .system(size: 17, weight: .regular)
        case .HeadlineEmphasized:
            return .system(size: 17, weight: .semibold)
        case .BodyRegular:
            return .system(size: 17, weight: .semibold)//
        case .BodyEmphasized:
            return .system(size: 17, weight: .semibold)//
        case .CalloutRegular:
            return .system(size: 17, weight: .semibold)//
        case .CalloutEmphasized:
            return .system(size: 17, weight: .semibold)//
        case .SubheadlineRegular:
            return .system(size: 15, weight: .regular)
        case .SubheadlineEmphasized:
            return .system(size: 17, weight: .semibold)//
        case .FootnoteRegular:
            return .system(size: 13, weight: .semibold)
        case .FootnoteEmphasized:
            return .system(size: 17, weight: .semibold)//
        case .Caption1Regular:
            return .system(size: 17, weight: .semibold)//
        case .Caption1Emphasized:
            return .system(size: 17, weight: .semibold)//
        case .Caption2Regular:
            return .system(size: 17, weight: .semibold)//
        case .Caption2Emphasized:
            return .system(size: 17, weight: .semibold)//
        }
    }
}
