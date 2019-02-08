//
//  CategoryViewController.swift
//  Mondai
//
//  Created by Christian Stevanus on 26/01/19.
//  Copyright © 2019 Christian Stevanus. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    //using realm
    let realm = try! Realm()
    
    //using core data
    //var categoryArray = [Category]()
    
    //using realm
    var categoryArray: Results<Category_Realm>!
    
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    

    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //let category = categoryArray[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row]{
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.color)

            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: category.color)!, returnFlat: true)
        } else {
            cell.textLabel?.text = "No Caegories Added yet"
            cell.backgroundColor = UIColor(hexString: "FFFFFF")
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToItems"{
            
            let destinationVC = segue.destination as! TodoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow{
                
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
        }
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
       var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            
            //let newCategory = Category(context: self.contex) //this is using core data
            let newCategory = Category_Realm() //this is using realm
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            //increment row
            //self.categoryArray.append(newCategory) // realm dont need this line because its auto update
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category_Realm) {
        
        do
        {
            //try contex.save() //using core data
            try realm.write {
                realm.add(category)
            }
        }
        catch
        {
            print("Error saving context :: Category : \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategory()
    {
        //<This code below is when you use realm>
        categoryArray = realm.objects(Category_Realm.self)
        
        //<This code below is when you use core data>
//        let request: NSFetchRequest<Category> = Category.fetchRequest()
//
//        do
//        {
//            categoryArray = try contex.fetch(request)
//        }
//        catch
//        {
//            print("Error fetching data from contexr :: Category : \(error)")
//        }
//
        self.tableView.reloadData()
    }
    
    //MARK: - Delete using swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categoryArray?[indexPath.row]
        {
            do
            {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }

            } catch{
                print("Error delering category \(error)")
            }

            //tableView.reloadData()
        }
    }
    
}
