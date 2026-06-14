import UIKit

class EmptyStateView: UIView {
    var onButtonTap: (() -> Void)?
    
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private var actionButton: GradientButton?
    
    init(icon: String, title: String, message: String, buttonTitle: String? = nil) {
        super.init(frame: .zero)
        setupUI(icon: icon, title: title, message: message, buttonTitle: buttonTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(icon: String, title: String, message: String, buttonTitle: String?) {
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 52)
        iconLabel.textAlignment = .center
        
        titleLabel.text = title
        titleLabel.font = UIFont.appTitle
        titleLabel.textColor = UIColor.appTextPrimary
        titleLabel.textAlignment = .center
        
        messageLabel.text = message
        messageLabel.font = UIFont.appBody
        messageLabel.textColor = UIColor.appTextSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [iconLabel, titleLabel, messageLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        
        addSubview(stackView)
        stackView.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            trailing: trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 24, bottom: 0, right: -24)
        )
        
        if let btnTitle = buttonTitle {
            let button = GradientButton(title: btnTitle)
            button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
            addSubview(button)
            
            button.anchor(
                top: stackView.bottomAnchor,
                leading: leadingAnchor,
                bottom: bottomAnchor,
                trailing: trailingAnchor,
                padding: UIEdgeInsets(top: 24, left: 32, bottom: -24, right: -32),
                size: CGSize(width: 0, height: 50)
            )
            
            actionButton = button
        } else {
            stackView.anchor(bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: -24, right: 0))
        }
    }
    
    @objc private func handleTap() {
        onButtonTap?()
    }
}
