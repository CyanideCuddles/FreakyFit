import UIKit

class ExerciseCell: UITableViewCell {
    static let reuseIdentifier = "ExerciseCell"
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let statsLabel = UILabel()
    private let restLabel = UILabel()
    
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
        containerView.addShadow(color: .black, opacity: 0.03, offset: CGSize(width: 0, height: 1), radius: 3)
        contentView.addSubview(containerView)
        
        nameLabel.font = UIFont.appHeadline
        nameLabel.textColor = UIColor.appTextPrimary
        
        statsLabel.font = UIFont.appCallout
        statsLabel.textColor = UIColor.appSecondary
        
        restLabel.font = UIFont.appCaption
        restLabel.textColor = UIColor.appTextSecondary
        
        let labelStack = UIStackView(arrangedSubviews: [nameLabel, restLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        containerView.addSubview(labelStack)
        containerView.addSubview(statsLabel)
        
        containerView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 4, left: 16, bottom: -4, right: -16)
        )
        
        labelStack.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: statsLabel.leadingAnchor,
            padding: UIEdgeInsets(top: 12, left: 16, bottom: -12, right: -8)
        )
        
        statsLabel.anchor(
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        )
        statsLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
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
        statsLabel.textColor = UIColor.appSecondary
        restLabel.textColor = UIColor.appTextSecondary
    }
    
    func configure(with exercise: ExerciseTemplate) {
        nameLabel.text = exercise.name ?? "Exercise"
        statsLabel.text = "\(exercise.sets)x\(exercise.reps)"
        restLabel.text = "Rest: \(exercise.restSeconds)s"
    }
}
