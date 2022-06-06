import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]() //itemArray is used to load up the table view data source
    
    var selectedCategory: Categories? {
        didSet{
            loadItems()
        }
    }
    
    let contextItem = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let currentItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = currentItem.title
        
//        currentItem.check ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        cell.accessoryType = currentItem.check ? .checkmark : .none
        
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
        itemArray[indexPath.row].check = !itemArray[indexPath.row].check
        
        saveItems() // After every change, context has to be saved and commit the current status to the persistent container.
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Add New Items
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var itemAddTextField = UITextField()
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            
            let newItem = Item(context: self.contextItem)
            newItem.title = itemAddTextField.text!
            newItem.check = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            itemAddTextField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
 
    
    // MARK: - Model Manupulation Methods
    
    func saveItems() {
        
        do {
            try contextItem.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(),
                   predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do { // do-catch block is updating the itemArray which will be shown to user.
            itemArray = try contextItem.fetch(request) // returns NSFetchRequestResult which is an array of items. itemArray:[item]
        } catch {
            print("Error reading context \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            self.contextItem.delete(self.itemArray[indexPath.row])  // removing the item from the permanent store
            self.itemArray.remove(at: indexPath.row)                // removing the cureent item from the itemArray

            // contextItem is temporary area. It must be saved after the change.
            // contextItem.delete must be called first. then itemArray.remove. The order matters.
            
            self.saveItems()
        }
        
        return [deleteAction]
    }
    
}

// MARK: - SearchBar methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicateContains = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] // for sorting items
        
        loadItems(with: request, predicate: predicateContains)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

