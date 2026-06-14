import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Initialize ThemeManager to apply default colors (including dark mode)
        ThemeManager.shared.applyTheme()
        
        // Initialize UIWindow programmatically (iOS 12 compatibility bypasses SceneDelegate)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = MainTabBarController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        // Configure local notification daily checkoffs
        let settings = DataManager.shared.getSettings()
        if settings.notificationsEnabled {
            let time = settings.reminderTime ?? "07:00"
            NotificationManager.shared.scheduleDailyReminder(at: time)
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save database changes
        DataManager.shared.save()
    }
}
