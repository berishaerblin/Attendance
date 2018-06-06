//
//  Subjects.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/9/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData

class Subjects: NSManagedObject {
    
    class func insertIntoSubjects(theSubject: CreateSubject, in context: NSManagedObjectContext) -> Subjects {
        let subject = Subjects(context: context)
        subject.subjectName = theSubject.subjectName
        // subject.subjectProfessor = Professor.insertIntoProfessor(theProfessor: thisProfessor, in: context)
        return subject
        
    }
    
    
    class  func insertNewSubjectIntoProfessor(theSubject: CreateSubject, into theProfessor: CreateNewSubjectIntoProfessor,  in  context: NSManagedObjectContext) {
        let subject = Subjects(context: context)
        subject.subjectName = theSubject.subjectName
        subject.subjectProfessor = Professor.insertNewSubject(into: theProfessor, in: context)
        
    }
    
    
    class func insertNewStudent(theStudent: StudentsAttendance, in context: NSManagedObjectContext) -> Subjects {
        let request: NSFetchRequest<Subjects> = Subjects.fetchRequest()
        request.predicate = NSPredicate(format: "subjectName = %@", theStudent.subject)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0{
                assert (matches.count >= 1, "Subjects -- database inconsistency!")
                return matches[0]
            }
        } catch {
            print("unable to find")
        }
        
        return Subjects()
    }
    
    
    class func find(theSubject: String, in context: NSManagedObjectContext) -> Subjects {
        let request: NSFetchRequest<Subjects> = Subjects.fetchRequest()
        request.predicate = NSPredicate(format: "subjectName = %@", theSubject)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0{
                assert (matches.count >= 1, "Subjects -- database inconsistency!")
                return matches[0]
            }
        } catch {
            print("unable to find")
        }
        
        return Subjects()
    }

}
