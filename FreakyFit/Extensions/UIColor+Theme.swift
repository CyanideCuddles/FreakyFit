import UIKit

extension UIColor {
    private static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        // Since iOS 12 does not support UIUserInterfaceStyle, we delegate to our ThemeManager
        return ThemeManager.shared.isDarkMode ? dark : light
    }
    
    static var appPrimary: UIColor {
        return dynamicColor(
            light: UIColor(red: 229/255, green: 57/255, blue: 53/255, alpha: 1.0), // Red 600
            dark: UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1.0) // Soft Red
        )
    }
    
    static var appSecondary: UIColor {
        return dynamicColor(
            light: UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1.0), // Blue 800
            dark: UIColor(red: 66/255, green: 165/255, blue: 245/255, alpha: 1.0) // Light Blue 400
        )
    }
    
    static var appAccent: UIColor {
        return UIColor(red: 255/255, green: 138/255, blue: 128/255, alpha: 1.0) // Soft light red
    }
    
    static var appBackground: UIColor {
        return dynamicColor(
            light: UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1.0), // Light grey
            dark: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0) // Black
        )
    }
    
    static var appSurface: UIColor {
        return dynamicColor(
            light: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0), // White
            dark: UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0) // Dark Grey (iOS SystemBackground dark equivalent)
        )
    }
    
    static var appTextPrimary: UIColor {
        return dynamicColor(
            light: UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0),
            dark: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        )
    }
    
    static var appTextSecondary: UIColor {
        return UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0) // iOS Gray
    }
    
    static var appSuccess: UIColor {
        return dynamicColor(
            light: UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0), // green
            dark: UIColor(red: 48/255, green: 209/255, blue: 88/255, alpha: 1.0)
        )
    }
    
    static var appWarning: UIColor {
        return dynamicColor(
            light: UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0), // orange
            dark: UIColor(red: 255/255, green: 159/255, blue: 10/255, alpha: 1.0)
        )
    }
    
    static var appDestructive: UIColor {
        return dynamicColor(
            light: UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0), // red
            dark: UIColor(red: 255/255, green: 69/255, blue: 58/255, alpha: 1.0)
        )
    }
    
    static var appTabBar: UIColor {
        return dynamicColor(
            light: UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0),
            dark: UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        )
    }
    
    static var appNavBar: UIColor {
        return dynamicColor(
            light: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0),
            dark: UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        )
    }
    
    static var appSeparator: UIColor {
        return dynamicColor(
            light: UIColor(red: 198/255, green: 198/255, blue: 200/255, alpha: 1.0),
            dark: UIColor(red: 56/255, green: 56/255, blue: 58/255, alpha: 1.0)
        )
    }
}
