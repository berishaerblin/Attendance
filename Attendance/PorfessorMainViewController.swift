//
//  PorfessorMainViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/12/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//
import UIKit
import MultipeerConnectivity
import CoreData

class ProfessorMainViewController: UIViewController,
MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var professorName: UILabel!
    @IBOutlet weak var professorSurname: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noStudentsLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var visibleInfoLabel: UILabel!
    @IBOutlet weak var subjectPickerView: UIPickerView!
    
    let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    let serviceType = "AttendanceEB"
    let todayDate = Date()
    let dateFormatter = DateFormatter()
    
    
    var today: String = ""
    var subjects = [String]()
    var createNewSubject: CreateSubject?
    var thisProfessor: CreateNewSubjectIntoProfessor?
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    var advertiser: MCNearbyServiceAdvertiser!
    var invitationHandler: ((Bool, MCSession?) -> Void)?
    var studentsAttendance: StudentsAttendance?
    var studentsSubject: String?
    var thisSubject: Subjects?
    var value: Values!
    var timer: Timer!
    var secondsCounted = 0
    var secondsCountedOld = 0
    
    private var students = [ProfessorStudents]()
    private let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjectPickerView.delegate = self
        subjectPickerView.dataSource = self
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        today = dateFormatter.string(from: todayDate)
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)//, securityIdentity: nil, encryptionPreference: .optional)
        self.session.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
        dataBaseStistics()
    }
    
    func saveStudentAttendanceFor(name: String, surname: String, studentID: String, deviceID: String, fromPeer peerID: MCPeerID) {
        print("Sesionet e conectuare \(session.connectedPeers.count)")
        let (itIsNewStudent, itIsFake, itIsNewSubject) = fetchForExistedStudent(name: name, surname: surname, studentID: studentID, deviceID: deviceID, subject: studentsSubject!)
        let x = (itIsNewStudent,itIsFake, itIsNewSubject)
        
        
        if x.0 == true && x.1 == false {
            print("new student")
            studentsAttendance = StudentsAttendance(deviceID: deviceID, itWas: 1, studentID: studentID, studentName: name, studentSurname: surname, today: dateFormatter.date(from: today)! as NSDate, subject: studentsSubject!)
            if let context = container?.viewContext {
                ProfessorStudents.insertIntoProfessorStudents(theStudent: studentsAttendance!, in: context)
                do {
                    try context.save()
                } catch {
                    print("unable to save")
                }
            }
        } else if x.0 == false && x.1 == false && x.2 == true {
            print("new Subject")
            studentsAttendance = StudentsAttendance(deviceID: deviceID, itWas: 1, studentID: studentID, studentName: name, studentSurname: surname, today: dateFormatter.date(from: today)! as NSDate, subject: studentsSubject!)
            if let context = container?.viewContext {
                ProfessorStudents.insertIntoProfessorStudents(theStudent: studentsAttendance!, in: context)
                do {
                    try context.save()
                } catch {
                    print("unable to save")
                }
            }
        } else if x.0 == false && x.1 == false && x.2 == false {
            print("old student")
            if let context = container?.viewContext {
                let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
                request.predicate = NSPredicate(format: "studentID = %@ and subjects = %@", studentID, Subjects.find(theSubject: studentsSubject!, in: context))
                let result = try? context.fetch(request)
                for student in result! {
                    student.itWas = student.itWas + 1
                    student.today = dateFormatter.date(from: today)
                }
                do {
                    try context.save()
                } catch {
                    print("unable to save")
                }
            }
        } else {
            return
        }
    }
    
    func fetchForExistedStudent(name: String, surname: String, studentID: String, deviceID: String, subject: String) -> (Bool,Bool, Bool) {
        var itIsNewStudent = false
        var itIsFake = false
        var itIsNewSubject = true
        if let context = container?.viewContext {
            let thisSubject = Subjects.find(theSubject: subject, in: context)
            let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
            request.predicate = NSPredicate(format: "(studentID = %@ or deviceID = %@) and subjects = %@", studentID, deviceID, thisSubject)
            let result = try? context.fetch(request)
            if (result?.isEmpty)! {
                itIsNewStudent = true
            } else {
                for theStudent in result! {
                    if theStudent.subjects == thisSubject {
                        itIsNewSubject = false
                        if theStudent.studentName == name && theStudent.studentSurname == surname && theStudent.deviceID == deviceID {
                            itIsNewStudent = false
                        } else {
                            itIsFake = true
                            handleTheFakeStudent(name: name)
                        }
                    } else if theStudent.studentName == name && theStudent.studentSurname == surname && theStudent.deviceID == deviceID {
                        itIsNewSubject = true
                    } else {
                        itIsFake = true
                        handleTheFakeStudent(name: name)
                    }
                }
            }
        }
        return (itIsNewStudent, itIsFake, itIsNewSubject)
    }
    
    
    private func handleTheFakeStudent(name: String) {
        let alert = UIAlertController(title: "Warning!", message: "The device that \(name) is trying to register is registered with another Student!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func switchVisibility(_ sender: UISwitch) {
        if switchVisible.isOn {
            advertiser.startAdvertisingPeer()
            visibleInfoLabel.text = "Visible"
        } else {
            advertiser.stopAdvertisingPeer()
            visibleInfoLabel.text = "Not Visible"
            session.disconnect()
        }
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
    private func registerTheAttendance() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setNumberOfRowsInSection()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return setNumberOfSections()
    }
    
    private func setNumberOfRowsInSection() -> Int {
        let result = configureTableViewFromStudnets()
        if result.isEmpty {
            return 0
        } else {
            return result.count
        }
    }
    
    private func setNumberOfSections() -> Int {
        let result = configureTableViewFromStudnets()
        if result.isEmpty {
            DispatchQueue.main.async {
                self.noStudentsLabel.isHidden = false
                self.emojiLabel.isHidden = false
                self.tableView.isHidden = true
            }
            return 0
        } else {
            DispatchQueue.main.async {
                self.noStudentsLabel.isHidden = true
                self.emojiLabel.isHidden = true
                self.tableView.isHidden = false
            }
            return 1
        }
    }
    
    func configureTableViewFromStudnets() -> [ProfessorStudents] {
        var result = [ProfessorStudents]()
        if let context = container?.viewContext {
            let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
            request.predicate = NSPredicate(format: "today = %@ and subjects = %@", (dateFormatter.date(from: today) as NSDate?)!, Subjects.find(theSubject: studentsSubject!, in: context))
            userDefaults.set(studentsSubject, forKey: "currentSubject")
            result = (try! context.fetch(request))
        }
        return result
    }
    
    var fetchedResultsController: NSFetchedResultsController<ProfessorStudents>?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fetchAttendance()
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentsCell", for: indexPath)
        
        if let theStudent = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = "\(theStudent.studentName!) \(theStudent.studentSurname!)"
        }
        return cell
    }
    
    private func fetchAttendance() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
            request.predicate = NSPredicate(format: "subjects = %@ and today = %@", Subjects.find(theSubject: studentsSubject!, in: context), (dateFormatter.date(from: today) as NSDate?)!)
            request.sortDescriptors = [NSSortDescriptor(key: "studentName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            let fetched = NSFetchedResultsController<ProfessorStudents>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController = fetched
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("NUk ka")
            }
        }
    }
    
    
    private func updateUI() {
        if let context = container?.viewContext {
            
            let request: NSFetchRequest<Professor> = Professor.fetchRequest()
            if let username = userDefaults.string(forKey: "username") {
                request.predicate = NSPredicate(format: "usernameProfessor = %@", username)
            }
            let result = try? context.fetch(request)
            for professor in result! {
                professorName.text = professor.professorName
                professorSurname.text = professor.professorSurname
                subjects.removeAll()
                subjectName.text = subjectNameForProfessor(theProfessor: professor)
                subjectPickerView.reloadAllComponents()
            }
            
        }
        
    }
    
    func subjectNameForProfessor(theProfessor: Professor) -> String {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Subjects> = Subjects.fetchRequest()
            request.predicate = NSPredicate(format: "subjectProfessor = %@", theProfessor)
            let result = try? context.fetch(request)
            for subject in result! {
                subjects.insert(subject.subjectName!, at: 0)
            }
        }
        studentsSubject = subjects[0]
        tableView.reloadData()
        return subjects[0]
    }
    
    private func studentsForSubjectName(theSubject: Subjects) -> [ProfessorStudents] {
        if let context = container?.viewContext {
            let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
            request.predicate = NSPredicate(format: "subjects = %@", theSubject)
            let result = try? context.fetch(request)
            print(result!)
            return result!
            
        }
        return [ProfessorStudents]()
    }
    
    
    
    private func dataBaseStistics() {
        if let context = container?.viewContext {
            context.perform {
                
                if Thread.isMainThread{
                    print("on main thread")
                } else {
                    print("off main thread")
                }
                let request: NSFetchRequest<Subjects> = Subjects.fetchRequest()
                //self.students = (try! context.fetch(request))
                let result = try? context.fetch(request)
                for su in result! {
                    print("\(String(describing: su.subjectProfessor?.professorName))   \(String(describing: su.subjectName))")
                }
            }
        }
    }
    
    @IBAction func addNewSubject(_ sender: UIBarButtonItem) {
        thisProfessor = CreateNewSubjectIntoProfessor(professorsUsername: userDefaults.string(forKey: "username")!)
        handleTheNewSubject()
    }
    
    private func handleTheNewSubject() {
        let alert = UIAlertController(title: "New Subject", message: "Type the name of the subject.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] action in
            if let textField = alert.textFields {
                if let firstTextField = textField.first, firstTextField.hasText {
                    if let firstTextFieldText = firstTextField.text {
                        self?.createNewSubject = CreateSubject(subjectName: firstTextFieldText)
                        if let newSubject = self?.createNewSubject {
                            if newSubject.subjectName != "" {
                                self?.insertNewSubject()
                            }
                        }
                    }
                }
            }
        }))
        alert.addTextField(configurationHandler: nil)
        present(alert, animated: true)
        
    }
    
    private func insertNewSubject() {
        if let context = container?.viewContext {
            Subjects.insertNewSubjectIntoProfessor(theSubject: (self.createNewSubject!), into: (self.thisProfessor!), in: context)
            try? context.save()
            DispatchQueue.main.async {
                self.updateUI()
            }
        } else {
            print("Unable to Save")
            
        }
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBAction func changeSubject(_ sender: Any) {
        tableView.isHidden = true
        subjectPickerView.isHidden = false
        backgroundView.isHidden = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return subjects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return subjects[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subjectName.text = subjects[row]
        studentsSubject = subjects[row]
        subjectPickerView.isHidden = true
        backgroundView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    // MARK: Session
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)  {
        let infos = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, Any>
        self.saveStudentAttendanceFor(name: infos["name"] as! String, surname: infos["surname"] as! String, studentID: infos["studentID"] as! String,deviceID: infos["deviceID"] as! String, fromPeer: peerID)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        session.cancelConnectPeer(peerID)
    }
    
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress)  {
    }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL??, withError error: Error?)  {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID)  {
        print("Sessionet e conectuara: \(session.connectedPeers.count)")
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID,
                 didChange state: MCSessionState)  {
        switch state {
        case .connecting:
            runTimer()
            print("It is connecting")
        case .connected:
            if timer != nil {
                timer.invalidate()
                print("Sekondat \(secondsCountedOld)")
                print("It is connected")
                timer = nil
            }
        default:
            break
        }
    }
    
    @objc private func checkForPeers() {
        secondsCounted = Int((timer?.timeInterval)!)
        secondsCountedOld = secondsCountedOld + secondsCounted
    }
    
    private func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(checkForPeers)), userInfo: nil, repeats: true)
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    // MARK: Supporting code
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
}
