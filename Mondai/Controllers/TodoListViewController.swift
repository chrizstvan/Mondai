//
//  ViewController.swift
//  Mondai
//
//  Created by Christian Stevanus on 24/01/19.
//  Copyright © 2019 Christian Stevanus. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController
{
    
    //var itemArray = [Item_Realm]()
    var todoItems: Results<Item_Realm>?
    let realm = try! Realm()
    
    var selectedCategory : Category_Realm?{
        didSet
        {
            loadItem()
        }
    }
    
    //<use code below when you using codable and plist method
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //<this singleton is not used anymore because data too large>
    //let defaults = UserDefaults()
    
    //contex is need to set for coredata seting
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        //<Load item by user defaulf method>
//        if let items = defaults.array(forKey: "ToDoListArray") as? [Item]{
//            itemArray = items
//        }
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) // without super class
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = FlatRedDark().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
            {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //<To select complete uncomplete in table view>
        //todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        
        //<To delete item in table view on selected, REMEMBER the sequence, context must first>
        //contex.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
       // saveItem()
        
        //ini cara update pake realm
        if let item = todoItems?[indexPath.row]
        {
            do
            {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch
            {
                print("Error saving data status \(error)")
            }
        }
        tableView.reloadData()
        
        //UI animation
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Mondai item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default)
        { (action) in
            
            
//            let newItem = Item(context: self.contex)
//            newItem.title = textField.text!
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
//
//            // what will happen when user click add button
//            self.itemArray.append(newItem)
            
            // saving data using persistant data
            //self.defaults.set(self.itemArray, forKey: "ToDoListArray") <this not using anymore>
            
            //<ini cara nambah item klo pake REALM>
            if let currentCategory = self.selectedCategory{
                
                do{
                    try self.realm.write {
                        let newItem = Item_Realm()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch
                {
                    print("Error saving item \(error)")
                }
                
            }
            self.tableView.reloadData()
            
            // saving data is a method now! come look and see
            //self.saveItem()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation
    
    /*
     <saving data with coredata and sqlite method>
     */
        func saveItem()
        {
            
            do
            {
                try contex.save()
            }
            catch
            {
                print("Error saving contex : \n(error)")
            }
    
            self.tableView.reloadData()
        }
    
    /*
     <load data with Realm>
     */
    
    func loadItem()
    {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Deletion Using Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemsForDeletion = self.todoItems?[indexPath.row]
        {
            do
            {
                try self.realm.write {
                    self.realm.delete(itemsForDeletion)
                }
                
            } catch{
                print("Error delering category \(error)")
            }
            
            //tableView.reloadData()
        }
    }
    
    /*
     <load data with coredata and sqlite method>
     */
//    func loadItem(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil)
//        {
//            // ini di buat karena ad konflik pas query data search dan segue kategory
//            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//            if let additionalPredicate = predicate {
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//            }
//            else{
//                request.predicate = categoryPredicate
//            }
//
//            do{
//                itemArray = try contex.fetch(request)
//            } catch{
//                print("Error fetching data from contex: \(error)")
//            }
//
//            tableView.reloadData()
//
//        }
    
  
    
    /*
     <saving data with codeable and plist method>
     */
//    func saveItem()
//    {
//        //saving data with new way
//        let encoder = PropertyListEncoder()
//
//        do
//        {
//            let data = try encoder.encode(self.itemArray)
//            try data.write(to: self.dataFilePath!)
//        }
//        catch
//        {
//            print("Error encoding itemArray : \n(error)")
//        }
//
//        self.tableView.reloadData()
//    }
    
    /*
    <load data with codeable and plist method
    */
//    func loadItem()
//    {
//        if let data = try? Data(contentsOf: dataFilePath!)
//        {
//            let decoder = PropertyListDecoder()
//
//            do
//            {
//                itemArray = try decoder.decode([Item].self, from: data)
//            }
//            catch
//            {
//                print("Error ecode item array, \n(error)")
//            }
//        }
//    }
    
}

//MARK: - Search bar section
extension TodoListViewController: UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//
//        //quering database using NSPredicate, please chek it at cheatsheet from REALM
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) // [cd] stand for CASE and DIACRITIC
//
//        request.predicate = predicate
//
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//
//        loadItem(with: request, predicate: predicate)
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0
        {
            loadItem()

            // this method will execute searchbar.resingFirstResponder to foreground
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
}

