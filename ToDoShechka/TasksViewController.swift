 //
//  TasksViewController.swift
//  ToDoShechka
//
//  Created by Vladimir Saprykin on 19.03.17.
//  Copyright © 2017 Vladimir Saprykin. All rights reserved.
//

import UIKit
import Firebase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var user: User!
    var ref: FIRDatabaseReference!
    var tasks = Array<Task>()

    @IBOutlet weak var tableView: UITableView!
//    @IBAction func showDetailButton(_ sender: UIBarButtonItem) {
//
//        performSegue(withIdentifier: "showDetail", sender: nil)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = FIRAuth.auth()?.currentUser  else { return }
        user = User(user: currentUser)
        ref = FIRDatabase.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value, with: { [weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapShort: item as! FIRDataSnapshot)
                _tasks.append(task)
                self?.tasks = _tasks
                self?.tableView.reloadData()
            }
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        let taskTitle = task.title
        let isCompleted = task.completed
        cell.textLabel?.text = taskTitle
        
        toogleCompleted(cell, isCompleted: isCompleted)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
   }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        toogleCompleted(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])
    }
    
    func toogleCompleted(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }

    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            print (error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showDetail", sender: nil)
//        let alertController = UIAlertController(title: "New Task", message: "Add new task" , preferredStyle: .alert)
//        alertController.addTextField()
//        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
//            guard let textField = alertController.textFields?.first, textField.text != "" else { return }
//            
//             let task = Task(title: textField.text!, userId: (self?.user.uid)!)
//             let taskRef = self?.ref.child(task.title.lowercased())
//            taskRef?.setValue(task.convertToDictionary())
//        }
//        
//        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        alertController.addAction(save)
//        alertController.addAction(cancel)
//        
//        present(alertController, animated: true, completion: nil) 
        
    }
}
