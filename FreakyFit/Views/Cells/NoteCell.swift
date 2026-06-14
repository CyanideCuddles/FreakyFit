import UIKit

class NoteCell: UITableViewCell {
    static let reuseIdentifier = "NoteCell"
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let bodyPreviewLabel = UILabel()
    private let dateLabel = UILabel()
    private let categoryBadge = UILabel()
    
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
        
        titleLabel.font = UIFont.appHeadline
        titleLabel.textColor = UIColor.appTextPrimary
        
        bodyPreviewLabel.font = UIFont.appCaption
        bodyPreviewLabel.textColor = UIColor.appTextSecondary
        bodyPreviewLabel.numberOfLines = 2
        
        dateLabel.font = .systemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = UIColor.appTextSecondary
        
        categoryBadge.font = .systemFont(ofSize: 10, weight: .bold)
        categoryBadge.textColor = .white
        categoryBadge.textAlignment = .center
        categoryBadge.layer.cornerRadius = 4
        categoryBadge.clipsToBounds = true
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(bodyPreviewLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(categoryBadge)
        
        containerView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 6, left: 16, bottom: -6, right: -16)
        )
        
        titleLabel.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            trailing: categoryBadge.leadingAnchor,
            padding: UIEdgeInsets(top: 12, left: 16, bottom: 0, right: -8)
        )
        
        categoryBadge.anchor(
            top: containerView.topAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: -16),
            size: CGSize(width: 70, height: 18)
        )
        
        bodyPreviewLabel.anchor(
            top: titleLabel.bottomAnchor,
            leading: containerView.leadingAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: 6, left: 16, bottom: 0, right: -16)
        )
        
        dateLabel.anchor(
            top: bodyPreviewLabel.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: -12, right: -16)
        )
        
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
        titleLabel.textColor = UIColor.appTextPrimary
        bodyPreviewLabel.textColor = UIColor.appTextSecondary
        dateLabel.textColor = UIColor.appTextSecondary
    }
    
    func configure(with note: Note) {
        titleLabel.text = (note.title == nil || note.title!.isEmpty) ? "Untitled Note" : note.title
        bodyPreviewLabel.text = (note.content == nil || note.content!.isEmpty) ? "No content" : note.content
        
        if let updated = note.updatedAt {
            dateLabel.text = updated.relativeString
        } else {
            dateLabel.text = ""
        }
        
        let cat = note.category?.lowercased() ?? "workout"
        if cat == "workout" {
            categoryBadge.text = "WORKOUT"
            categoryBadge.backgroundColor = UIColor.appSecondary
        } else {
            categoryBadge.text = "BODY"
            categoryBadge.backgroundColor = UIColor.appWarning
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.1) {
            self.containerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}
