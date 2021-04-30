//
//  SpeechRecognitionVC.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 27/04/21.
//

import UIKit

@IBDesignable class BubbleShapeView: UIView { // 1
    
    
    override init(frame: CGRect) { // 2
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        super.backgroundColor = .clear // 3
    }
    
    private var bubbleColor: UIColor? { // 4
        didSet {
            setNeedsDisplay() // 5
        }
    }
    
    override var backgroundColor: UIColor? { // 6
        get { return .clear }
        set { bubbleColor = .clear }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 { // 1
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear { // 2
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var startColor: UIColor = .clear { // 2
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var endColor: UIColor = .clear { // 2
        didSet {
            setNeedsDisplay()
        }
    }
    
    enum ArrowDirection: String { // 1
        case left = "left"
        case right = "right"
        case none = "none"
    }
    
    var arrowDirection: ArrowDirection = .right { // 2
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var arrowDirectionIB: String { // 3
        get {
            return arrowDirection.rawValue
        }
        set {
            if let direction = ArrowDirection(rawValue: newValue) {
                arrowDirection = direction
            }
        }
    }

    
    override func draw(_ rect: CGRect) {
        var bezierPath = UIBezierPath()
        bezierPath.lineWidth = borderWidth // 3
        
        let bottom = rect.height - borderWidth // 4
        let right = rect.width - borderWidth
        let top = borderWidth
        let left = borderWidth
        
        if arrowDirection == .right { // 4
            
            bezierPath.move(to: CGPoint(x: right - 22, y: bottom)) // 5
            bezierPath.addLine(to: CGPoint(x: 17 + borderWidth, y: bottom))
            bezierPath.addCurve(to: CGPoint(x: left, y: bottom - 18), controlPoint1: CGPoint(x: 7.61 + borderWidth, y: bottom), controlPoint2: CGPoint(x: left, y: bottom - 7.61))
            bezierPath.addLine(to: CGPoint(x: left, y: 17 + borderWidth))
            bezierPath.addCurve(to: CGPoint(x: 17 + borderWidth, y: top), controlPoint1: CGPoint(x: left, y: 7.61 + borderWidth), controlPoint2: CGPoint(x: 7.61 + borderWidth, y: top))
            bezierPath.addLine(to: CGPoint(x: right - 21, y: top))
            bezierPath.addCurve(to: CGPoint(x: right - 4, y: 17 + borderWidth), controlPoint1: CGPoint(x: right - 11.61, y: top), controlPoint2: CGPoint(x: right - 4, y: 7.61 + borderWidth))
            bezierPath.addLine(to: CGPoint(x: right - 4, y: bottom - 11))
            bezierPath.addCurve(to: CGPoint(x: right, y: bottom), controlPoint1: CGPoint(x: right - 4, y: bottom - 1), controlPoint2: CGPoint(x: right, y: bottom))
            bezierPath.addLine(to: CGPoint(x: right + 0.05, y: bottom - 0.01))
            bezierPath.addCurve(to: CGPoint(x: right - 11.04, y: bottom - 4.04), controlPoint1: CGPoint(x: right - 4.07, y: bottom + 0.43), controlPoint2: CGPoint(x: right - 8.16, y: bottom - 1.06))
            bezierPath.addCurve(to: CGPoint(x: right - 22, y: bottom), controlPoint1: CGPoint(x: right - 16, y: bottom), controlPoint2: CGPoint(x: right - 19, y: bottom))
            
        } else if arrowDirection == .left { // 4
            bezierPath.move(to: CGPoint(x: 22 + borderWidth, y: bottom)) // 5
            bezierPath.addLine(to: CGPoint(x: right - 17, y: bottom))
            bezierPath.addCurve(to: CGPoint(x: right, y: bottom - 17), controlPoint1: CGPoint(x: right - 7.61, y: bottom), controlPoint2: CGPoint(x: right, y: bottom - 7.61))
            bezierPath.addLine(to: CGPoint(x: right, y: 17 + borderWidth))
            bezierPath.addCurve(to: CGPoint(x: right - 17, y: top), controlPoint1: CGPoint(x: right, y: 7.61 + borderWidth), controlPoint2: CGPoint(x: right - 7.61, y: top))
            bezierPath.addLine(to: CGPoint(x: 21 + borderWidth, y: top))
            bezierPath.addCurve(to: CGPoint(x: 4 + borderWidth, y: 17 + borderWidth), controlPoint1: CGPoint(x: 11.61 + borderWidth, y: top), controlPoint2: CGPoint(x: borderWidth + 4, y: 7.61 + borderWidth))
            bezierPath.addLine(to: CGPoint(x: borderWidth + 4, y: bottom - 11))
            bezierPath.addCurve(to: CGPoint(x: borderWidth, y: bottom), controlPoint1: CGPoint(x: borderWidth + 4, y: bottom - 1), controlPoint2: CGPoint(x: borderWidth, y: bottom))
            bezierPath.addLine(to: CGPoint(x: borderWidth - 0.05, y: bottom - 0.01))
            bezierPath.addCurve(to: CGPoint(x: borderWidth + 11.04, y: bottom - 4.04), controlPoint1: CGPoint(x: borderWidth + 4.07, y: bottom + 0.43), controlPoint2: CGPoint(x: borderWidth + 8.16, y: bottom - 1.06))
            bezierPath.addCurve(to: CGPoint(x: borderWidth + 22, y: bottom), controlPoint1: CGPoint(x: borderWidth + 16, y: bottom), controlPoint2: CGPoint(x: borderWidth + 19, y: bottom))
            
        } else {
            bezierPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.topLeft, .bottomRight, .topRight, .bottomLeft],
                                    cornerRadii: CGSize(width: 15.0, height: 0.0))
        }
        
        bezierPath.close()
        
        let gradient = CAGradientLayer()
        gradient.frame = bezierPath.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
//        gradient.type = .axial

        let shapeMask = CAShapeLayer()
        shapeMask.path = bezierPath.cgPath

        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
//        backgroundColor?.setFill()
//        borderColor.setStroke() // 6
//        bezierPath.fill()
//        bezierPath.stroke()
    }
}
