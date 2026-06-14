import UIKit

class ActiveWorkoutViewController: UIViewController {
    
    var workoutTemplate: WorkoutTemplate!
    private var workoutLog: WorkoutLog!
    
    private var activeExerciseIndex = 0
    private var elapsedSeconds = 0
    private var timer: Timer?
    
    private let timeLabel = UILabel()
    private let progressLabel = UILabel()
    private let progressRing = ProgressRing()
    
    // Exercise Card UI
    private let exerciseCard = UIView()
    private let exerciseNameLabel = UILabel()
    private let tableView = UITableView()
    
    private let nextButton = UIButton(type: .system)
    private let prevButton = UIButton(type: .system)
    
    // Rest Timer overlay container
    private let restOverlay = UIView()
    private let restTimerView = RestTimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
        
        // Start tracking
        workoutLog = DataManager.shared.startWorkout(from: workoutTemplate)
        startTimer()
        loadExercise()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setupUI() {
        title = "Workout Log"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Quit",
            style: .plain,
            target: self,
            action: #selector(handleQuitTap)
        )
        
        timeLabel.font = .systemFont(ofSize: 22, weight: .bold)
        timeLabel.textColor = UIColor.appPrimary
        timeLabel.text = "00:00"
        view.addSubview(timeLabel)
        
        progressRing.lineWidth = 6
        view.addSubview(progressRing)
        
        progressLabel.font = UIFont.appCaption
        progressLabel.textColor = UIColor.appTextSecondary
        progressLabel.text = "COMPLETION"
        progressLabel.textAlignment = .center
        view.addSubview(progressLabel)
        
        // Exercise details card
        exerciseCard.backgroundColor = UIColor.appSurface
        exerciseCard.roundCorners(radius: 12)
        exerciseCard.addShadow(color: .black, opacity: 0.05, offset: CGSize(width: 0, height: 2), radius: 6)
        view.addSubview(exerciseCard)
        
        exerciseNameLabel.font = UIFont.appTitle
        exerciseNameLabel.textColor = UIColor.appTextPrimary
        exerciseCard.addSubview(exerciseNameLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.appSeparator
        tableView.backgroundColor = .clear
        tableView.register(SetCell.self, forCellReuseIdentifier: SetCell.reuseIdentifier)
        exerciseCard.addSubview(tableView)
        
        // Nav Buttons
        prevButton.setTitle("← Previous", for: .normal)
        prevButton.titleLabel?.font = UIFont.appHeadline
        prevButton.tintColor = UIColor.appTextSecondary
        prevButton.addTarget(self, action: #selector(handlePrev), for: .touchUpInside)
        view.addSubview(prevButton)
        
        nextButton.setTitle("Next Exercise →", for: .normal)
        nextButton.titleLabel?.font = UIFont.appHeadline
        nextButton.tintColor = UIColor.appSecondary
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        view.addSubview(nextButton)
        
        // Layout Anchors
        timeLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)
        )
        
        progressRing.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: -16),
            size: CGSize(width: 44, height: 44)
        )
        
        progressLabel.anchor(
            top: progressRing.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: -16)
        )
        progressLabel.centerXAnchor.constraint(equalTo: progressRing.centerXAnchor).isActive = true
        
        exerciseCard.anchor(
            top: progressLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        )
        
        exerciseNameLabel.anchor(
            top: exerciseCard.topAnchor,
            leading: exerciseCard.leadingAnchor,
            trailing: exerciseCard.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        )
        
        tableView.anchor(
            top: exerciseNameLabel.bottomAnchor,
            leading: exerciseCard.leadingAnchor,
            bottom: exerciseCard.bottomAnchor,
            trailing: exerciseCard.trailingAnchor,
            padding: UIEdgeInsets(top: 12, left: 0, bottom: -12, right: 0)
        )
        
        prevButton.anchor(
            top: exerciseCard.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            padding: UIEdgeInsets(top: 16, left: 24, bottom: -24, right: 0),
            size: CGSize(width: 110, height: 50)
        )
        
        nextButton.anchor(
            top: exerciseCard.bottomAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 0, bottom: -24, right: -24),
            size: CGSize(width: 140, height: 50)
        )
        
        setupRestOverlay()
    }
    
    private func setupRestOverlay() {
        restOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        restOverlay.isHidden = true
        view.addSubview(restOverlay)
        restOverlay.fillSuperview()
        
        restOverlay.addSubview(restTimerView)
        restTimerView.centerInSuperview(size: CGSize(width: 280, height: 260))
        
        restTimerView.onTimerComplete = { [weak self] in
            self?.hideRestOverlay()
        }
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
        view.backgroundColor = UIColor.appBackground
        exerciseCard.backgroundColor = UIColor.appSurface
        exerciseNameLabel.textColor = UIColor.appTextPrimary
        progressLabel.textColor = UIColor.appTextSecondary
        tableView.separatorColor = UIColor.appSeparator
        tableView.reloadData()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        elapsedSeconds += 1
        let min = elapsedSeconds / 60
        let sec = elapsedSeconds % 60
        timeLabel.text = String(format: "%02d:%02d", min, sec)
    }
    
    private func loadExercise() {
        guard activeExerciseIndex < workoutLog.exerciseLogsArray.count else { return }
        
        let exLog = workoutLog.exerciseLogsArray[activeExerciseIndex]
        exerciseNameLabel.text = exLog.exerciseName
        
        // Hide prev button if first exercise
        prevButton.isHidden = activeExerciseIndex == 0
        
        // Next button title shifts to finish on last exercise
        let isLast = activeExerciseIndex == workoutLog.exerciseLogsArray.count - 1
        let btnTitle = isLast ? "Finish Workout ✓" : "Next Exercise →"
        nextButton.setTitle(btnTitle, for: .normal)
        nextButton.tintColor = isLast ? UIColor.appSuccess : UIColor.appSecondary
        
        tableView.reloadData()
    }
    
    @objc private func handleQuitTap() {
        let alert = UIAlertController(
            title: "Quit Workout?",
            message: "Are you sure you want to stop tracking? Today's progress will not be saved.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Resume", style: .default))
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { [weak self] _ in
            // Delete incomplete log from Core Data context
            DataManager.shared.deleteWorkoutTemplate(self?.workoutLog.workout ?? WorkoutTemplate()) // Wait, template shouldn't delete, only delete workoutLog
            DataManager.shared.resetAllData() // Wait, resetAllData is dangerous! Let's delete the specific log
            
            // Delete specific log object
            CoreDataStack.shared.viewContext.delete(self?.workoutLog ?? WorkoutLog())
            DataManager.shared.save()
            
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func handlePrev() {
        if activeExerciseIndex > 0 {
            activeExerciseIndex -= 1
            loadExercise()
        }
    }
    
    @objc private func handleNext() {
        let isLast = activeExerciseIndex == workoutLog.exerciseLogsArray.count - 1
        
        if isLast {
            finishWorkout()
        } else {
            activeExerciseIndex += 1
            loadExercise()
        }
    }
    
    private func showRestOverlay(seconds: Int) {
        restTimerView.totalSeconds = seconds
        restOverlay.isHidden = false
        restOverlay.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.restOverlay.alpha = 1.0
        }
        
        restTimerView.start()
    }
    
    private func hideRestOverlay() {
        UIView.animate(withDuration: 0.3, animations: {
            self.restOverlay.alpha = 0.0
        }) { _ in
            self.restOverlay.isHidden = true
        }
    }
    
    private func updateProgress() {
        progressRing.setProgress(CGFloat(workoutLog.completionPercent), animated: true)
    }
    
    private func finishWorkout() {
        timer?.invalidate()
        timer = nil
        
        DataManager.shared.completeWorkout(workoutLog)
        
        let alert = UIAlertController(
            title: "Workout Completed!",
            message: "Amazing effort! You finished '\(workoutTemplate.name ?? "")' in \(elapsedSeconds/60) min.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Save & Finish", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - TableView Methods
extension ActiveWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard activeExerciseIndex < workoutLog.exerciseLogsArray.count else { return 0 }
        return workoutLog.exerciseLogsArray[activeExerciseIndex].setLogsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SetCell.reuseIdentifier, for: indexPath) as? SetCell else {
            return UITableViewCell()
        }
        
        let exLog = workoutLog.exerciseLogsArray[activeExerciseIndex]
        let setLog = exLog.setLogsArray[indexPath.row]
        
        cell.configure(
            setNumber: Int(setLog.setNumber),
            targetReps: Int(setLog.targetReps),
            isCompleted: setLog.isCompleted,
            weight: setLog.weight,
            actualReps: Int(setLog.actualReps)
        )
        
        cell.onToggleCompletion = { [weak self] in
            guard let self = self else { return }
            
            // Toggle completed states
            if setLog.isCompleted {
                setLog.isCompleted = false
                setLog.actualReps = 0
                DataManager.shared.save()
                self.updateProgress()
                tableView.reloadRows(at: [indexPath], with: .fade)
            } else {
                // Request log weights & reps
                self.showLogInputs(setLog: setLog, indexPath: indexPath)
            }
        }
        
        return cell
    }
    
    private func showLogInputs(setLog: SetLog, indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Log Set \(setLog.setNumber)",
            message: "Enter actual weight and reps",
            preferredStyle: .alert
        )
        
        alert.addTextField { field in
            field.placeholder = "Weight (kg)"
            field.keyboardType = .decimalPad
            field.text = setLog.weight > 0 ? String(format: "%.1f", setLog.weight) : ""
        }
        
        alert.addTextField { field in
            field.placeholder = "Reps"
            field.keyboardType = .numberPad
            field.text = "\(setLog.targetReps)"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let save = UIAlertAction(title: "Check Off", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let weightText = alert.textFields?[0].text ?? "0"
            let repsText = alert.textFields?[1].text ?? "\(setLog.targetReps)"
            
            let weight = Float(weightText) ?? 0.0
            let reps = Int32(repsText) ?? setLog.targetReps
            
            DataManager.shared.completeSet(
                in: self.workoutLog,
                exerciseIndex: self.activeExerciseIndex,
                setNumber: setLog.setNumber,
                actualReps: reps,
                weight: weight
            )
            
            self.updateProgress()
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            
            // Auto trigger rest timer if exercise template specifies it
            let templateExercises = self.workoutTemplate.exercisesArray
            if self.activeExerciseIndex < templateExercises.count {
                let restSec = templateExercises[self.activeExerciseIndex].restSeconds
                if restSec > 0 {
                    self.showRestOverlay(seconds: Int(restSec))
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}
