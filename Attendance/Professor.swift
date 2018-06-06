//
//  Professor.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/9/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData

class Professor: NSManagedObject {

    
    class func insertIntoProfessor(theProfessor: CreateProfessor, in context: NSManagedObjectContext) {
        let professor = Professor(context: context)
        professor.professorName = theProfessor.professorName
        professor.professorSurname = theProfessor.professorSurname
        professor.usernameProfessor = theProfessor.professorUsername
        professor.passwordPofessor = theProfessor.professorPassword

        professor.addToSubjects(Subjects.insertIntoSubjects(theSubject: theProfessor.professorSubject, in: context))
    }
    
    
    class func insertNewSubject(into theProfessor: CreateNewSubjectIntoProfessor, in context: NSManagedObjectContext) -> Professor {
       // let professor = Professor(context: context)
        let request: NSFetchRequest<Professor> = Professor.fetchRequest()
        request.predicate = NSPredicate(format: "usernameProfessor = %@", theProfessor.professorsUsername)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0{
                assert (matches.count >= 1, "Professor -- database inconsistency!")
                return matches[0]
            }
        } catch {
            print("unable to find")
        }
        
        return Professor()
    }
}
