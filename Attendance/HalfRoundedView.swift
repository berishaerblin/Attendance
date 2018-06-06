//
//  HalfRoundedView.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/24/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit


@IBDesignable

class HalfRoundedView: UIView {    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let circlePath = UIBezierPath.init(arcCenter: CGPoint(x: self.bounds.size.width / 2, y: 0), radius: self.bounds.size.height, startAngle: 0.0, endAngle: CGFloat(Double.pi), clockwise: true)
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        self.layer.mask = circleShape
    }

}
