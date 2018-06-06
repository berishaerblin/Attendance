//
//  RegisterViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/3/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
 
    private var itIsStudent: Bool?
    
    let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var createStudnet: CreateStudents?
    var createProfessor: CreateProfessor?
    var createSubject: CreateSubject?
    
    let type = ["Student", "Professor"]
    private var typeChoose = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        pickerView.delegate = self
        pickerView.dataSource = self
        nameTextField.delegate = self
        surnameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        idTextField.delegate = self
        subjectTextField.delegate = self
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return type[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if type[row] == type[0] {
            //print(type[row])
            idTextField.isHidden = false
            subjectTextField.isHidden = true
        } else {
            //print(type[row])
            idTextField.isHidden = true
            subjectTextField.isHidden = false
        }
        
       typeChoose = type[pickerView.selectedRow(inComponent: 0)]
    }
        
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "New Register", nameTextField.hasText && surnameTextField.hasText && ((idTextField.isEnabled && idTextField.hasText)  || (subjectTextField.isEnabled && subjectTextField.hasText)) && usernameTextField.hasText && passwordTextField.hasText {
            print(typeChoose)
            if typeChoose == "Professor"  {
                registerTheProfessor()
            }else {
                registerTheStudent()
            }
           
            return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        } else {
            handleTheEmptyFields()
            return false
        }
    }
    
    func registerTheStudent() {
            createStudnet = CreateStudents(studentName: nameTextField.text!, studentSurname: surnameTextField.text!, studentID: idTextField.text!, studentUsername: usernameTextField.text!, studentPassword: passwordTextField.text!)
            print(createStudnet?.studentName ?? "name does not come") 
    }
    
    func registerTheProfessor() {
        createSubject = CreateSubject(subjectName: subjectTextField.text!)
        createProfessor = CreateProfessor(professorName: nameTextField.text!, professorSurname: surnameTextField.text!, professorSubject: createSubject!, professorUsername: usernameTextField.text!, professorPassword: passwordTextField.text!)
            print(createProfessor?.professorName ?? "name does not come")
    }
    
    
    private func handleTheEmptyFields() {
        let alert = UIAlertController(title: "Warning!", message: "All text fields should have text", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
