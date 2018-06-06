//
//  EditProfileViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 9/19/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var contanier: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {didSet {updateUI()}}
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var universityTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var patternTextField: UITextField!
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBOutlet weak var addImage: RoundImage!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        updateUI()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    @IBAction func addImageTapped(_ sender: UITapGestureRecognizer) {
         present(imagePicker, animated: true, completion: nil)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("Image not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
        private func updateUI() {
            if let context = contanier?.viewContext {
                
                let request: NSFetchRequest<Students> = Students.fetchRequest()
                request.predicate = NSPredicate(format: "usernameStudent == %@", UserDefaults.standard.string(forKey: "username")!)
                let result = try? context.fetch(request)
                for name in result! {
                    nameLabel.text = name.studnetName
                    surnameLabel.text = name.studentSurname
                    idLabel.text = name.studentID
                    universityTextField.text = name.university
                    schoolTextField.text = name.school
                    patternTextField.text = name.pattern
                    if name.profileImage != nil {
                        addImage.image = name.profileImage as? UIImage
                    } else {
                        addImage.image = UIImage(named: "emptyImage")
                    }
                }
            }
        }
    
    func updateUsersProfile(with image: UIImage, university: String, school: String, pattern: String){
        
        if let context = contanier?.viewContext {
            let request: NSFetchRequest<Students> = Students.fetchRequest()
            request.predicate = NSPredicate(format: "usernameStudent == %@", UserDefaults.standard.string(forKey: "username")!)
            let result = try? context.fetch(request)
            for name in result! {
                name.university = university
                name.school = school
                name.pattern = pattern
                name.profileImage = image
            }
            
            do {
                try context.save()
            } catch {
                print("unable to update")
            }
        }
        
    }
    
    @IBAction func saveTheEdit(_ sender: UIBarButtonItem) {
        updateUsersProfile(with: addImage.image!, university: universityTextField.text!, school: schoolTextField.text!, pattern: patternTextField.text!)
        
       _ = navigationController?.popViewController(animated: true)
    }
    
}
