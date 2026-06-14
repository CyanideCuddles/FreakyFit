import UIKit

class SetCell: UITableViewCell {
    static let reuseIdentifier = "SetCell"
    
    var onToggleCompletion: (() -> Void)?
    
    private let setNumberLabel = UILabel()
    private let statsTextField = UITextField()
    private let checkButton = UIButton(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        setNumberLabel.font = UIFont.appHeadline
        setNumberLabel.textColor = UIColor.appTextPrimary
        contentView.addSubview(setNumberLabel)
        
        statsTextField.font = UIFont.appBody
        statsTextField.textColor = UIColor.appTextPrimary
        statsTextField.textAlignment = .center
        statsTextField.borderStyle = .none
        statsTextField.isUserInteractionEnabled = false // Reads only
        contentView.addSubview(statsTextField)
        
        checkButton.layer.borderWidth = 2
        checkButton.layer.borderColor = UIColor.appSeparator.cgColor
        checkButton.layer.cornerRadius = 15
        checkButton.clipsToBounds = true
        checkButton.addTarget(self, action: #selector(handleCheck), for: .touchUpInside)
        contentView.addSubview(checkButton)
        
        setNumberLabel.anchor(
            leading: contentView.leadingAnchor,
            padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        )
        setNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        statsTextField.centerInSuperview()
        
        checkButton.anchor(
            trailing: contentView.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16),
            size: CGSize(width: 30, height: 30)
        )
        checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    @objc private func handleCheck() {
        onToggleCompletion?()
    }
    
    func configure(
        setNumber: Int,
        targetReps: Int,
        isCompleted: Bool,
        weight: Float,
        actualReps: Int
    ) {
        setNumberLabel.text = "Set \(setNumber)"
        
        let repVal = isCompleted ? actualReps : targetReps
        if weight > 0 {
            statsTextField.text = "\(weight) kg × \(repVal)"
        } else {
            statsTextField.text = "\(repVal) reps"
        }
        
        if isCompleted {
            checkButton.backgroundColor = UIColor.appSuccess
            checkButton.layer.borderColor = UIColor.appSuccess.cgColor
            
            // Checkmark unicode text
            checkButton.setTitle("✓", for: .normal)
            checkButton.setTitleColor(.white, for: .normal)
            checkButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            
            setNumberLabel.alpha = 0.5
            statsTextField.alpha = 0.5
        } else {
            checkButton.backgroundColor = .clear
            checkButton.layer.borderColor = UIColor.appSeparator.cgColor
            checkButton.setTitle("", for: .normal)
            
            setNumberLabel.alpha = 1.0
            statsTextField.alpha = 1.0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onToggleCompletion = nil
        checkButton.setTitle("", for: .normal)
        checkButton.backgroundColor = .clear
        checkButton.layer.borderColor = UIColor.appSeparator.cgColor
    }
}
