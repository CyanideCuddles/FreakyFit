import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    static let themeDidChangeNotification = Notification.Name("FreakyFitThemeDidChange")
    
    private let darkModeKey = "freakyfit_is_dark_mode"
    
    private(set) var isDarkMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: darkModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: darkModeKey)
        }
    }
    
    private init() {}
    
    func toggleTheme() {
        isDarkMode.toggle()
        applyTheme()
        NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: nil)
    }
    
    func setDarkMode(_ enabled: Bool) {
        if isDarkMode != enabled {
            isDarkMode = enabled
            applyTheme()
            NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: nil)
        }
    }
    
    func applyTheme() {
        // Apply Global appearance configurations for UIKit controls on iOS 12
        let textColor = UIColor.appTextPrimary
        let barColor = UIColor.appNavBar
        let tintColor = UIColor.appPrimary
        
        // Navigation Bar
        UINavigationBar.appearance().barTintColor = barColor
        UINavigationBar.appearance().tintColor = tintColor
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: textColor,
            .font: UIFont.appHeadline
        ]
        
        // Tab Bar
        UITabBar.appearance().barTintColor = UIColor.appTabBar
        UITabBar.appearance().tintColor = tintColor
        UITabBar.appearance().unselectedItemTintColor = UIColor.appTextSecondary
        
        // Table View
        UITableView.appearance().backgroundColor = UIColor.appBackground
        UITableViewCell.appearance().backgroundColor = UIColor.appSurface
    }
}
