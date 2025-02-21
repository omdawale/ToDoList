import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
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
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.Title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items to show"
        }
        
        // Use ChameleonFramework for the UI Colours
        cell.backgroundColor = UIColor(hexString: todoItems?[indexPath.row].color ?? "FFDFEF")
        
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
                        newItem.dateCreated = Date()
                        newItem.color = RandomFlatColor().hexValue()
                        currentCategory.items.append(newItem)
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
    func loadItems(){
        /// **R in CRUD operation define as below
        todoItems = selectedCategory?.items.sorted(byKeyPath: "Title", ascending: true)
        self.tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            //print(item.done)
            do{
                try self.realm.write(){
                    /// ** CURD - D Operation in Realm
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error saving data: \(error)")
            }
        }
    }
}

// MARK: - Extension of TodoListController.

extension TodoListViewController: UISearchBarDelegate {
    /// ** Using a delegate method for finding a when search bar search button is pressed.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        /// ** Query in Realm -- Take a List Item and  filter them.
        todoItems = todoItems?.filter("Title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true )
        self.tableView.reloadData()
    }
    
    /// ** Below delegate method is triggerred whenever the user type in search bar and show the result
    /// if user has cleared the search bar then it will again back to original view.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            ///** It (resignFirstResponder()) will use for the came back to original view controller, that is dismissed the keyboard and pointer in the search bar.
            ///***Used with Queue Async call. It will run in background and UI not showing as busy.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

