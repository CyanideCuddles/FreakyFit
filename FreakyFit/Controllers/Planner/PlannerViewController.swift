import UIKit

class PlannerViewController: UIViewController {
    
    private let dayStack = UIStackView()
    private let tableView = UITableView()
    private let emptyView = EmptyStateView(
        icon: "📋",
        title: "No Templates Yet",
        message: "Tap + to create a custom workout plan!"
    )
    
    private var selectedDayFilter: Int16 = 0 // 0 = All, 2 = Mon, ..., 1 = Sun (Calendar standard)
    private var allTemplates: [WorkoutTemplate] = []
    private var filteredTemplates: [WorkoutTemplate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        title = "Planner"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleAddWorkout)
        )
        
        // Days stack filter setup (All, Mon, Tue, Wed, Thu, Fri, Sat, Sun)
        dayStack.axis = .horizontal
        dayStack.distribution = .fillEqually
        dayStack.spacing = 4
        view.addSubview(dayStack)
        
        setupDayFilterButtons()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(WorkoutCell.self, forCellReuseIdentifier: WorkoutCell.reuseIdentifier)
        view.addSubview(tableView)
        
        view.addSubview(emptyView)
        
        dayStack.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: -8),
            size: CGSize(width: 0, height: 36)
        )
        
        tableView.anchor(
            top: dayStack.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        )
        
        emptyView.centerInSuperview()
        emptyView.onButtonTap = { [weak self] in
            self?.handleAddWorkout()
        }
    }
    
    private func setupDayFilterButtons() {
        // Order: All (0), Mon (2), Tue (3), Wed (4), Thu (5), Fri (6), Sat (7), Sun (1)
        let days: [(title: String, code: Int16)] = [
            ("All", 0), ("M", 2), ("T", 3), ("W", 4), ("T", 5), ("F", 6), ("S", 7), ("S", 1)
        ]
        
        for day in days {
            let btn = UIButton(type: .custom)
            btn.setTitle(day.title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            btn.tag = Int(day.code)
            btn.addTarget(self, action: #selector(handleDayFilterTap(_:)), for: .touchUpInside)
            btn.roundCorners(radius: 6)
            
            dayStack.addArrangedSubview(btn)
        }
        
        // Match dayOfWeek today initially
        let todayVal = Int16(Date().dayOfWeek)
        selectedDayFilter = todayVal
        
        updateFilterButtonHighlighting()
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
        tableView.backgroundColor = UIColor.appBackground
        updateFilterButtonHighlighting()
    }
    
    private func updateFilterButtonHighlighting() {
        for view in dayStack.arrangedSubviews {
            if let btn = view as? UIButton {
                let isSelected = btn.tag == Int(selectedDayFilter)
                if isSelected {
                    btn.backgroundColor = UIColor.appPrimary
                    btn.setTitleColor(.white, for: .normal)
                } else {
                    btn.backgroundColor = UIColor.appSurface
                    btn.setTitleColor(UIColor.appTextSecondary, for: .normal)
                }
            }
        }
    }
    
    private func loadData() {
        allTemplates = DataManager.shared.fetchAllWorkoutTemplates()
        filterTemplates()
    }
    
    private func filterTemplates() {
        if selectedDayFilter == 0 {
            filteredTemplates = allTemplates
        } else {
            filteredTemplates = allTemplates.filter { template in
                template.scheduleDaysArray.contains { $0.dayOfWeek == selectedDayFilter }
            }
        }
        
        tableView.reloadData()
        
        let hasData = !filteredTemplates.isEmpty
        tableView.isHidden = !hasData
        emptyView.isHidden = hasData
    }
    
    @objc private func handleDayFilterTap(_ sender: UIButton) {
        selectedDayFilter = Int16(sender.tag)
        updateFilterButtonHighlighting()
        filterTemplates()
    }
    
    @objc private func handleAddWorkout() {
        let alert = UIAlertController(
            title: "New Workout",
            message: "Enter a name for this workout template",
            preferredStyle: .alert
        )
        
        alert.addTextField { field in
            field.placeholder = "e.g., Push Day, Cardio"
            field.autocapitalizationType = .words
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let save = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            let template = DataManager.shared.createWorkoutTemplate(name: name, notes: nil)
            
            // Navigate directly to editing this new template
            let detailVC = WorkoutDetailViewController()
            detailVC.workoutTemplate = template
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        present(alert, animated: true)
    }
}

// MARK: - TableView Methods
extension PlannerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutCell.reuseIdentifier, for: indexPath) as? WorkoutCell else {
            return UITableViewCell()
        }
        
        let template = filteredTemplates[indexPath.row]
        cell.configure(with: template)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let template = filteredTemplates[indexPath.row]
        let detailVC = WorkoutDetailViewController()
        detailVC.workoutTemplate = template
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let template = filteredTemplates[indexPath.row]
            
            let confirm = UIAlertController(
                title: "Delete Template?",
                message: "Are you sure you want to delete '\(template.name ?? "")'? This will not delete your logged workout history.",
                preferredStyle: .actionSheet
            )
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                DataManager.shared.deleteWorkoutTemplate(template)
                self?.loadData()
            }
            
            confirm.addAction(delete)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(confirm, animated: true)
        }
    }
}
