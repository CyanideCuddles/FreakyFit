import UIKit

class StatCard: UIView {
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    init(icon: String, title: String, value: String) {
        super.init(frame: .zero)
        
        setupUI(icon: icon, title: title, value: value)
        setupThemeListener()
        applyThemeColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI(icon: String, title: String, value: String) {
        roundCorners(radius: 12)
        addShadow(color: .black, opacity: 0.06, offset: CGSize(width: 0, height: 2), radius: 6)
        
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 22)
        
        titleLabel.text = title.uppercased()
        titleLabel.font = UIFont.appCaption
        titleLabel.textColor = UIColor.appTextSecondary
        
        valueLabel.text = value
        valueLabel.font = UIFont.appTitle
        valueLabel.textColor = UIColor.appTextPrimary
        
        let stackView = UIStackView(arrangedSubviews: [iconLabel, titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            trailing: trailingAnchor,
            padding: UIEdgeInsets(top: 12, left: 12, bottom: -12, right: -12)
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
        backgroundColor = UIColor.appSurface
        valueLabel.textColor = UIColor.appTextPrimary
        titleLabel.textColor = UIColor.appTextSecondary
    }
    
    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}
