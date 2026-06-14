import UIKit

extension UIFont {
    static var appLargeTitle: UIFont {
        return .systemFont(ofSize: 28, weight: .bold)
    }
    
    static var appTitle: UIFont {
        return .systemFont(ofSize: 22, weight: .semibold)
    }
    
    static var appHeadline: UIFont {
        return .systemFont(ofSize: 17, weight: .semibold)
    }
    
    static var appBody: UIFont {
        return .systemFont(ofSize: 16, weight: .regular)
    }
    
    static var appCallout: UIFont {
        return .systemFont(ofSize: 15, weight: .regular)
    }
    
    static var appCaption: UIFont {
        return .systemFont(ofSize: 13, weight: .regular)
    }
    
    static var appButtonFont: UIFont {
        return .systemFont(ofSize: 17, weight: .bold)
    }
}
