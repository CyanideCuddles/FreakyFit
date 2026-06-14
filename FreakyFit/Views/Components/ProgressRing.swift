import UIKit

class ProgressRing: UIView {
    var progressColor: UIColor = .appPrimary {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
    var trackColor: UIColor = .appSeparator {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    var lineWidth: CGFloat = 8.0 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }
    
    let centerLabel = UILabel()
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var currentProgress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabel()
    }
    
    private func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func setupLabel() {
        centerLabel.font = UIFont.appHeadline
        centerLabel.textAlignment = .center
        centerLabel.textColor = .appTextPrimary
        centerLabel.text = "0%"
        addSubview(centerLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        
        let path = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        )
        
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        
        centerLabel.frame = bounds
        applyColors()
    }
    
    private func applyColors() {
        trackLayer.strokeColor = trackColor.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        centerLabel.textColor = UIColor.appTextPrimary
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool) {
        let clampedProgress = max(0.0, min(1.0, progress))
        currentProgress = clampedProgress
        
        centerLabel.text = String(format: "%.0f%%", clampedProgress * 100)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedProgress
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = clampedProgress
            progressLayer.add(animation, forKey: "progressAnim")
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.strokeEnd = clampedProgress
            CATransaction.commit()
        }
    }
}
