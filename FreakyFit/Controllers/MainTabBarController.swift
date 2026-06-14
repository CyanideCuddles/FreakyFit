import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupThemeListener()
        applyThemeColors()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        let plannerVC = PlannerViewController()
        let progressVC = ProgressViewController()
        let notesVC = NotesViewController()
        let settingsVC = SettingsViewController()
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let plannerNav = UINavigationController(rootViewController: plannerVC)
        let progressNav = UINavigationController(rootViewController: progressVC)
        let notesNav = UINavigationController(rootViewController: notesVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        // Render custom icons using emojis (iOS 12 compatibility without SF Symbols)
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: imageFromEmoji("🏠"),
            selectedImage: imageFromEmoji("🏠")
        )
        
        plannerNav.tabBarItem = UITabBarItem(
            title: "Planner",
            image: imageFromEmoji("📋"),
            selectedImage: imageFromEmoji("📋")
        )
        
        progressNav.tabBarItem = UITabBarItem(
            title: "Progress",
            image: imageFromEmoji("📊"),
            selectedImage: imageFromEmoji("📊")
        )
        
        notesNav.tabBarItem = UITabBarItem(
            title: "Notes",
            image: imageFromEmoji("📝"),
            selectedImage: imageFromEmoji("📝")
        )
        
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: imageFromEmoji("⚙️"),
            selectedImage: imageFromEmoji("⚙️")
        )
        
        viewControllers = [homeNav, plannerNav, progressNav, notesNav, settingsNav]
    }
    
    private func setupThemeListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func themeDidChange() {
        applyThemeColors()
    }
    
    private func applyThemeColors() {
        tabBar.barTintColor = UIColor.appTabBar
        tabBar.tintColor = UIColor.appPrimary
        tabBar.unselectedItemTintColor = UIColor.appTextSecondary
        
        if let navs = viewControllers as? [UINavigationController] {
            for nav in navs {
                nav.navigationBar.barTintColor = UIColor.appNavBar
                nav.navigationBar.tintColor = UIColor.appPrimary
                nav.navigationBar.titleTextAttributes = [
                    .foregroundColor: UIColor.appTextPrimary,
                    .font: UIFont.appHeadline
                ]
            }
        }
    }
    
    // Renders an emoji as a small UIImage for iOS 12 compatibility
    private func imageFromEmoji(_ emoji: String) -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let rect = CGRect(origin: .zero, size: size)
        
        // Center emoji drawing
        let font = UIFont.systemFont(ofSize: 22)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: style
        ]
        
        emoji.draw(in: rect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
