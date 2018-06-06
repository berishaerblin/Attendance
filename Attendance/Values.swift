//
//  Values.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/29/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import Foundation
struct Values {
    
    private var _subjectName: String
    
    var setSubjectsName: String {
        set {
            _subjectName = newValue
        }get {
            return _subjectName
        }
    }
    
    var getSubjectName: String {
        return _subjectName
    }
}
