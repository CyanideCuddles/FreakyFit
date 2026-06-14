import UIKit

class WeightLogCell: UITableViewCell {
    static let reuseIdentifier = "WeightLogCell"
    
    private let containerView = UIView()
    private let weightLabel = UILabel()
    private let dateLabel = UILabel()
    
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
        
        weightLabel.font = UIFont.appTitle
        weightLabel.textColor = UIColor.appPrimary
        containerView.addSubview(weightLabel)
        
        dateLabel.font = UIFont.appCallout
        dateLabel.textColor = UIColor.appTextSecondary
        containerView.addSubview(dateLabel)
        
        containerView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 4, left: 16, bottom: -4, right: -16)
        )
        
        weightLabel.anchor(
            leading: containerView.leadingAnchor,
            padding: UIEdgeInsets(top: 12, left: 16, bottom: -12, right: 0)
        )
        weightLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        dateLabel.anchor(
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        )
        dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
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
        dateLabel.textColor = UIColor.appTextSecondary
    }
    
    func configure(with entry: WeightEntry, unit: String) {
        weightLabel.text = String(format: "%.1f %@", entry.weight, unit)
        if let entryDate = entry.date {
            dateLabel.text = entryDate.relativeString
        } else {
            dateLabel.text = ""
        }
    }
}
