//
//  RoundImage.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/3/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
@IBDesignable
class RoundImage: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width/2
        clipsToBounds = true
    }

}
