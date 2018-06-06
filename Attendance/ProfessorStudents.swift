//
//  ProfessorStudents.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/17/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData

class ProfessorStudents: NSManagedObject {
    
    class func insertIntoProfessorStudents(theStudent: StudentsAttendance, in context: NSManagedObjectContext) {
        
        let student = ProfessorStudents(context: context)
        student.studentName = theStudent.studentName
        student.studentSurname = theStudent.studentSurname
        student.studentID = theStudent.studentID
        student.deviceID = theStudent.deviceID
        student.itWas = theStudent.itWas
        student.today = theStudent.today as Date
        
        student.subjects = Subjects.insertNewStudent(theStudent: theStudent, in: context)
        
    }
    
}
