//
//  ProfessorProfileViewController.swift
//  Attendance
//
//  Created by Erblin Berisha on 8/15/17.
//  Copyright © 2017 Erblin Berisha. All rights reserved.
//

import UIKit
 import SwiftKeychainWrapper
import CoreData

class ProfessorProfileViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate,  UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var mainVar: String?
    var subjectToShow: Subjects?
    var values: Values!
    
    private var students = [ProfessorStudents]()
    var searchController: UISearchController!
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mainVar = UserDefaults.standard.string(forKey: "currentSubject")
        self.navigationItem.title = mainVar
        if let context = container?.viewContext, let nameToSearch = mainVar {
            subjectToShow = Subjects.find(theSubject: nameToSearch, in: context)

        }

        tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setNumberOfRowsInSection()
    }
    
    private func setNumberOfRowsInSection() -> Int{
            students = configureTableViewFromStudnets()
            return students.count
    }
    
    
    func configureTableViewFromStudnets() -> [ProfessorStudents] {
        var result = [ProfessorStudents]()
        if let context = container?.viewContext {
            let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
            if !inSearchMode {
                if subjectToShow != nil {
                    request.predicate = NSPredicate(format: "subjects = %@", subjectToShow!)
                    result = (try! context.fetch(request))
                }
            } else {
                if subjectToShow != nil, searchKey != nil {
                    request.predicate = NSPredicate(format: "subjects = %@ and studentName contains[c] %@", subjectToShow!, searchKey!)
                    result = (try! context.fetch(request))
                }
            }
        }
        return result
    }
    
    
    var fetchedResultsController: NSFetchedResultsController<ProfessorStudents>?
    var searchKey: String?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !inSearchMode {
            fetchAttendance()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "allStudents", for: indexPath)
        if let theStudent = fetchedResultsController?.object(at: indexPath) {
            print(theStudent.studentName ?? "nuk ka")
            cell.textLabel?.text = "\(theStudent.studentName!) \(theStudent.studentSurname!)"
            cell.detailTextLabel?.text = "\(theStudent.itWas)"
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objc = fetchedResultsController?.fetchedObjects, objc.count > 0 {
            let student = objc[indexPath.row]
            performSegue(withIdentifier: "studentDetail", sender: student)
        }
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            //searchBar.showsCancelButton = false
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            view.endEditing(true)
            tableView.reloadData()
            
        }else {
            //searchBar.showsCancelButton = true
            inSearchMode = true
            searchKey = searchBar.text!.lowercased()
            fetchAttendanceFromSearch(searchKey: searchKey!)
            //filter({$0.name.range(of: lower) != nil})
        }
    }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = true
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = false
//        searchBar.resignFirstResponder()
//    }
    
    private func fetchAttendance() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
            if subjectToShow != nil {
                request.predicate = NSPredicate(format: "subjects = %@", subjectToShow!)
            }
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
    
    
    private func fetchAttendanceFromSearch(searchKey: String) {
        if let context = container?.viewContext {
            let request: NSFetchRequest<ProfessorStudents> = ProfessorStudents.fetchRequest()
            if subjectToShow != nil {
            request.predicate = NSPredicate(format: "subjects = %@ and studentName contains[c] %@", subjectToShow!, searchKey)
            }
            request.sortDescriptors = [NSSortDescriptor(key: "studentName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            let fetched = NSFetchedResultsController<ProfessorStudents>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController = fetched
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("NUk ka")
            }
            tableView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "studentDetail" {
            if let destination = segue.destination as? StudentDetailViewController {
                if let student = sender as? ProfessorStudents {
                    destination.student = student
                }
            }
        }
    }
    
    @IBAction func deleteAllStudentsTapped(_ sender: UIBarButtonItem) {
        handleTheDeletion()
    }
    
    private func handleTheDeletion() {
        let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to delte all the students", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes, delete all", style: .destructive, handler: { [weak self] (action) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfessorStudents")
            if self?.subjectToShow != nil {
                fetchRequest.predicate = NSPredicate(format: "subjects = %@", (self?.subjectToShow)!)
            }
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            if let context = self?.container?.viewContext {
                do {
                    try context.execute(batchDeleteRequest)
                    self?.tableView.reloadData()
                } catch {
                    print("Could not delte the Items")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        let _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        dismiss(animated: false, completion: nil)
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
