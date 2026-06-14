import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notification auth: \(error)")
                }
                completion(granted)
            }
        }
    }
    
    func scheduleDailyReminder(at time: String) {
        cancelAllNotifications()
        
        let timeParts = time.components(separatedBy: ":")
        guard timeParts.count == 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to get Freaky Fit!"
        content.body = "Don't skip your workout template scheduled for today. Let's make progress!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    func scheduleMissedWorkoutReminder() {
        let content = UNMutableNotificationContent()
        content.title = "We missed you yesterday!"
        content.body = "You didn't log a workout yesterday. Keep the streak alive and log today's session!"
        content.sound = .default
        
        // Trigger 24 hours later if no workout is completed
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0 // Alert at 9:00 AM next day
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "missed_workout_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling missed workout reminder: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func updateNotificationSettings(enabled: Bool, time: String) {
        if enabled {
            requestAuthorization { granted in
                if granted {
                    self.scheduleDailyReminder(at: time)
                }
            }
        } else {
            cancelAllNotifications()
        }
    }
}
