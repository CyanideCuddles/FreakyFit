import Foundation

class StreakManager {
    static func calculateStreak(from logs: [WorkoutLog]) -> Int {
        let completedDates = getSortedCompletedDates(from: logs)
        guard !completedDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Check if there is a workout logged today or yesterday
        let hasWorkoutToday = completedDates.contains(today)
        let hasWorkoutYesterday = completedDates.contains(yesterday)
        
        guard hasWorkoutToday || hasWorkoutYesterday else { return 0 }
        
        var currentStreak = 0
        var checkDate = hasWorkoutToday ? today : yesterday
        
        while completedDates.contains(checkDate) {
            currentStreak += 1
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = nextDate
        }
        
        return currentStreak
    }
    
    static func calculateLongestStreak(from logs: [WorkoutLog]) -> Int {
        let completedDates = getSortedCompletedDates(from: logs)
        guard !completedDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date? = nil
        
        for date in completedDates {
            if let last = lastDate {
                let daysBetween = calendar.dateComponents([.day], from: date, to: last).day ?? 0
                
                if daysBetween == 1 {
                    currentStreak += 1
                } else if daysBetween > 1 {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            lastDate = date
        }
        
        longestStreak = max(longestStreak, currentStreak)
        return longestStreak
    }
    
    private static func getSortedCompletedDates(from logs: [WorkoutLog]) -> [Date] {
        let calendar = Calendar.current
        let completedDates = logs.compactMap { log -> Date? in
            guard log.isCompleted, let completedAt = log.completedAt else { return nil }
            return calendar.startOfDay(for: completedAt)
        }
        
        // Deduplicate and sort descending (newest first)
        let uniqueDates = Set(completedDates)
        return uniqueDates.sorted(by: >)
    }
}
