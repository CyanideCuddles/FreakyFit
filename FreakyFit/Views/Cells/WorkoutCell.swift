import UIKit

class WorkoutCell: UITableViewCell {
    static let reuseIdentifier = "WorkoutCell"
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let detailsLabel = UILabel()
    private let chevronLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupThemeListener()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.roundCorners(radius: 12)
        containerView.addShadow(color: .black, opacity: 0.04, offset: CGSize(width: 0, height: 2), radius: 4)
        contentView.addSubview(containerView)
        
        nameLabel.font = UIFont.appHeadline
        nameLabel.textColor = UIColor.appTextPrimary
        
        detailsLabel.font = UIFont.appCaption
        detailsLabel.textColor = UIColor.appTextSecondary
        
        chevronLabel.text = "›"
        chevronLabel.font = .systemFont(ofSize: 24, weight: .light)
        chevronLabel.textColor = UIColor.appTextSecondary
        
        let labelStack = UIStackView(arrangedSubviews: [nameLabel, detailsLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        containerView.addSubview(labelStack)
        containerView.addSubview(chevronLabel)
        
        containerView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: -8, right: -16)
        )
        
        labelStack.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: chevronLabel.leadingAnchor,
            padding: UIEdgeInsets(top: 12, left: 16, bottom: -12, right: -8)
        )
        
        chevronLabel.anchor(
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16),
            size: CGSize(width: 12, height: 0)
        )
        chevronLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        applyThemeColors()
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
        containerView.backgroundColor = UIColor.appSurface
        nameLabel.textColor = UIColor.appTextPrimary
        detailsLabel.textColor = UIColor.appTextSecondary
        chevronLabel.textColor = UIColor.appTextSecondary
    }
    
    func configure(with workout: WorkoutTemplate) {
        let count = workout.exercisesArray.count
        let dayStr = workout.scheduleDaysString
        configure(name: workout.name ?? "Workout", exerciseCount: count, scheduledDays: dayStr)
    }
    
    func configure(name: String, exerciseCount: Int, scheduledDays: String) {
        nameLabel.text = name
        
        let exText = exerciseCount == 1 ? "1 exercise" : "\(exerciseCount) exercises"
        detailsLabel.text = "\(exText) • \(scheduledDays)"
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.1) {
            self.containerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}
