import UIKit
import RealmSwift

class TodoListViewController: UITableViewController, UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        /// *** Removing cause add selectedCategory
        loadItems()
    }
    
    //MARK: - Count a number of items in the list or List of Araay
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //MARK: - Show an list or List of Array items on the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.Title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items to show"
        }
        return cell
    }
    
    //MARK: - Select a row and mark as check tick mark
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        /// **U in CRUD operation in Realm define as below
        if let item = todoItems?[indexPath.row]{
            //print(item.done)
            do{
                try realm.write(){
                    /// ** CURD - D Operation in Realm
                    //realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving data: \(error)")
            }
        }
        self.tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add a new Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFieldTo = UITextField()
        
        /// **Creating an alert when users  pressed the add button user get an small alert pop up to add items in the list. //Add a new item to your list
        let alert = UIAlertController(title: "To Do List", message: "", preferredStyle: .alert)
        
        /// **Creating a textfield in alert popup
        alert.addTextField { (alertTextField) in
            ///Creating a place holder in text field
            alertTextField.placeholder = "Add a new item"
            textFieldTo = alertTextField
        }
        
        let action = UIAlertAction(title: "Add New Item in List", style: .default) { (action) in
           
            /// **C in CRUD in Realm
            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.Title = textFieldTo.text!
                        currentCategory.items.append(newItem )
                    }
                } catch {
                    print("Error in saving new Items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        /// **Show or preview the alert popop up
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
//
    
    /// ***In below method we use external & internal parameter name also provide a default value after = sign.
    func loadItems(){
        /// **R in CRUD operation define as below
        todoItems = selectedCategory?.items.sorted(byKeyPath: "Title", ascending: true)
        self.tableView.reloadData()
    }
}

// MARK: - Extension of TodoListController.

//extension TodoListViewController: UISearchBarDelegate {
//   
//    /// ** Using a delegate method for finding a when search bar search button is pressed.
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        
//        /// ** Below is like a SQL query to fetch the data on the basis of where condintion in SQL
//        ///  ** in Swift we use NSPredicate(format:"title CONTAINS %@", searchBar.text)
//        ///  here %@ use as where cndition. object’s attribute name is equal to value passed in
//        // Addiding an quary to the request.
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        
//        /// *** After getting a data for sorting we used NSSortDescriptor
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//        /// *** OR
//        /// we can use as below as well
//        // request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        
//        /// ***We can use below Method or create a do catch block manually.
//        loadItems(with: request, predicate: predicate)
//    }
//    
//    /// ** Below delegate method is triggerred whenever the user type in search bar and show the result
//    /// if user has cleared the search bar then it will again back to original view.
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0{
//            loadItems()
//            
//            ///** It (resignFirstResponder()) will use for the came back to original view controller, that is dismissed the keyboard and pointer in the search bar.
//            ///***Used with Queue Async call. It will run in background and UI not showing as busy.
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}
//
