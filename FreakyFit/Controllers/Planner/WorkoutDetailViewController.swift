import UIKit

class WorkoutDetailViewController: UIViewController {
    
    var workoutTemplate: WorkoutTemplate!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let nameField = UITextField()
    
    private let scheduleHeader = UILabel()
    private let scheduleStack = UIStackView()
    
    private let exercisesHeader = UILabel()
    private let tableView = UITableView()
    
    private let addExerciseButton = GradientButton(title: "Add Exercise")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWorkoutData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveWorkoutName()
    }
    
    private func setupUI() {
        title = "Edit Workout"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.fillSuperview()
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        // Editable Name
        nameField.font = UIFont.appTitle
        nameField.placeholder = "Workout Name"
        nameField.borderStyle = .roundedRect
        nameField.autocapitalizationType = .words
        contentView.addSubview(nameField)
        
        // Schedule header
        scheduleHeader.text = "WEEKLY SCHEDULE"
        scheduleHeader.font = UIFont.appCaption
        scheduleHeader.textColor = UIColor.appTextSecondary
        contentView.addSubview(scheduleHeader)
        
        // Schedule stack
        scheduleStack.axis = .horizontal
        scheduleStack.distribution = .fillEqually
        scheduleStack.spacing = 4
        contentView.addSubview(scheduleStack)
        
        setupScheduleButtons()
        
        // Exercises header
        exercisesHeader.text = "EXERCISES"
        exercisesHeader.font = UIFont.appCaption
        exercisesHeader.textColor = UIColor.appTextSecondary
        contentView.addSubview(exercisesHeader)
        
        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false // Sized dynamically inside the scrollview
        tableView.register(ExerciseCell.self, forCellReuseIdentifier: ExerciseCell.reuseIdentifier)
        contentView.addSubview(tableView)
        
        addExerciseButton.addTarget(self, action: #selector(handleAddExercise), for: .touchUpInside)
        contentView.addSubview(addExerciseButton)
        
        // Anchors
        nameField.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 44)
        )
        
        scheduleHeader.anchor(
            top: nameField.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: -16)
        )
        
        scheduleStack.anchor(
            top: scheduleHeader.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 36)
        )
        
        exercisesHeader.anchor(
            top: scheduleStack.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: -16)
        )
        
        tableView.anchor(
            top: exercisesHeader.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        )
        
        addExerciseButton.anchor(
            top: tableView.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 24, bottom: -24, right: -24),
            size: CGSize(width: 0, height: 50)
        )
    }
    
    private func setupScheduleButtons() {
        let days: [(title: String, code: Int16)] = [
            ("M", 2), ("T", 3), ("W", 4), ("T", 5), ("F", 6), ("S", 7), ("S", 1)
        ]
        
        for day in days {
            let btn = UIButton(type: .custom)
            btn.setTitle(day.title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            btn.tag = Int(day.code)
            btn.addTarget(self, action: #selector(handleScheduleDayTap(_:)), for: .touchUpInside)
            btn.roundCorners(radius: 6)
            
            scheduleStack.addArrangedSubview(btn)
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
        contentView.backgroundColor = UIColor.appBackground
        nameField.backgroundColor = UIColor.appSurface
        nameField.textColor = UIColor.appTextPrimary
        scheduleHeader.textColor = UIColor.appTextSecondary
        exercisesHeader.textColor = UIColor.appTextSecondary
        tableView.backgroundColor = UIColor.appBackground
        updateScheduleButtonsHighlighting()
    }
    
    private func loadWorkoutData() {
        nameField.text = workoutTemplate.name
        updateScheduleButtonsHighlighting()
        tableView.reloadData()
        
        // Dynamically adjust table height constraint to match cell items
        let rowCount = workoutTemplate.exercisesArray.count
        let totalTableHeight = CGFloat(rowCount * 64)
        
        tableView.heightAnchor.constraint(equalToConstant: totalTableHeight).isActive = true
    }
    
    private func updateScheduleButtonsHighlighting() {
        let activeDays = workoutTemplate.scheduleDaysArray.map { $0.dayOfWeek }
        
        for view in scheduleStack.arrangedSubviews {
            if let btn = view as? UIButton {
                let isScheduled = activeDays.contains(Int16(btn.tag))
                if isScheduled {
                    btn.backgroundColor = UIColor.appPrimary
                    btn.setTitleColor(.white, for: .normal)
                } else {
                    btn.backgroundColor = UIColor.appSurface
                    btn.setTitleColor(UIColor.appTextSecondary, for: .normal)
                }
            }
        }
    }
    
    private func saveWorkoutName() {
        if let text = nameField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            workoutTemplate.name = text
            DataManager.shared.save()
        }
    }
    
    @objc private func handleScheduleDayTap(_ sender: UIButton) {
        let dayCode = Int16(sender.tag)
        var activeDays = workoutTemplate.scheduleDaysArray.map { $0.dayOfWeek }
        
        if activeDays.contains(dayCode) {
            activeDays.removeAll { $0 == dayCode }
        } else {
            activeDays.append(dayCode)
        }
        
        DataManager.shared.setSchedule(for: workoutTemplate, days: activeDays)
        updateScheduleButtonsHighlighting()
    }
    
    @objc private func handleAddExercise() {
        let editVC = ExerciseEditViewController()
        editVC.workoutTemplate = workoutTemplate
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// MARK: - TableView
extension WorkoutDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutTemplate.exercisesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseCell.reuseIdentifier, for: indexPath) as? ExerciseCell else {
            return UITableViewCell()
        }
        
        let exercise = workoutTemplate.exercisesArray[indexPath.row]
        cell.configure(with: exercise)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = workoutTemplate.exercisesArray[indexPath.row]
        let editVC = ExerciseEditViewController()
        editVC.workoutTemplate = workoutTemplate
        editVC.editingExercise = exercise
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let exercise = workoutTemplate.exercisesArray[indexPath.row]
            DataManager.shared.deleteExercise(exercise)
            loadWorkoutData()
        }
    }
}
