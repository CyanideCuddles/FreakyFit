import UIKit

class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    init(title: String, colors: [UIColor]? = nil) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.appButtonFont
        setTitleColor(.white, for: .normal)
        
        let gradientColors = colors ?? [.appPrimary, .appSecondary]
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = 25
        layer.insertSublayer(gradientLayer, at: 0)
        
        roundCorners(radius: 25)
        addShadow(color: .black, opacity: 0.15, offset: CGSize(width: 0, height: 4), radius: 6)
        
        // Touch events for animation
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func setGradientColors(_ colors: [UIColor]) {
        gradientLayer.colors = colors.map { $0.cgColor }
    }
    
    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: nil)
    }
    
    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.transform = .identity
        }, completion: nil)
    }
}
