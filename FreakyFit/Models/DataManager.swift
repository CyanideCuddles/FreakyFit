import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    
    private let context = CoreDataStack.shared.viewContext
    
    private init() {}
    
    // MARK: - Workout Templates
    
    func fetchAllWorkoutTemplates() -> [WorkoutTemplate] {
        let request = NSFetchRequest<WorkoutTemplate>(entityName: "WorkoutTemplate")
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        request.fetchBatchSize = 20
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch workout templates: \(error)")
            return []
        }
    }
    
    func fetchTodaysWorkouts() -> [WorkoutTemplate] {
        let dayVal = Int16(Date().dayOfWeek)
        let templates = fetchAllWorkoutTemplates()
        
        return templates.filter { template in
            template.scheduleDaysArray.contains { $0.dayOfWeek == dayVal }
        }
    }
    
    func createWorkoutTemplate(name: String, notes: String?) -> WorkoutTemplate {
        let template = WorkoutTemplate(context: context)
        template.id = UUID()
        template.name = name
        template.notes = notes
        template.createdAt = Date()
        
        let existingCount = fetchAllWorkoutTemplates().count
        template.sortOrder = Int32(existingCount)
        
        save()
        return template
    }
    
    func deleteWorkoutTemplate(_ template: WorkoutTemplate) {
        context.delete(template)
        save()
    }
    
    func addExercise(
        to workout: WorkoutTemplate,
        name: String,
        sets: Int32,
        reps: Int32,
        restSeconds: Int32,
        notes: String?
    ) -> ExerciseTemplate {
        let exercise = ExerciseTemplate(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.sets = sets
        exercise.reps = reps
        exercise.restSeconds = restSeconds
        exercise.notes = notes
        exercise.workout = workout
        
        let existingCount = workout.exercisesArray.count
        exercise.sortOrder = Int32(existingCount)
        
        save()
        return exercise
    }
    
    func deleteExercise(_ exercise: ExerciseTemplate) {
        context.delete(exercise)
        save()
    }
    
    func setSchedule(for workout: WorkoutTemplate, days: [Int16]) {
        // Delete existing schedule days
        if let existingDays = workout.scheduleDays as? Set<ScheduleDay> {
            for day in existingDays {
                context.delete(day)
            }
        }
        
        // Add new schedule days
        for dayOfWeek in days {
            let day = ScheduleDay(context: context)
            day.id = UUID()
            day.dayOfWeek = dayOfWeek
            day.workout = workout
        }
        
        save()
    }
    
    // MARK: - Workout Logging
    
    func startWorkout(from template: WorkoutTemplate) -> WorkoutLog {
        let log = WorkoutLog(context: context)
        log.id = UUID()
        log.startedAt = Date()
        log.isCompleted = false
        log.completionPercent = 0.0
        log.workout = template
        
        var exerciseOrder: Int32 = 0
        for exerciseTemplate in template.exercisesArray {
            let exLog = ExerciseLog(context: context)
            exLog.id = UUID()
            exLog.exerciseName = exerciseTemplate.name
            exLog.sortOrder = exerciseOrder
            exLog.workoutLog = log
            
            for setNum in 1...exerciseTemplate.sets {
                let setLog = SetLog(context: context)
                setLog.id = UUID()
                setLog.setNumber = setNum
                setLog.targetReps = exerciseTemplate.reps
                setLog.actualReps = 0
                
                // Prefill with latest logged weight for this exercise if available
                setLog.weight = fetchLatestWeightForExercise(name: exerciseTemplate.name ?? "")
                
                setLog.isCompleted = false
                setLog.exerciseLog = exLog
            }
            
            exerciseOrder += 1
        }
        
        save()
        return log
    }
    
    private func fetchLatestWeightForExercise(name: String) -> Float {
        let request = NSFetchRequest<SetLog>(entityName: "SetLog")
        request.predicate = NSPredicate(format: "exerciseLog.exerciseName == %@", name)
        request.sortDescriptors = [NSSortDescriptor(key: "exerciseLog.workoutLog.completedAt", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first?.weight ?? 0.0
        } catch {
            return 0.0
        }
    }
    
    func completeSet(
        in log: WorkoutLog,
        exerciseIndex: Int,
        setNumber: Int32,
        actualReps: Int32,
        weight: Float
    ) {
        guard exerciseIndex < log.exerciseLogsArray.count else { return }
        let exerciseLog = log.exerciseLogsArray[exerciseIndex]
        
        if let setLog = exerciseLog.setLogsArray.first(where: { $0.setNumber == setNumber }) {
            setLog.actualReps = actualReps
            setLog.weight = weight
            setLog.isCompleted = true
            
            updateCompletionPercentage(for: log)
        }
    }
    
    private func updateCompletionPercentage(for log: WorkoutLog) {
        var totalSets = 0
        var completedSets = 0
        
        for exLog in log.exerciseLogsArray {
            for setLog in exLog.setLogsArray {
                totalSets += 1
                if setLog.isCompleted {
                    completedSets += 1
                }
            }
        }
        
        if totalSets > 0 {
            log.completionPercent = Float(completedSets) / Float(totalSets)
        } else {
            log.completionPercent = 0.0
        }
        
        save()
    }
    
    func completeWorkout(_ log: WorkoutLog) {
        log.completedAt = Date()
        log.isCompleted = true
        updateCompletionPercentage(for: log)
        save()
    }
    
    func fetchWorkoutHistory(limit: Int = 20) -> [WorkoutLog] {
        let request = NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
        request.predicate = NSPredicate(format: "isCompleted == true")
        request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
        request.fetchLimit = limit
        request.fetchBatchSize = 20
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch workout logs: \(error)")
            return []
        }
    }
    
    // MARK: - Weight Entries
    
    func saveWeightEntry(weight: Float, date: Date) {
        // Check if entry for this date already exists
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        let request = NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        
        do {
            let existing = try context.fetch(request)
            if let first = existing.first {
                first.weight = weight
            } else {
                let entry = WeightEntry(context: context)
                entry.id = UUID()
                entry.weight = weight
                entry.date = date
            }
            save()
        } catch {
            print("Failed to query weight entry: \(error)")
        }
    }
    
    func fetchWeightEntries(last count: Int = 30) -> [WeightEntry] {
        let request = NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = count
        request.fetchBatchSize = 20
        
        do {
            // Return chronological order (oldest first) for graphing
            return try context.fetch(request).reversed()
        } catch {
            print("Failed to fetch weight entries: \(error)")
            return []
        }
    }
    
    func latestWeight() -> WeightEntry? {
        let request = NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch latest weight entry: \(error)")
            return nil
        }
    }
    
    // MARK: - Notes
    
    func createNote(title: String, content: String, category: String) -> Note {
        let note = Note(context: context)
        note.id = UUID()
        note.title = title
        note.content = content
        note.category = category
        note.createdAt = Date()
        note.updatedAt = Date()
        
        save()
        return note
    }
    
    func fetchNotes(category: String?) -> [Note] {
        let request = NSFetchRequest<Note>(entityName: "Note")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.fetchBatchSize = 20
        
        if let category = category {
            request.predicate = NSPredicate(format: "category == %@", category)
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch notes: \(error)")
            return []
        }
    }
    
    func updateNote(_ note: Note, title: String, content: String) {
        note.title = title
        note.content = content
        note.updatedAt = Date()
        save()
    }
    
    func deleteNote(_ note: Note) {
        context.delete(note)
        save()
    }
    
    // MARK: - User Settings
    
    func getSettings() -> UserSettings {
        let request = NSFetchRequest<UserSettings>(entityName: "UserSettings")
        request.fetchLimit = 1
        
        do {
            if let settings = try context.fetch(request).first {
                return settings
            } else {
                // Create default settings
                let settings = UserSettings(context: context)
                settings.goalWeight = 70.0
                settings.notificationsEnabled = false
                settings.reminderTime = "07:00"
                settings.darkModeEnabled = false
                settings.weightUnit = 0 // kg
                save()
                return settings
            }
        } catch {
            let settings = UserSettings(context: context)
            settings.goalWeight = 70.0
            return settings
        }
    }
    
    func saveSettings(_ settings: UserSettings) {
        save()
    }
    
    // MARK: - Stats & Streaks
    
    func totalWorkoutsCompleted() -> Int {
        let request = NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
        request.predicate = NSPredicate(format: "isCompleted == true")
        
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }
    
    func currentStreak() -> Int {
        let request = NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
        request.predicate = NSPredicate(format: "isCompleted == true")
        request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
        
        do {
            let completedLogs = try context.fetch(request)
            return StreakManager.calculateStreak(from: completedLogs)
        } catch {
            return 0
        }
    }
    
    func longestStreak() -> Int {
        let request = NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
        request.predicate = NSPredicate(format: "isCompleted == true")
        request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
        
        do {
            let completedLogs = try context.fetch(request)
            return StreakManager.calculateLongestStreak(from: completedLogs)
        } catch {
            return 0
        }
    }
    
    // MARK: - Reset All
    
    func resetAllData() {
        let entities = ["SetLog", "ExerciseLog", "WorkoutLog", "ScheduleDay", "ExerciseTemplate", "WorkoutTemplate", "WeightEntry", "Note", "UserSettings"]
        
        for entity in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Failed to delete entity \(entity): \(error)")
            }
        }
        
        save()
    }
    
    // MARK: - Save Helper
    
    func save() {
        CoreDataStack.shared.saveContext()
    }
}
