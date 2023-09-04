//
//  CircularProgressBarView.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/20/22.
//

import Foundation
import UIKit

class CircularProgressBarView: UIView {
    
    // MARK: Properties
    
    private var circleLayer = CAShapeLayer()
    
    private var progressLayer = CAShapeLayer()
    
    private var startPoint = CGFloat(-Double.pi / 2)
    
    private var endPoint = CGFloat(3 * Double.pi / 2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //createCircularPath()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //createCircularPath()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createCircularPath()
    }
    
    func createCircularPath() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Clear existing layers
        // created circularPath for circleLayer and progressLayer
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0), radius: 100, startAngle: startPoint, endAngle: endPoint, clockwise: true)

        // circleLayer path defined to circularPath
        circleLayer.path = circularPath.cgPath
        // ui edits
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 20.0
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.busynessIndexBackgroundColor.cgColor
        // added circleLayer to layer
        layer.addSublayer(circleLayer)
        // progressLayer path defined to circularPath
        progressLayer.path = circularPath.cgPath
        // ui edits
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 15.0
        progressLayer.strokeEnd = 0
        // progressLayer.strokeColor = UIColor.primary.cgColor
        // added progressLayer to layer
        layer.addSublayer(progressLayer)
    }
    
    func progressAnimation(duration: TimeInterval, toValue: Double) {
        print(toValue)
        // Update stroke color based on toValue
        if toValue > 0.9 {
            progressLayer.strokeColor = UIColor.overworkedColor?.cgColor
        } else if toValue > 0.75 {
            progressLayer.strokeColor = UIColor.busyColor?.cgColor
        } else if toValue > 0.6 {
            progressLayer.strokeColor = UIColor.balancedColor?.cgColor
        } else {
            progressLayer.strokeColor = UIColor.relaxedColor?.cgColor
        }

        // created circularProgressAnimation with keyPath
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        // set the end time
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = toValue
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
}
