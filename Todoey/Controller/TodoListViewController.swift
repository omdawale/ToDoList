import UIKit
import CoreData

class TodoListViewController: UITableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    /// **Creating an defaults constant for to retrive a small and convenient data using UserDefaults
    // let defaults = UserDefaults.standard
    
    /// **Initializing a context
    // We can used both ways to create a context.
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // let context = AppDelegate().persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        /// *** Removing cause add selectedCategory
        //loadItems()
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
        
        /// **We can use Ternary Operator instead of If else
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
        
        tableView.deselectRow(at: indexPath, animated: true)
        //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        /// **U in CRUD operation define as below
        // itemArray[indexPath.row].setValue("Ten", forKey: "One")
        
        /// **D in CRUD operation define as below.
        /// Remember the order always same First delete from context then from the delete.
       
        // below line deonotes the removing a row in context.
        context.delete(itemArray[indexPath.row])
        
        // below line denotes the removing a row in main table.
        itemArray.remove(at: indexPath.row)
        
        /// **We can use below one single line instead of if  else using not ! operator.
         itemArray[indexPath.row].done = !itemArray[indexPath.row].done
///        if itemArray[indexPath.row].Done == false{
///            itemArray[indexPath.row].Done = true
///        } else {
///            itemArray[indexPath.row].Done = false
///        }

        /// ** Creating a constant and initializing a property list encoder.
        /// It is used to encode Swift data types (like structs, classes, or collections) into Property List (plist) format.
        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        
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
        
        /// **Creating an alert when users  pressed the add button user get an small alert pop up to add items in the list. //Add a new item to your list
        let alert = UIAlertController(title: "To Do List", message: "", preferredStyle: .alert)
        
        /// **Creating a textfield in alert popup
        alert.addTextField { (alertTextField) in
            ///Creating a place holder in text field
            alertTextField.placeholder = "Add a new item"
            textFieldTo = alertTextField
        }
        
        let action = UIAlertAction(title: "Add New Item in List", style: .default) { (action) in
           
            /// **C in CRUD operation define as below
            /// Initializing a core Data
            // We can used both ways to create a context
            // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // let context = AppDelegate().persistentContainer.viewContext
            let newItem = Item(context: self.context)
            
            newItem.title = textFieldTo.text!
            newItem.done = false
            // Adding Parent Category
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
           
            /// **Creating a constant and initializing a property list encoder.
            /// It is used to encode Swift data types (like structs, classes, or collections) into Property List (plist) format.
            self.saveItems()
        
            //self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            
            /// **Reloading  a data which is newlly added in the list. Ii will show on table view
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        /// **Show or preview the alert popop up
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    func saveItems(){
        do{
            try context.save()
        } catch {
            print("Error saving context\(error)")
        }
        self.tableView.reloadData()
    }
    
    /// ***In below method we use external & internal parameter name also provide a default value after = sign.
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? =  nil){
        ///** Creating a predicate which is use for when we click on category it will show us the matching or that category related items
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        /// **R in CRUD operation define as below
        /// Below are using for the read the Data from Core data to Context and show on controller.
        /// let request: NSFetchRequest<Item> = Item.fetchRequest()
        do{
            itemArray = try context.fetch(request)
        } catch {
            print ("Unexpected error while fetching data from Context: \(error).")
        }
        self.tableView.reloadData()
    }
}

//MARK: - Extension of TodoListController.

extension TodoListViewController: UISearchBarDelegate {
   
    /// ** Using a delegate method for finding a when search bar search button is pressed.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        /// ** Below is like a SQL query to fetch the data on the basis of where condintion in SQL
        ///  ** in Swift we use NSPredicate(format:"title CONTAINS %@", searchBar.text)
        ///  here %@ use as where cndition. object’s attribute name is equal to value passed in
        // Addiding an quary to the request.
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        /// *** After getting a data for sorting we used NSSortDescriptor
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        /// *** OR
        /// we can use as below as well
        // request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        /// ***We can use below Method or create a do catch block manually.
        loadItems(with: request, predicate: predicate)
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



