//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    /// Creating an defaults constant for to retrive a small and convenient data using UserDefaults
    // let defaults = UserDefaults.standard
    
    /// Initializing a context
    // We can used both ways to create a context.
    // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let context = AppDelegate().persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(dataFilePath)
        
        loadItems()
        
    }
    
    //MARK: - Count a number of items in the list or List of Araay
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: - Show an list or List of Array items on the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("celForRowAt")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        /// We can use Ternary Operator instead of If else
        /// Ternary Operator --> value = condition ? valueifTrue : valueifFalse
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
///        if item.Done == true {
///            cell.accessoryType = .checkmark
///        } else {
///            cell.accessoryType = .none
///        }
         
        return cell
    }
    
    //MARK: - Select a row and mark as check tick mark
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        /// We can use below one single line instead of if  else using not ! operator.
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
///        if itemArray[indexPath.row].Done == false{
///            itemArray[indexPath.row].Done = true
///        } else {
///            itemArray[indexPath.row].Done = false
///        }

        /// Creating a constant and initializing a property list encoder.
        /// It is used to encode Swift data types (like structs, classes, or collections) into Property List (plist) format.
        self.saveItems()
        
        tableView.reloadData()
        
///        if let cell = tableView.cellForRow(at: indexPath) {
///             if cell.accessoryType == .checkmark {
///                 cell.accessoryType = .none /// Remove checkmark if it’s already selected
///             } else {
///                 cell.accessoryType = .checkmark /// Add checkmark
///             }
///         }
    }
    
    //MARK: - Add a new Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFieldTo = UITextField()
        
        /// Creating an alert when users  pressed the add button user get an small alert pop up to add items in the list. //Add a new item to your list//
        let alert = UIAlertController(title: "To Do List", message: "", preferredStyle: .alert)
        
        /// Creating a textfield in alert popup
        alert.addTextField { (alertTextField) in
            ///Creating a place holder in text field
            alertTextField.placeholder = "Add a new item"
            textFieldTo = alertTextField
        }
        
        let action = UIAlertAction(title: "Add New Item in List", style: .default) { (action) in
           
            /// Initializing a core Data
            // We can used both ways to create a context
            // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            //let context = AppDelegate().persistentContainer.viewContext
            let newItem = Item(context: self.context)
            
            newItem.title = textFieldTo.text!
            newItem.done = false
            self.itemArray.append(newItem)
           
            /// Creating a constant and initializing a property list encoder.
            /// It is used to encode Swift data types (like structs, classes, or collections) into Property List (plist) format.
            self.saveItems()

            
            //self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            
            /// Reloading  a data which is newlly added in the list. Ii will show on table view
            self.tableView.reloadData()
        
        }
        
        alert.addAction(action)
        
        /// Show or preview the alert popop up
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    func saveItems(){
        do{
            try context.save()
        } catch {
            print("Error saving context\(error)")
        }
    }
    
    func loadItems(){
        /// Below are using for the read the Data from Core data to Context and show on controller.
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do{
            itemArray = try context.fetch(request)
        } catch {
            print ("Unexpected error while fetching data from Context: \(error).")
        }
    }
}

