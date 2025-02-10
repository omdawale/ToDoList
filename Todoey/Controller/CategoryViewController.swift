import UIKit
import CoreData

class CategoryViewControllerTableViewController: UITableViewController {
    
    var itemCategory = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    //MARK: - TableView Datasource method
    ///**  Count a number of items in the list or List of Array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCategory.count
    }
    
    ///** Show an list or List of Array items on the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let item = itemCategory[indexPath.row]
        cell.textLabel?.text = item.name
        
        return cell
    }
    
    //MARK: - TableView Delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = itemCategory[indexPath.row]
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
            ///** CURD -- C -- Create Operations
            let newCategory = Category(context: self.context)
            newCategory.name = textFieldTo.text!
            self.itemCategory.append(newCategory)
            self.saveItems()
        }
        
        alert.addAction(action)
        /// ** Show or preview the alert popop up
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation method
    func saveItems() {
        do{
            try context.save()
        } catch {
            print("Error saving context\(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        // CURD - R -- Read Operations
        do{
            itemCategory = try context.fetch(request)
        } catch {
            print("Error\(error)")
        }
        tableView.reloadData()
    }
}


//tableView.deselectRow(at: indexPath, animated: true)
//
//// below line deonotes the removing a row in context.
//context.delete(itemCategory[indexPath.row])
//
//// below line denotes the removing a row in main table.
//itemCategory.remove(at: indexPath.row)
//
//self.saveItems()
//tableView.deselectRow(at: indexPath, animated: true)

