import UIKit

extension UIView {
    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        leading: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        trailing: NSLayoutXAxisAnchor? = nil,
        padding: UIEdgeInsets = .zero,
        size: CGSize = .zero
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        if let top = top {
            constraints.append(topAnchor.constraint(equalTo: top, constant: padding.top))
        }
        if let leading = leading {
            constraints.append(leadingAnchor.constraint(equalTo: leading, constant: padding.left))
        }
        if let bottom = bottom {
            constraints.append(bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom))
        }
        if let trailing = trailing {
            constraints.append(trailingAnchor.constraint(equalTo: trailing, constant: padding.right))
        }
        
        if size.width != 0 {
            constraints.append(widthAnchor.constraint(equalToConstant: size.width))
        }
        if size.height != 0 {
            constraints.append(heightAnchor.constraint(equalToConstant: size.height))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        anchor(
            top: superview.topAnchor,
            leading: superview.leadingAnchor,
            bottom: superview.bottomAnchor,
            trailing: superview.trailingAnchor,
            padding: padding
        )
    }
    
    func centerInSuperview(size: CGSize = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ]
        
        if size.width != 0 {
            constraints.append(widthAnchor.constraint(equalToConstant: size.width))
        }
        if size.height != 0 {
            constraints.append(heightAnchor.constraint(equalToConstant: size.height))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 8
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func roundCorners(radius: CGFloat = 12) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
