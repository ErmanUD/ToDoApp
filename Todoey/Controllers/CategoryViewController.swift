import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoriesArray = [Categories]()
    let contextCategory = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) // prototype cell identifier
        
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*
        contextCategory.delete(categoriesArray[indexPath.row]) // removing the data from the permanent store
        categoriesArray.remove(at: indexPath.row) // removing the cureent item from the itemArray
        // contextItem is temporary area. It must be saved after the change.
        // contextItem.delete must be called first. then itemArray.remove. The order matters.
         */
        
//        saveCategories()
//        tableView.deselectRow(at: indexPath, animated: true)

        
        performSegue(withIdentifier: "goToItems", sender: self)
                
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoriesArray[indexPath.row]
        }
    }

    
    // MARK: - Data Manipulation Methods
    
    func saveCategories() {
        
        do {
            try contextCategory.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData() // to update tableView with latest data
    }
    
    func loadCategories(with request: NSFetchRequest<Categories> = Categories.fetchRequest()) {
        
        do { // do-catch block is updating the categoryArray which will be shown to user.
            categoriesArray = try contextCategory.fetch(request) // returns NSFetchRequestResult which is an array of categories. categoryArray:[categories]
        } catch {
            print("Error reading context \(error)")
        }
        
        tableView.reloadData()
    }
    

    // MARK: - Add New Categories
    
    @IBAction func addButonnTapped(_ sender: UIBarButtonItem) {
        
        var categoryAddTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            
            let newCategory = Categories(context: self.contextCategory)
            newCategory.name = categoryAddTextField.text!
            
            self.categoriesArray.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            categoryAddTextField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
