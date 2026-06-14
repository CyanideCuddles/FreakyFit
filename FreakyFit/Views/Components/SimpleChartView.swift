import UIKit

class SimpleChartView: UIView {
    var dataPoints: [CGFloat] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    var labels: [String] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    var lineColor: UIColor = .appPrimary
    var fillColor: UIColor = .appPrimary
    var showDots: Bool = true
    
    private let lineLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()
    private var dotLayers: [CALayer] = []
    private let emptyLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        fillLayer.fillColor = fillColor.withAlphaComponent(0.15).cgColor
        fillLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(fillLayer)
        
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3.0
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        layer.addSublayer(lineLayer)
        
        emptyLabel.text = "Log weight to view chart progress"
        emptyLabel.font = UIFont.appBody
        emptyLabel.textColor = UIColor.appTextSecondary
        emptyLabel.textAlignment = .center
        addSubview(emptyLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        emptyLabel.frame = bounds
        lineLayer.strokeColor = lineColor.cgColor
        fillLayer.fillColor = lineColor.withAlphaComponent(0.15).cgColor
        
        // Remove old dots
        dotLayers.forEach { $0.removeFromSuperlayer() }
        dotLayers.removeAll()
        
        guard dataPoints.count > 1 else {
            emptyLabel.isHidden = false
            lineLayer.path = nil
            fillLayer.path = nil
            return
        }
        
        emptyLabel.isHidden = true
        
        let maxVal = dataPoints.max() ?? 100
        let minVal = dataPoints.min() ?? 0
        
        // Add padding to max and min values
        let valRange = maxVal - minVal
        let paddingMultiplier: CGFloat = 0.15
        let paddedMin = max(0, minVal - (valRange * paddingMultiplier))
        let paddedMax = maxVal + (valRange * paddingMultiplier)
        let finalRange = paddedMax - paddedMin == 0 ? 10 : paddedMax - paddedMin
        
        let paddingBottom: CGFloat = 20
        let paddingTop: CGFloat = 16
        let paddingSide: CGFloat = 16
        
        let chartWidth = bounds.width - (paddingSide * 2)
        let chartHeight = bounds.height - paddingTop - paddingBottom
        
        let stepX = chartWidth / CGFloat(dataPoints.count - 1)
        
        let linePath = UIBezierPath()
        let fillPath = UIBezierPath()
        
        var points: [CGPoint] = []
        
        for (i, val) in dataPoints.enumerated() {
            let x = paddingSide + CGFloat(i) * stepX
            let normalizedY = (val - paddedMin) / finalRange
            let y = bounds.height - paddingBottom - (normalizedY * chartHeight)
            let point = CGPoint(x: x, y: y)
            points.append(point)
            
            if i == 0 {
                linePath.move(to: point)
                fillPath.move(to: CGPoint(x: x, y: bounds.height - paddingBottom))
                fillPath.addLine(to: point)
            } else {
                linePath.addLine(to: point)
                fillPath.addLine(to: point)
            }
        }
        
        if let lastPoint = points.last {
            fillPath.addLine(to: CGPoint(x: lastPoint.x, y: bounds.height - paddingBottom))
            fillPath.close()
        }
        
        lineLayer.path = linePath.cgPath
        fillLayer.path = fillPath.cgPath
        
        // Add Dots
        if showDots {
            for point in points {
                let dot = CALayer()
                dot.bounds = CGRect(x: 0, y: 0, width: 8, height: 8)
                dot.cornerRadius = 4
                dot.backgroundColor = lineColor.cgColor
                dot.position = point
                layer.addSublayer(dot)
                dotLayers.append(dot)
            }
        }
    }
    
    func animateChart() {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0.0
        anim.toValue = 1.0
        anim.duration = 0.6
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineLayer.add(anim, forKey: "lineDraw")
    }
}
