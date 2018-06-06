//
//  StudentDetailViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/18/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData

class StudentDetailViewController: UIViewController {
    
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentSurnameLabel: UILabel!
    @IBOutlet weak var itWasLabel: UILabel!
    @IBOutlet weak var studentIDLabel: UILabel!
    var student: ProfessorStudents?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentNameLabel.text = student?.studentName
        studentSurnameLabel.text = student?.studentSurname
        studentIDLabel.text = student?.studentID
        itWasLabel.text = "\(String(describing: student!.itWas))"
    }

}
