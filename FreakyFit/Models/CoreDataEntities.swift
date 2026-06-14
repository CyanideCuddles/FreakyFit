import Foundation
import CoreData

// MARK: - WorkoutTemplate
@objc(WorkoutTemplate)
public class WorkoutTemplate: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var exercises: NSSet?
    @NSManaged public var scheduleDays: NSSet?
    @NSManaged public var logs: NSSet?
    
    public var exercisesArray: [ExerciseTemplate] {
        let set = exercises as? Set<ExerciseTemplate> ?? []
        return set.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    public var scheduleDaysArray: [ScheduleDay] {
        let set = scheduleDays as? Set<ScheduleDay> ?? []
        return set.sorted { $0.dayOfWeek < $1.dayOfWeek }
    }
    
    public var scheduleDaysString: String {
        let days = scheduleDaysArray.map { day -> String in
            switch day.dayOfWeek {
            case 1: return "Sun"
            case 2: return "Mon"
            case 3: return "Tue"
            case 4: return "Wed"
            case 5: return "Thu"
            case 6: return "Fri"
            case 7: return "Sat"
            default: return ""
            }
        }.filter { !$0.isEmpty }
        
        if days.count == 7 {
            return "Daily"
        } else if days.isEmpty {
            return "Unscheduled"
        } else {
            return days.joined(separator: ", ")
        }
    }
}

// MARK: - ExerciseTemplate
@objc(ExerciseTemplate)
public class ExerciseTemplate: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var sets: Int32
    @NSManaged public var reps: Int32
    @NSManaged public var restSeconds: Int32
    @NSManaged public var notes: String?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var workout: WorkoutTemplate?
}

// MARK: - ScheduleDay
@objc(ScheduleDay)
public class ScheduleDay: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var dayOfWeek: Int16 // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    @NSManaged public var workout: WorkoutTemplate?
}

// MARK: - WorkoutLog
@objc(WorkoutLog)
public class WorkoutLog: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var startedAt: Date?
    @NSManaged public var completedAt: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completionPercent: Float
    @NSManaged public var workout: WorkoutTemplate?
    @NSManaged public var exerciseLogs: NSSet?
    
    public var exerciseLogsArray: [ExerciseLog] {
        let set = exerciseLogs as? Set<ExerciseLog> ?? []
        return set.sorted { $0.sortOrder < $1.sortOrder }
    }
}

// MARK: - ExerciseLog
@objc(ExerciseLog)
public class ExerciseLog: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var exerciseName: String?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var workoutLog: WorkoutLog?
    @NSManaged public var setLogs: NSSet?
    
    public var setLogsArray: [SetLog] {
        let set = setLogs as? Set<SetLog> ?? []
        return set.sorted { $0.setNumber < $1.setNumber }
    }
}

// MARK: - SetLog
@objc(SetLog)
public class SetLog: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var setNumber: Int32
    @NSManaged public var targetReps: Int32
    @NSManaged public var actualReps: Int32
    @NSManaged public var weight: Float
    @NSManaged public var isCompleted: Bool
    @NSManaged public var exerciseLog: ExerciseLog?
}

// MARK: - WeightEntry
@objc(WeightEntry)
public class WeightEntry: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var weight: Float
    @NSManaged public var date: Date?
}

// MARK: - Note
@objc(Note)
public class Note: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var category: String? // "workout" or "body"
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

// MARK: - UserSettings
@objc(UserSettings)
public class UserSettings: NSManagedObject {
    @NSManaged public var goalWeight: Float
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var reminderTime: String? // "HH:mm" format, e.g. "07:00"
    @NSManaged public var darkModeEnabled: Bool
    @NSManaged public var weightUnit: Int16 // 0 = kg, 1 = lbs
}
