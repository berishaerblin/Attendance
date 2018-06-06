//
//  Students.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/9/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData

class Students: NSManagedObject {
    
    
    class func insertIntoStudents(theStudent: CreateStudents, in context: NSManagedObjectContext) {
        let student = Students(context: context)
        student.studnetName = theStudent.studentName
        student.studentSurname = theStudent.studentSurname
        student.studentID = theStudent.studentID
        
        student.usernameStudent = theStudent.studentUsername
        student.passwordStudent = theStudent.studentPassword

        
    }

}
