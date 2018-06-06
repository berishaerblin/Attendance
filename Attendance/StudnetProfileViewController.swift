//
//  StudentProfileViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/3/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData
import SwiftKeychainWrapper

class StudentProfileViewController: UIViewController {

    var contanier: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet { updateUI() } }
    
    var student = [Students]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImage: RoundImage!
    @IBOutlet weak var studentsNameLabel: UILabel!
    @IBOutlet weak var studentsSurnameLabel: UILabel!
    @IBOutlet weak var studentsIdLabel: UILabel!
    
    @IBOutlet weak var studentsUniversityLabel: UILabel!
    
    @IBOutlet weak var studentsSchoolLabel: UILabel!
    
    @IBOutlet weak var studentsPatternLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
      
        printDatabaseStatistics()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateUI()
    }
    
    var fetchedResultsController: NSFetchedResultsController<Students>?
    
    private func updateUI() {
        if let context = contanier?.viewContext {
            
            let request: NSFetchRequest<Students> = Students.fetchRequest()
            request.predicate = NSPredicate(format: "usernameStudent == %@", UserDefaults.standard.string(forKey: "username")!)
            let result = try? context.fetch(request)
            for name in result! {
                studentsNameLabel.text = name.studnetName
                studentsSurnameLabel.text = name.studentSurname
                studentsIdLabel.text = name.studentID
                studentsUniversityLabel.text = name.university
                studentsSchoolLabel.text = name.school
                studentsPatternLabel.text = name.pattern
                if name.profileImage != nil {
                    profileImage.image = name.profileImage as? UIImage
                } else {
                    profileImage.image = UIImage(named: "emptyImage")
                }
            }
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = contanier?.viewContext {
            context.perform {
                if Thread.isMainThread{
                    print("on main thread")
                } else {
                    print("off main thread")
                }
                let request: NSFetchRequest<Students> = Students.fetchRequest()
                if let tweetCount = (try? context.fetch(request))?.count {
                    print("\(tweetCount) users")
                }
            }
        }
    }

    @IBAction func signOutTapped(_ sender: UIButton) {
        let _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        dismiss(animated: false, completion: nil)
    }
}
