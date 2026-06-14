import UIKit

class ProgressViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let weightHeader = UILabel()
    private let chartCard = UIView()
    private let chartView = SimpleChartView()
    
    private let weightProgressHeader = UILabel()
    private let currentWeightCard = StatCard(icon: "⚖️", title: "Current", value: "--")
    private let goalWeightCard = StatCard(icon: "🎯", title: "Goal", value: "--")
    private let logWeightButton = GradientButton(title: "Log New Weight")
    
    private let statsHeader = UILabel()
    private let currentStreakCard = StatCard(icon: "🔥", title: "Streak", value: "0 days")
    private let longestStreakCard = StatCard(icon: "🏆", title: "Longest", value: "0 days")
    private let totalWorkoutsCard = StatCard(icon: "💪", title: "Total logs", value: "0")
    private let completionRateCard = StatCard(icon: "📈", title: "Completion", value: "0%")
    
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
        title = "Progress"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.fillSuperview()
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        weightHeader.text = "WEIGHT ANALYSIS"
        weightHeader.font = UIFont.appCaption
        weightHeader.textColor = UIColor.appTextSecondary
        contentView.addSubview(weightHeader)
        
        chartCard.roundCorners(radius: 12)
        chartCard.addShadow(color: .black, opacity: 0.04, offset: CGSize(width: 0, height: 2), radius: 6)
        contentView.addSubview(chartCard)
        
        chartView.roundCorners(radius: 8)
        chartCard.addSubview(chartView)
        
        weightProgressHeader.text = "GOAL TRACKING"
        weightProgressHeader.font = UIFont.appCaption
        weightProgressHeader.textColor = UIColor.appTextSecondary
        contentView.addSubview(weightProgressHeader)
        
        let goalStack = UIStackView(arrangedSubviews: [currentWeightCard, goalWeightCard])
        goalStack.axis = .horizontal
        goalStack.distribution = .fillEqually
        goalStack.spacing = 10
        contentView.addSubview(goalStack)
        
        logWeightButton.addTarget(self, action: #selector(handleLogWeight), for: .touchUpInside)
        contentView.addSubview(logWeightButton)
        
        statsHeader.text = "WORKOUT METRICS"
        statsHeader.font = UIFont.appCaption
        statsHeader.textColor = UIColor.appTextSecondary
        contentView.addSubview(statsHeader)
        
        let gridRow1 = UIStackView(arrangedSubviews: [currentStreakCard, longestStreakCard])
        gridRow1.axis = .horizontal
        gridRow1.distribution = .fillEqually
        gridRow1.spacing = 10
        
        let gridRow2 = UIStackView(arrangedSubviews: [totalWorkoutsCard, completionRateCard])
        gridRow2.axis = .horizontal
        gridRow2.distribution = .fillEqually
        gridRow2.spacing = 10
        
        let statsStack = UIStackView(arrangedSubviews: [gridRow1, gridRow2])
        statsStack.axis = .vertical
        statsStack.distribution = .fillEqually
        statsStack.spacing = 10
        contentView.addSubview(statsStack)
        
        // Setup Anchors
        weightHeader.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: -16)
        )
        
        chartCard.anchor(
            top: weightHeader.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 180)
        )
        chartView.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10))
        
        weightProgressHeader.anchor(
            top: chartCard.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: -16)
        )
        
        goalStack.anchor(
            top: weightProgressHeader.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 90)
        )
        
        logWeightButton.anchor(
            top: goalStack.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 12, left: 24, bottom: 0, right: -24),
            size: CGSize(width: 0, height: 50)
        )
        
        statsHeader.anchor(
            top: logWeightButton.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: -16)
        )
        
        statsStack.anchor(
            top: statsHeader.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: -24, right: -16),
            size: CGSize(width: 0, height: 190)
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
        contentView.backgroundColor = UIColor.appBackground
        weightHeader.textColor = UIColor.appTextSecondary
        chartCard.backgroundColor = UIColor.appSurface
        weightProgressHeader.textColor = UIColor.appTextSecondary
        statsHeader.textColor = UIColor.appTextSecondary
    }
    
    private func loadData() {
        let settings = DataManager.shared.getSettings()
        let unit = settings.weightUnit == 0 ? "kg" : "lbs"
        
        // Weight logs
        let entries = DataManager.shared.fetchWeightEntries()
        let weights = entries.map { CGFloat($0.weight) }
        let dates = entries.compactMap { $0.date?.formatted(as: "MM/dd") }
        
        chartView.dataPoints = weights
        chartView.labels = dates
        chartView.animateChart()
        
        // Update labels
        if let last = DataManager.shared.latestWeight() {
            currentWeightCard.updateValue(String(format: "%.1f %@", last.weight, unit))
        } else {
            currentWeightCard.updateValue("--")
        }
        
        goalWeightCard.updateValue(String(format: "%.1f %@", settings.goalWeight, unit))
        
        // Streak counts
        let streak = DataManager.shared.currentStreak()
        currentStreakCard.updateValue(streak == 1 ? "1 day" : "\(streak) days")
        
        let longest = DataManager.shared.longestStreak()
        longestStreakCard.updateValue(longest == 1 ? "1 day" : "\(longest) days")
        
        let total = DataManager.shared.totalWorkoutsCompleted()
        totalWorkoutsCard.updateValue("\(total)")
        
        // Calculate completion avg
        let logs = DataManager.shared.fetchWorkoutHistory(limit: 50)
        if !logs.isEmpty {
            let totalPct = logs.reduce(0.0) { $0 + $1.completionPercent }
            let avg = totalPct / Float(logs.count)
            completionRateCard.updateValue(String(format: "%.0f%%", avg * 100))
        } else {
            completionRateCard.updateValue("0%")
        }
    }
    
    @objc private func handleLogWeight() {
        let entryVC = WeightEntryViewController()
        navigationController?.pushViewController(entryVC, animated: true)
    }
}
