import UIKit

class HomeViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let greetingLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let todaySectionHeader = UILabel()
    private let todayCard = UIView()
    private let todayWorkoutNameLabel = UILabel()
    private let todayWorkoutDetailsLabel = UILabel()
    private let startButton = GradientButton(title: "Start Workout")
    private let emptyTodayView = EmptyStateView(
        icon: "💤",
        title: "No Workout Scheduled",
        message: "Enjoy your rest day or plan a new session!"
    )
    
    private let statsHeaderLabel = UILabel()
    private let streakCard = StatCard(icon: "🔥", title: "Streak", value: "0 days")
    private let totalCompletedCard = StatCard(icon: "💪", title: "Total logs", value: "0")
    private let lastWeightCard = StatCard(icon: "⚖️", title: "Weight", value: "--")
    
    private var todaysWorkouts: [WorkoutTemplate] = []
    
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
        title = "Dashboard"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.fillSuperview()
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        greetingLabel.font = UIFont.appBody
        greetingLabel.textColor = UIColor.appTextSecondary
        contentView.addSubview(greetingLabel)
        
        titleLabel.text = "FreakyFit"
        titleLabel.font = UIFont.appLargeTitle
        titleLabel.textColor = UIColor.appTextPrimary
        contentView.addSubview(titleLabel)
        
        todaySectionHeader.text = "TODAY'S TEMPLATE"
        todaySectionHeader.font = UIFont.appCaption
        todaySectionHeader.textColor = UIColor.appTextSecondary
        contentView.addSubview(todaySectionHeader)
        
        // Today card
        todayCard.roundCorners(radius: 12)
        todayCard.addShadow(color: .black, opacity: 0.05, offset: CGSize(width: 0, height: 2), radius: 6)
        contentView.addSubview(todayCard)
        
        todayWorkoutNameLabel.font = UIFont.appTitle
        todayWorkoutNameLabel.textColor = UIColor.appTextPrimary
        todayCard.addSubview(todayWorkoutNameLabel)
        
        todayWorkoutDetailsLabel.font = UIFont.appBody
        todayWorkoutDetailsLabel.textColor = UIColor.appTextSecondary
        todayCard.addSubview(todayWorkoutDetailsLabel)
        
        startButton.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        todayCard.addSubview(startButton)
        
        contentView.addSubview(emptyTodayView)
        
        statsHeaderLabel.text = "YOUR METRICS"
        statsHeaderLabel.font = UIFont.appCaption
        statsHeaderLabel.textColor = UIColor.appTextSecondary
        contentView.addSubview(statsHeaderLabel)
        
        let statsStack = UIStackView(arrangedSubviews: [streakCard, totalCompletedCard, lastWeightCard])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 10
        contentView.addSubview(statsStack)
        
        // Anchoring layout constraints
        greetingLabel.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: -16)
        )
        
        titleLabel.anchor(
            top: greetingLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 4, left: 16, bottom: 0, right: -16)
        )
        
        todaySectionHeader.anchor(
            top: titleLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: -16)
        )
        
        todayCard.anchor(
            top: todaySectionHeader.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: -16)
        )
        
        todayWorkoutNameLabel.anchor(
            top: todayCard.topAnchor,
            leading: todayCard.leadingAnchor,
            trailing: todayCard.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        )
        
        todayWorkoutDetailsLabel.anchor(
            top: todayWorkoutNameLabel.bottomAnchor,
            leading: todayCard.leadingAnchor,
            trailing: todayCard.trailingAnchor,
            padding: UIEdgeInsets(top: 4, left: 16, bottom: 0, right: -16)
        )
        
        startButton.anchor(
            top: todayWorkoutDetailsLabel.bottomAnchor,
            leading: todayCard.leadingAnchor,
            bottom: todayCard.bottomAnchor,
            trailing: todayCard.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16),
            size: CGSize(width: 0, height: 50)
        )
        
        emptyTodayView.anchor(
            top: todaySectionHeader.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: -16)
        )
        
        statsHeaderLabel.anchor(
            top: todayCard.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: -16)
        )
        
        statsStack.anchor(
            top: statsHeaderLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: -24, right: -16),
            size: CGSize(width: 0, height: 100)
        )
        
        // Define dual layouts for empty/full templates
        emptyTodayView.onButtonTap = { [weak self] in
            self?.tabBarController?.selectedIndex = 1 // Go to Planner
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
        titleLabel.textColor = UIColor.appTextPrimary
        greetingLabel.textColor = UIColor.appTextSecondary
        todaySectionHeader.textColor = UIColor.appTextSecondary
        todayCard.backgroundColor = UIColor.appSurface
        todayWorkoutNameLabel.textColor = UIColor.appTextPrimary
        todayWorkoutDetailsLabel.textColor = UIColor.appTextSecondary
        statsHeaderLabel.textColor = UIColor.appTextSecondary
    }
    
    private func loadData() {
        // Update greeting based on system hours
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            greetingLabel.text = "GOOD MORNING"
        } else if hour < 17 {
            greetingLabel.text = "GOOD AFTERNOON"
        } else {
            greetingLabel.text = "GOOD EVENING"
        }
        
        todaysWorkouts = DataManager.shared.fetchTodaysWorkouts()
        
        if let todayWorkout = todaysWorkouts.first {
            todayCard.isHidden = false
            emptyTodayView.isHidden = true
            
            todayWorkoutNameLabel.text = todayWorkout.name
            let exCount = todayWorkout.exercisesArray.count
            todayWorkoutDetailsLabel.text = exCount == 1 ? "1 exercise scheduled" : "\(exCount) exercises scheduled"
            
            // Adjust card bottom constraints dynamically
            statsHeaderLabel.setValue(todayCard.bottomAnchor, forKey: "topAnchor")
        } else {
            todayCard.isHidden = true
            emptyTodayView.isHidden = false
            
            statsHeaderLabel.setValue(emptyTodayView.bottomAnchor, forKey: "topAnchor")
        }
        
        // Load metric counts
        let streak = DataManager.shared.currentStreak()
        streakCard.updateValue(streak == 1 ? "1 day" : "\(streak) days")
        
        let total = DataManager.shared.totalWorkoutsCompleted()
        totalCompletedCard.updateValue("\(total)")
        
        let settings = DataManager.shared.getSettings()
        let unit = settings.weightUnit == 0 ? "kg" : "lbs"
        
        if let weight = DataManager.shared.latestWeight() {
            lastWeightCard.updateValue(String(format: "%.1f %@", weight.weight, unit))
        } else {
            lastWeightCard.updateValue("--")
        }
    }
    
    @objc private func handleStart() {
        guard let todayWorkout = todaysWorkouts.first else { return }
        
        let activeVC = ActiveWorkoutViewController()
        activeVC.workoutTemplate = todayWorkout
        activeVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(activeVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        CoreDataStack.shared.viewContext.reset()
    }
}
