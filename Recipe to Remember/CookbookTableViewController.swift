//
//  CookbookTableViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/22/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData

class CookbookTableViewController: UITableViewController, CustomCookbookAndRecipeCellDelegate {
    
    
    var cookbooks = [Cookbook]()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBAction func addCookbookButton(_ sender: UIBarButtonItem) {
        
        let alertController: UIAlertController = UIAlertController(title: "Create a cookbook.", message: "Setting up a cookbook for you, now just give it a name.", preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action -> Void in
        }
        
        let addAction: UIAlertAction = UIAlertAction(title: "Add", style: .default) {
            action -> Void in
            let text = (alertController.textFields?.first!)?.text
            
            if text == "" {
                let errorController: UIAlertController = UIAlertController(title: "Invalid Entry", message: "Must provide at least one character to name a cookbook!", preferredStyle: .alert)
                
                errorController.addAction(cancelAction)
                self.present(errorController, animated: true, completion: nil)
                
            } else {
                let newItem = NSEntityDescription.insertNewObject(forEntityName: "Cookbook", into: self.managedObjectContext) as! Cookbook
                
                newItem.name = text!
                self.cookbooks.append(newItem)
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("This is the error: \(error)")
                }
                
                
                self.tableView.reloadData()
                print(self.cookbooks)
                

            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { ( textField : UITextField!) -> Void in
            textField.placeholder = "Name this Cookbook"
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
    }
    
    func fetchAllItems() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cookbook")
        do {
            let result = try managedObjectContext.fetch(request)
            cookbooks = result as! [Cookbook]
        } catch {
            print("\(error)")
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cookbooks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CookbookCell", for: indexPath) as! CustomCookbookAndRecipeCell
        cell.editButton.setTitle(cookbooks[indexPath.row].name, for: .normal)
        cell.editButton.sizeToFit()
        cell.cellDelegate = self
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CookbookSegue" {
            let recipesController = segue.destination as! RecipesTableViewController
            let indexPath: NSIndexPath

            if sender is UITableViewCell {
                indexPath = tableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            } else {
                indexPath = sender as! NSIndexPath
            }
            let cookbook = cookbooks[indexPath.row]
            recipesController.cookbook = cookbook
        }
    }
    
    func didSelectButtonAtIndexPathOfCell(sender: CustomCookbookAndRecipeCell) {
        let index = tableView.indexPath(for: sender)
        let row = index?.row
        
        let cookbook = cookbooks[row!]
        
        let alertController = UIAlertController(title: "Editing Cookbook Name", message: "What would you like to name this cookbook?", preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action -> Void in
        }
        let addAction: UIAlertAction = UIAlertAction(title: "Save", style: .default) {
            action -> Void in
            
            let text  = alertController.textFields?.first?.text
            cookbook.name = text
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { ( textField : UITextField!) -> Void in
            textField.text = cookbook.name
        }
        
        self.present(alertController, animated: true, completion: nil)


        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cookbook = cookbooks.remove(at: indexPath.row)
        managedObjectContext.delete(cookbook)
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        fetchAllItems()
        tableView.reloadData()
        
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
