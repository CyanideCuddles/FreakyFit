import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var settings: UserSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
    }
    
    private func setupUI() {
        title = "Settings"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.fillSuperview()
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
        tableView.reloadData()
    }
    
    private func loadSettings() {
        settings = DataManager.shared.getSettings()
        tableView.reloadData()
    }
    
    private func saveSettings() {
        DataManager.shared.saveSettings(settings)
    }
    
    @objc private func handleDarkModeToggle(_ sender: UISwitch) {
        ThemeManager.shared.setDarkMode(sender.isOn)
        settings.darkModeEnabled = sender.isOn
        saveSettings()
    }
    
    @objc private func handleNotificationsToggle(_ sender: UISwitch) {
        settings.notificationsEnabled = sender.isOn
        saveSettings()
        
        let time = settings.reminderTime ?? "07:00"
        NotificationManager.shared.updateNotificationSettings(enabled: sender.isOn, time: time)
    }
    
    private func changeGoalWeight() {
        let alert = UIAlertController(
            title: "Goal Weight",
            message: "Enter your target goal weight.",
            preferredStyle: .alert
        )
        
        alert.addTextField { [weak self] field in
            field.placeholder = "Goal"
            field.keyboardType = .decimalPad
            field.text = String(format: "%.1f", self?.settings.goalWeight ?? 70.0)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let val = Float(text) else { return }
            
            self.settings.goalWeight = val
            self.saveSettings()
            self.tableView.reloadData()
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        present(alert, animated: true)
    }
    
    private func selectReminderTime() {
        let alert = UIAlertController(
            title: "Reminder Time",
            message: "\n\n\n\n\n\n\n\n\n", // Space hack to fit picker subview on iOS 12
            preferredStyle: .alert
        )
        
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.minuteInterval = 5
        
        // Load current time
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let timeStr = settings.reminderTime, let date = formatter.date(from: timeStr) {
            picker.setDate(date, animated: false)
        }
        
        alert.view.addSubview(picker)
        picker.anchor(
            top: alert.view.topAnchor,
            leading: alert.view.leadingAnchor,
            trailing: alert.view.trailingAnchor,
            padding: UIEdgeInsets(top: 44, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 160)
        )
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let timeStr = picker.date.formatted(as: "HH:mm")
            self.settings.reminderTime = timeStr
            self.saveSettings()
            
            if self.settings.notificationsEnabled {
                NotificationManager.shared.scheduleDailyReminder(at: timeStr)
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        present(alert, animated: true)
    }
    
    private func resetAllData() {
        let alert1 = UIAlertController(
            title: "Reset All Data?",
            message: "This will permanently delete your templates, weight logs, history, and notes. This action is irreversible.",
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let proceed = UIAlertAction(title: "Delete Everything", style: .destructive) { [weak self] _ in
            self?.showFinalResetConfirmation()
        }
        
        alert1.addAction(cancel)
        alert1.addAction(proceed)
        
        present(alert1, animated: true)
    }
    
    private func showFinalResetConfirmation() {
        let alert2 = UIAlertController(
            title: "Final Confirmation",
            message: "Type 'RESET' to confirm deletion.",
            preferredStyle: .alert
        )
        
        alert2.addTextField { field in
            field.placeholder = "RESET"
            field.autocapitalizationType = .allCharacters
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "RESET", style: .destructive) { [weak self] _ in
            guard let text = alert2.textFields?.first?.text, text == "RESET" else { return }
            
            DataManager.shared.resetAllData()
            self?.loadSettings()
            
            // Go back to home dashboard
            self?.tabBarController?.selectedIndex = 0
        }
        
        alert2.addAction(cancel)
        alert2.addAction(delete)
        
        present(alert2, animated: true)
    }
}

// MARK: - TableView Methods
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 // Profile (Goal weight, Units)
        case 1: return 1 // Appearance (Dark mode)
        case 2: return 2 // Notifications (Enabled, Time)
        case 3: return 1 // Data (Reset)
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Profile & Goals"
        case 1: return "Appearance"
        case 2: return "Notifications"
        case 3: return "Data Operations"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingsCell")
        cell.backgroundColor = UIColor.appSurface
        cell.textLabel?.textColor = UIColor.appTextPrimary
        cell.detailTextLabel?.textColor = UIColor.appTextSecondary
        cell.selectionStyle = .none
        
        guard settings != nil else { return cell }
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Goal Weight"
                let unit = settings.weightUnit == 0 ? "kg" : "lbs"
                cell.detailTextLabel?.text = String(format: "%.1f %@", settings.goalWeight, unit)
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "Weight Unit"
                cell.detailTextLabel?.text = settings.weightUnit == 0 ? "Kilograms (kg)" : "Pounds (lbs)"
                cell.accessoryType = .disclosureIndicator
            }
        case 1:
            cell.textLabel?.text = "In-App Dark Mode"
            let sw = UISwitch()
            sw.isOn = ThemeManager.shared.isDarkMode
            sw.addTarget(self, action: #selector(handleDarkModeToggle(_:)), for: .valueChanged)
            cell.accessoryView = sw
        case 2:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Daily Workout Reminder"
                let sw = UISwitch()
                sw.isOn = settings.notificationsEnabled
                sw.addTarget(self, action: #selector(handleNotificationsToggle(_:)), for: .valueChanged)
                cell.accessoryView = sw
            } else {
                cell.textLabel?.text = "Reminder Time"
                cell.detailTextLabel?.text = settings.reminderTime ?? "07:00"
                cell.accessoryType = .disclosureIndicator
                cell.isUserInteractionEnabled = settings.notificationsEnabled
                cell.textLabel?.alpha = settings.notificationsEnabled ? 1.0 : 0.5
                cell.detailTextLabel?.alpha = settings.notificationsEnabled ? 1.0 : 0.5
            }
        case 3:
            cell.textLabel?.text = "Reset All Data"
            cell.textLabel?.textColor = UIColor.appDestructive
            cell.detailTextLabel?.text = ""
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                changeGoalWeight()
            } else {
                settings.weightUnit = settings.weightUnit == 0 ? 1 : 0
                saveSettings()
                tableView.reloadData()
            }
        case 2:
            if indexPath.row == 1 {
                selectReminderTime()
            }
        case 3:
            resetAllData()
        default:
            break
        }
    }
}
