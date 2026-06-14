import UIKit

class WeightEntryViewController: UIViewController {
    
    private var currentWeight: Float = 70.0
    private var unitStr = "kg"
    
    private let weightLabel = UILabel()
    private let stepperContainer = UIStackView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    
    private let datePicker = UIDatePicker()
    private let quickTodayButton = UIButton(type: .system)
    private let saveButton = GradientButton(title: "Save Entry")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
        prefillWeight()
    }
    
    private func setupUI() {
        title = "Log Weight"
        
        weightLabel.font = .systemFont(ofSize: 56, weight: .bold)
        weightLabel.textColor = UIColor.appPrimary
        weightLabel.textAlignment = .center
        view.addSubview(weightLabel)
        
        // Minus Button
        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        minusButton.addTarget(self, action: #selector(handleMinus), for: .touchUpInside)
        
        // Plus Button
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        plusButton.addTarget(self, action: #selector(handlePlus), for: .touchUpInside)
        
        stepperContainer.axis = .horizontal
        stepperContainer.distribution = .fillEqually
        stepperContainer.spacing = 30
        stepperContainer.addArrangedSubview(minusButton)
        stepperContainer.addArrangedSubview(plusButton)
        view.addSubview(stepperContainer)
        
        // Date Picker (wheels style by default on iOS 12)
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        view.addSubview(datePicker)
        
        quickTodayButton.setTitle("Set to Today", for: .normal)
        quickTodayButton.titleLabel?.font = UIFont.appHeadline
        quickTodayButton.tintColor = UIColor.appSecondary
        quickTodayButton.addTarget(self, action: #selector(handleSetToday), for: .touchUpInside)
        view.addSubview(quickTodayButton)
        
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // Layout constraints
        weightLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 32, left: 16, bottom: 0, right: -16)
        )
        
        stepperContainer.anchor(
            top: weightLabel.bottomAnchor,
            padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0),
            size: CGSize(width: 160, height: 50)
        )
        stepperContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        datePicker.anchor(
            top: stepperContainer.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: -16)
        )
        
        quickTodayButton.anchor(
            top: datePicker.bottomAnchor,
            padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        )
        quickTodayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        saveButton.anchor(
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 32, bottom: -32, right: -32),
            size: CGSize(width: 0, height: 50)
        )
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
        minusButton.tintColor = UIColor.appPrimary
        plusButton.tintColor = UIColor.appPrimary
        datePicker.setValue(UIColor.appTextPrimary, forKey: "textColor") // Hack to fix wheel color
    }
    
    private func prefillWeight() {
        let settings = DataManager.shared.getSettings()
        unitStr = settings.weightUnit == 0 ? "kg" : "lbs"
        
        if let latest = DataManager.shared.latestWeight() {
            currentWeight = latest.weight
        } else {
            currentWeight = settings.goalWeight
        }
        
        updateWeightLabel()
    }
    
    private func updateWeightLabel() {
        weightLabel.text = String(format: "%.1f %@", currentWeight, unitStr)
    }
    
    @objc private func handleMinus() {
        if currentWeight > 10.0 {
            currentWeight -= 0.1
            updateWeightLabel()
        }
    }
    
    @objc private func handlePlus() {
        if currentWeight < 300.0 {
            currentWeight += 0.1
            updateWeightLabel()
        }
    }
    
    @objc private func handleSetToday() {
        datePicker.setDate(Date(), animated: true)
    }
    
    @objc private func handleSave() {
        let selectedDate = datePicker.date
        DataManager.shared.saveWeightEntry(weight: currentWeight, date: selectedDate)
        
        navigationController?.popViewController(animated: true)
    }
}
