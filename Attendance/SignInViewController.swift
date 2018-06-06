//
//  SignInViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/8/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData
import SwiftKeychainWrapper

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    @IBOutlet weak var signInUsernameTextField: UITextField!
    @IBOutlet weak var signInPasswordTextField: UITextField!
    
    private var theSegueId: String?
    private var signInStudent: CreateStudents?
    private var signInProfessor: CreateProfessor?
    private var itIsStudent = true
    
    var username: String?
    var password: String?
    var type: String?
    
    private let userDefaults = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setTheDetails()
        signInUsernameTextField.delegate = self
        signInPasswordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("It is Signed In")
            if type != nil {
                performSegue(withIdentifier: type!, sender: nil)
            } else {
                KeychainWrapper.standard.removeObject(forKey: KEY_UID)
                print("Removed keychain")
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        if signInUsernameTextField.hasText && signInPasswordTextField.hasText {
            if username != nil, password != nil {
                if signInUsernameTextField.text == userDefaults.string(forKey: "username")! && signInPasswordTextField.text == userDefaults.string(forKey: "password")!{
                    completeSignIn(username: username!, type: type!)
                    signInUsernameTextField.text = nil
                    signInPasswordTextField.text = nil
                } else {
                    handleSignIn()
                }
            } else {
                handleTheUnregisteredUser()
            }
        } else {
            handleTheEmptyFields()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func unwindAndRegisterStudent(from segue: UIStoryboardSegue) {
        if let registor = segue.source as? RegisterViewController {
            if let context = container?.viewContext {
                if let newStudent = registor.createStudnet {
                    signInStudent = newStudent
                    Students.insertIntoStudents(theStudent: newStudent, in: context)
                    itIsStudent = true
                    userDef()
                    do {
                        try context.save()
                    } catch {
                        print("unable to save")
                    }
                } else if let newProfessor = registor.createProfessor {
                    signInProfessor = newProfessor
                    Professor.insertIntoProfessor(theProfessor: newProfessor, in: context)
                    itIsStudent = false
                    userDef()
                    do {
                        try context.save()
                    } catch {
                        print("unable to save")
                    }
                    
                }
                else {
                    print("Error")
                }
            }
            
            completeSignIn(username: username!, type: type!)
        }
    }
    
    func userDef() {
        if itIsStudent {
            print(signInStudent?.studentUsername ?? "ska")
            userDefaults.set(signInStudent?.studentUsername, forKey: "username")
            userDefaults.set(signInStudent?.studentPassword, forKey: "password")
            userDefaults.set("Student", forKey: "userType")
            userDefaults.synchronize()
            
        } else {
            userDefaults.set(signInProfessor?.professorUsername, forKey: "username")
            userDefaults.set(signInProfessor?.professorPassword, forKey: "password")
            userDefaults.set("Professor", forKey: "userType")
            userDefaults.synchronize()
            
        }
        
        username = userDefaults.string(forKey: "username")!
        password = userDefaults.string(forKey: "password")!
        type = userDefaults.string(forKey: "userType")!
        
        
        
    }
    
    func setTheDetails() {
        if userDefaults.string(forKey: "username") != nil, userDefaults.string(forKey: "password") != nil, userDefaults.string(forKey: "userType") != nil {
            
            username = userDefaults.string(forKey: "username")!
            password = userDefaults.string(forKey: "password")!
            type = userDefaults.string(forKey: "userType")!
        }
    }
    
    
    func completeSignIn(username: String, type: String){
        let keychainResult = KeychainWrapper.standard.set(username, forKey: KEY_UID)
        print("Blinnky: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: type, sender: nil)
    }
    
    private func handleTheEmptyFields() {
        let alert = UIAlertController(title: "Warning!", message: "You should type the Username and Password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

    private func handleTheUnregisteredUser() {
        let alert = UIAlertController(title: "Warning!", message: "You need to register first to be able to Sign In!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func handleSignIn() {
        let alert = UIAlertController(title: "Warning!", message: "Your username or password is incorrect!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",  style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}


