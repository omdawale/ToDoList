import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    ///** Iniitialzating Realm in Controller
    let realm = try! Realm()
    var itemCategory: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.rowHeight = 70.0
    }
    
    //MARK: - TableView Datasource method
    ///**  Count a number of items in the list or List of Array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCategory?.count ?? 1
    }
    
    ///** Show an list or List of Array items on the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = itemCategory?[indexPath.row].name ?? "No Categories Added Yet"
        
        cell.delegate = self
        
        return cell
    }
    
    //MARK: - TableView Delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = itemCategory?[indexPath.row]
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFieldTo = UITextField()
        
        // Create a small PoP up Alert Window
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        // Creating textField in Alert PoP UP
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a New Category"
            textFieldTo = alertTextField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            ///** CURD -- C -- Create Operations in Realm, Realm we dont need to append its simply autoupdate/append.(Result<Category>!)
            let newCategory = Category()
            newCategory.name = textFieldTo.text!
            self.saveItems(category: newCategory)
        }
        
        alert.addAction(action)
        /// ** Show or preview the alert popop up
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation method
    func saveItems(category: Category) {
        do{
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving context\(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(){
        // CURD - R -- Read Operations in Realm
        itemCategory = realm.objects(Category.self)
        self.tableView.reloadData()
    }
}

// MARK: - Extension of CategoryViewController -- 1. Swipe Cell Delegate Method
extension CategoryViewController: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item Deleted")
           
            
            if let categoryForDeletion = self.itemCategory?[indexPath.row]{
                //print(item.done)
                do{
                    try self.realm.write(){
                        /// ** CURD - D Operation in Realm
                        self.realm.delete(categoryForDeletion)
                    }
                } catch {
                    print("Error saving data: \(error)")
                }
            }
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}
