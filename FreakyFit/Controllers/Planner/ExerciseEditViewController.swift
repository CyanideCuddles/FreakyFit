import UIKit

class ExerciseEditViewController: UIViewController {
    
    var workoutTemplate: WorkoutTemplate!
    var editingExercise: ExerciseTemplate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let nameLabel = UILabel()
    private let nameField = UITextField()
    
    // Form elements for Steppers
    private let setsLabel = UILabel()
    private let setsValueLabel = UILabel()
    private let setsStepper = UIStepper()
    
    private let repsLabel = UILabel()
    private let repsValueLabel = UILabel()
    private let repsStepper = UIStepper()
    
    private let restLabel = UILabel()
    private let restValueLabel = UILabel()
    private let restStepper = UIStepper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
        populateFields()
    }
    
    private func setupUI() {
        title = editingExercise == nil ? "Add Exercise" : "Edit Exercise"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(handleSave)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.fillSuperview()
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        nameLabel.text = "EXERCISE NAME"
        nameLabel.font = UIFont.appCaption
        nameLabel.textColor = UIColor.appTextSecondary
        contentView.addSubview(nameLabel)
        
        nameField.font = UIFont.appBody
        nameField.placeholder = "e.g., Bench Press, Squats"
        nameField.borderStyle = .roundedRect
        nameField.autocapitalizationType = .words
        contentView.addSubview(nameField)
        
        // Stepper rows setup
        setsLabel.text = "Sets"
        setsLabel.font = UIFont.appHeadline
        contentView.addSubview(setsLabel)
        
        setsValueLabel.font = UIFont.appTitle
        setsValueLabel.textColor = UIColor.appPrimary
        setsValueLabel.textAlignment = .right
        contentView.addSubview(setsValueLabel)
        
        setsStepper.minimumValue = 1
        setsStepper.maximumValue = 20
        setsStepper.value = 3
        setsStepper.addTarget(self, action: #selector(handleStepperChange), for: .valueChanged)
        contentView.addSubview(setsStepper)
        
        repsLabel.text = "Reps"
        repsLabel.font = UIFont.appHeadline
        contentView.addSubview(repsLabel)
        
        repsValueLabel.font = UIFont.appTitle
        repsValueLabel.textColor = UIColor.appPrimary
        repsValueLabel.textAlignment = .right
        contentView.addSubview(repsValueLabel)
        
        repsStepper.minimumValue = 1
        repsStepper.maximumValue = 100
        repsStepper.value = 10
        repsStepper.addTarget(self, action: #selector(handleStepperChange), for: .valueChanged)
        contentView.addSubview(repsStepper)
        
        restLabel.text = "Rest"
        restLabel.font = UIFont.appHeadline
        contentView.addSubview(restLabel)
        
        restValueLabel.font = UIFont.appTitle
        restValueLabel.textColor = UIColor.appPrimary
        restValueLabel.textAlignment = .right
        contentView.addSubview(restValueLabel)
        
        restStepper.minimumValue = 0
        restStepper.maximumValue = 300
        restStepper.stepValue = 15
        restStepper.value = 60
        restStepper.addTarget(self, action: #selector(handleStepperChange), for: .valueChanged)
        contentView.addSubview(restStepper)
        
        // Form constraints
        nameLabel.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: -16)
        )
        
        nameField.anchor(
            top: nameLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 44)
        )
        
        // Sets row
        setsLabel.anchor(
            top: nameField.bottomAnchor,
            leading: contentView.leadingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 0)
        )
        setsStepper.anchor(
            top: nameField.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: -16)
        )
        setsValueLabel.anchor(
            top: nameField.bottomAnchor,
            trailing: setsStepper.leadingAnchor,
            padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: -16),
            size: CGSize(width: 50, height: 0)
        )
        
        // Reps row
        repsLabel.anchor(
            top: setsLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 0)
        )
        repsStepper.anchor(
            top: setsLabel.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: -16)
        )
        repsValueLabel.anchor(
            top: setsLabel.bottomAnchor,
            trailing: repsStepper.leadingAnchor,
            padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: -16),
            size: CGSize(width: 50, height: 0)
        )
        
        // Rest row
        restLabel.anchor(
            top: repsLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: -24, right: 0)
        )
        restStepper.anchor(
            top: repsLabel.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: -16)
        )
        restValueLabel.anchor(
            top: repsLabel.bottomAnchor,
            trailing: restStepper.leadingAnchor,
            padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: -16),
            size: CGSize(width: 70, height: 0)
        )
        
        updateStepperLabels()
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
        nameLabel.textColor = UIColor.appTextSecondary
        setsLabel.textColor = UIColor.appTextPrimary
        repsLabel.textColor = UIColor.appTextPrimary
        restLabel.textColor = UIColor.appTextPrimary
        setsStepper.tintColor = UIColor.appPrimary
        repsStepper.tintColor = UIColor.appPrimary
        restStepper.tintColor = UIColor.appPrimary
    }
    
    private func populateFields() {
        if let exercise = editingExercise {
            nameField.text = exercise.name
            setsStepper.value = Double(exercise.sets)
            repsStepper.value = Double(exercise.reps)
            restStepper.value = Double(exercise.restSeconds)
            
            updateStepperLabels()
        }
    }
    
    private func updateStepperLabels() {
        setsValueLabel.text = "\(Int(setsStepper.value))"
        repsValueLabel.text = "\(Int(repsStepper.value))"
        restValueLabel.text = "\(Int(restStepper.value))s"
    }
    
    @objc private func handleStepperChange() {
        updateStepperLabels()
    }
    
    @objc private func handleSave() {
        guard let name = nameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            let errorAlert = UIAlertController(
                title: "Required Field",
                message: "Please enter an exercise name.",
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
            return
        }
        
        let sets = Int32(setsStepper.value)
        let reps = Int32(repsStepper.value)
        let rest = Int32(restStepper.value)
        
        if let exercise = editingExercise {
            // Edit mode
            exercise.name = name
            exercise.sets = sets
            exercise.reps = reps
            exercise.restSeconds = rest
            DataManager.shared.save()
        } else {
            // Create mode
            _ = DataManager.shared.addExercise(
                to: workoutTemplate,
                name: name,
                sets: sets,
                reps: reps,
                restSeconds: rest,
                notes: nil
            )
        }
        
        navigationController?.popViewController(animated: true)
    }
}
