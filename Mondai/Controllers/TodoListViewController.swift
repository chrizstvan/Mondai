//
//  ViewController.swift
//  Mondai
//
//  Created by Christian Stevanus on 24/01/19.
//  Copyright © 2019 Christian Stevanus. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController
{
    
    var itemArray = [Item]()
    
    var selectedCategory : Category?{
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
        
        
        
        //<Load item by user defaulf method>
//        if let items = defaults.array(forKey: "ToDoListArray") as? [Item]{
//            itemArray = items
//        }
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Tableview Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //<To select complete uncomplete in table view>
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //<To delete item in table view on selected, REMEMBER the sequence, context must first>
        //contex.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        saveItem()
        
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
            
            
            let newItem = Item(context: self.contex)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            // what will happen when user click add button
            self.itemArray.append(newItem)
            
            // saving data using persistant data
            //self.defaults.set(self.itemArray, forKey: "ToDoListArray") <this not using anymore>
            
            // saving data is a method now! come look and see
            self.saveItem()
            
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
     <load data with coredata and sqlite method>
     */
    func loadItem(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil)
        {
            // ini di buat karena ad konflik pas query data search dan segue kategory
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            
            if let additionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            }
            else{
                request.predicate = categoryPredicate
            }
            
            do{
                itemArray = try contex.fetch(request)
            } catch{
                print("Error fetching data from contex: \(error)")
            }
            
            tableView.reloadData()
            
        }
    
  
    
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
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //quering database using NSPredicate, please chek it at cheatsheet from REALM
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) // [cd] stand for CASE and DIACRITIC
        
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        loadItem(with: request, predicate: predicate)
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

