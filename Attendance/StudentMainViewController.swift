//
//  StudentMainViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/3/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

class StudnetMainViewController: UIViewController, MCBrowserViewControllerDelegate,
MCSessionDelegate {
    
    let serviceType = "AttendanceEB"
    var browser : MCBrowserViewController!
    var session : MCSession!
    var peerID: MCPeerID!
    var deviceID: String?
    var isConnected = false
    
    @IBOutlet weak var imHereButtonOutlet: UIButton!
    @IBOutlet weak var browseButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var surnameLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    private let userDefaults = UserDefaults.standard
    
    private var name: String?
    private var surname: String?
    private var studentID: String?
    private var timeOfRegistration: Date?
    
    private var username: String? {
        didSet {
            updateUI()
        }
    }
    
    var contanier: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet { updateUI() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfItIsAllowedToRegister()
        username = userDefaults.string(forKey: "username")
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        deviceID = UIDevice.current.identifierForVendor?.uuidString
        
        self.browser = MCBrowserViewController(serviceType: serviceType, session:self.session)
        self.browser.delegate = self;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkIfItIsConnected()
        checkIfItIsAllowedToRegister()
    }
    
    
    var fetchedResultsController: NSFetchedResultsController<Students>?
    
    private func updateUI() {
        if let context = contanier?.viewContext {
            
            let request: NSFetchRequest<Students> = Students.fetchRequest()
            if username != nil {
                request.predicate = NSPredicate(format: "usernameStudent == %@", username!)
            }
            let result = try? context.fetch(request)
            for student in result! {
                name = student.studnetName
                surname = student.studentSurname
                studentID = student.studentID
            }
            
            nameLabel.text = name
            surnameLabel.text = surname
            idLabel.text = studentID
        }
    }
    
    @IBAction func iAmHereButton(_ sender: UIButton) {
        let nameSurnameAndId = ["name" : self.name!, "surname": self.surname!, "studentID" : self.studentID!, "deviceID": self.deviceID!] as [String : Any]
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: nameSurnameAndId)
        
        do {
            try self.session.send(dataToSend, toPeers: self.session.connectedPeers, with: .reliable)
            let alert = UIAlertController(title: "Completed!", message: "You just said that you are here", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self](UIAlertAction) in
                self?.isConnected = false
                self?.stateLabel.text = "Disconnected"
            }))
            present(alert, animated: true, completion: nil)
            //session.disconnect()
            disableButtons()
            timeOfRegistration = Date()
            userDefaults.set(timeOfRegistration, forKey: "studentRegistered")
        } catch {
            let error = error as NSError
            print("Error sending data: \(String(describing: error.localizedDescription))")
        }
        
        
        
    }
    
    func checkIfItIsAllowedToRegister() {
        if let timeOf = userDefaults.object(forKey: "studentRegistered") as? Date {
            let duration = Date().timeIntervalSince(timeOf)
            let intDuration = Int(duration)
            if intDuration > 20 {
                print("\(intDuration)it IS bigger")
                enableButtons()
            } else {
                disableButtons()
            }
        }
        
    }
    
    func enableButtons() {
        browseButtonOutlet.isEnabled = true
        imHereButtonOutlet.isEnabled = true
    }
    
    func disableButtons() {
        browseButtonOutlet.isEnabled = false
        imHereButtonOutlet.isEnabled = false
    }
    
    @IBAction func showBrowser(_ sender: UIBarButtonItem) {
        self.present(self.browser, animated: true, completion: nil)
        
    }
    
    func browserViewControllerDidFinish(
        _ browserViewController: MCBrowserViewController)  {
        isConnected = true
        stateLabel.text = "Connected"
        self.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(
        _ browserViewController: MCBrowserViewController)  {
        self.session.disconnect()
        self.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, didReceive data: Data,
                 fromPeer peerID: MCPeerID)  {
    }
    
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress)  {
    }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL???, withError error: Error?)  {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID)  {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID,
                 didChange state: MCSessionState)  {        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func checkIfItIsConnected() {
        if isConnected == false {
            stateLabel.text = "Not Connected"
        }
    }
}

