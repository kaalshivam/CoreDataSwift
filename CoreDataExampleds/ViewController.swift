//
//  ViewController.swift
//  CoreDataExampleds
//
//  Created by Shivam Sharma on 09/11/22.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var userNameTF       : UITextField!
    @IBOutlet weak var emailTF          : UITextField!
    @IBOutlet weak var passwordTF       : UITextField!
    
    @IBOutlet weak var usersTableView   : UITableView!
    
    var userList                        = [USER]()
    var isUpdating                      = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTF.delegate     = self
        emailTF.delegate        = self
        passwordTF.delegate     = self
        usersTableView.delegate = self
        usersTableView.dataSource = self
        self.retrieveData()
    }
    
    @IBAction func saveBTN(_ sender: Any) {
        if( userNameTF.text ?? "" == "" || emailTF.text ?? "" ==
        "" || passwordTF.text ?? "" == "")
        {
            let alert = UIAlertController(title: "Error", message: "Kindly Fill All The fields", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        }
        
        else{
            if isUpdating{
                updateData(userNameTF.text ?? "", emailTF.text ?? "", passwordTF.text ?? "")
                isUpdating = !isUpdating
            }
            else{
                createData(userNameTF.text ?? "", emailTF.text ?? "", passwordTF.text ?? "")
            }
            self.retrieveData()
            self.usersTableView.reloadData()
            userNameTF.text = ""
            emailTF.text = ""
            passwordTF.text = ""
        }
    }
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTVC") as! UserTVC
        cell.emailLBL.text = userList[indexPath.row].email
        cell.nameLBL.text = userList[indexPath.row].name
        cell.numberLBL.text = "\(indexPath.row+1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            let alert = UIAlertController(title: "Alert" , message: "Do you want to edit this record ?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {_ in
                self.isUpdating = true
                self.userNameTF.text = self.userList[indexPath.row].name
                self.emailTF.text = self.userList[indexPath.row].email
                self.passwordTF.text = self.userList[indexPath.row].password
            }))
            self.present(alert, animated: true, completion: nil)
        }
        item.image = UIImage(systemName: "square.and.pencil")
        let swipeActions = UISwipeActionsConfiguration(actions: [item])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            let alert = UIAlertController(title: "Alert" , message: "Are You Sure to Delte The Record", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {_ in
                if let name = self.userList[indexPath.row].name{
                    self.deleteData(name)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        item.image = UIImage(systemName: "trash")
        let swipeActions = UISwipeActionsConfiguration(actions: [item])
        return swipeActions
    }
    
}


extension ViewController {
    func createData(_ name : String , _ email : String , _ password: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(name, forKeyPath: "username")
            user.setValue(email, forKey: "email")
            user.setValue(password, forKey: "password")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            var user = USER()
            userList.removeAll()
            for data in result as! [NSManagedObject] {
                user.name = data.value(forKey: "username") as? String ?? ""
                user.password = data.value(forKey: "password") as? String ?? ""
                user.email  = data.value(forKey: "email") as? String ?? ""
                self.userList.append(user)
            }
            self.usersTableView.reloadData()
        }
        catch {
            print("Failed")
        }
    }
    
    func updateData(_ name : String , _ password : String , _ email : String ){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username = %@", name)
        do
        {
            let test = try managedContext.fetch(fetchRequest)
   
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(name, forKey: "username")
                objectUpdate.setValue(email, forKey: "email")
                objectUpdate.setValue(password, forKey: "password")
                do{
                    try managedContext.save()
                }
                catch
                {
                    print(error)
                }
            self.retrieveData()

            }
        catch
        {
            print(error)
        }
   
    }
    
    func deleteData(_ name : String){
     
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username = %@", name )
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
            self.retrieveData()

        }
        catch
        {
            print(error)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
