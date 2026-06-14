import UIKit

class RestTimerView: UIView {
    var totalSeconds: Int = 60 {
        didSet {
            remainingSeconds = totalSeconds
            updateTimeLabel()
        }
    }
    
    var onTimerComplete: (() -> Void)?
    
    private var remainingSeconds = 60
    private var timer: Timer?
    private var isRunning = false
    
    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    private let controlButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    deinit {
        stop()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.appSurface
        roundCorners(radius: 20)
        addShadow(color: .black, opacity: 0.1, offset: CGSize(width: 0, height: 4), radius: 10)
        
        // Progress Arc setup
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.appSeparator.cgColor
        trackLayer.lineWidth = 10
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.appPrimary.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)
        
        // Labels
        titleLabel.text = "REST TIME"
        titleLabel.font = UIFont.appCaption
        titleLabel.textColor = UIColor.appTextSecondary
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        timeLabel.font = .systemFont(ofSize: 44, weight: .bold)
        timeLabel.textColor = UIColor.appTextPrimary
        timeLabel.textAlignment = .center
        addSubview(timeLabel)
        
        // Buttons
        controlButton.setTitle("Pause", for: .normal)
        controlButton.titleLabel?.font = UIFont.appHeadline
        controlButton.tintColor = UIColor.appSecondary
        controlButton.addTarget(self, action: #selector(toggleTimer), for: .touchUpInside)
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = UIFont.appHeadline
        skipButton.tintColor = UIColor.appDestructive
        skipButton.addTarget(self, action: #selector(skipTimer), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [controlButton, skipButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16
        addSubview(buttonStack)
        
        // Anchors
        titleLabel.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            trailing: trailingAnchor,
            padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: -16)
        )
        
        buttonStack.anchor(
            leading: leadingAnchor,
            bottom: bottomAnchor,
            trailing: trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 24, bottom: -24, right: -24),
            size: CGSize(width: 0, height: 44)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = min(bounds.width, bounds.height) * 0.55
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY - 10)
        let radius = (size - 10) / 2
        
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
        
        timeLabel.center = centerPoint
        timeLabel.bounds = CGRect(x: 0, y: 0, width: size - 20, height: 60)
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        controlButton.setTitle("Pause", for: .normal)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        controlButton.setTitle("Resume", for: .normal)
    }
    
    func resume() {
        start()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    @objc private func toggleTimer() {
        if isRunning {
            pause()
        } else {
            resume()
        }
    }
    
    @objc private func skipTimer() {
        stop()
        onTimerComplete?()
    }
    
    private func tick() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateTimeLabel()
            
            // Animate progress path
            let progress = CGFloat(remainingSeconds) / CGFloat(totalSeconds)
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            progressLayer.strokeEnd = progress
            CATransaction.commit()
            
            if remainingSeconds == 0 {
                complete()
            }
        }
    }
    
    private func complete() {
        stop()
        // Haptic feedback (AudioServicesPlaySystemSound standard for compatibility)
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = .identity
            }) { _ in
                self.onTimerComplete?()
            }
        }
    }
    
    private func updateTimeLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
