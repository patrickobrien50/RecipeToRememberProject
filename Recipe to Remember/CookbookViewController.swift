//
//  CookbookViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 7/2/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//
import CoreData
import UIKit
import AVFoundation

class CookbookViewController: UIViewController, CustomCookbookAndRecipeCellDelegate, UISearchBarDelegate {
    
    var cookbooks = [Cookbook]()
    var filteredCookbooks = [Cookbook]()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var player: AVAudioPlayer?
    var viewAppeared: Bool?
    var searching = false
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
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
                let indexPath: IndexPath = IndexPath(row: self.cookbooks.count - 1, section: 0)
                self.cookbookTableView.reloadData()
                self.cookbookTableView.reloadRows(at: [indexPath], with: .left)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        cookbookTableView.delegate = self
        cookbookTableView.dataSource = self
        cookbookSearchBar.delegate = self
        cookbookTableView.rowHeight = 134
        fetchAllItems()
        print(cookbooks)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewAppeared == nil {
        animateTable()
            viewAppeared = true
        } else {
            animateTableBackwards()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CookbookSegue" {
            let recipesController = segue.destination as! RecipeViewController
            recipesController.movingBackwards = false
            let indexPath: NSIndexPath
            
            if sender is UITableViewCell {
                indexPath = cookbookTableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            } else {
                indexPath = sender as! NSIndexPath
            }
            let cookbook = cookbooks[indexPath.row]
            recipesController.cookbook = cookbook
        }
    }
    
    func segueFx() {
        guard let url = Bundle.main.url(forResource: "Page turning", withExtension:".m4a") else {
            print("url not found")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player!.play()
        } catch _ as NSError {
            print("Error")
        }
    }
    
    func animateTableBackwards() {
        cookbookTableView.reloadData()
        
        let cells = cookbookTableView.visibleCells
        
        let tableViewWidth = cookbookTableView.bounds.size.width
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: tableViewWidth * -1, y: 0)
        }
        
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 1.0, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
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

    
    
    @IBOutlet weak var cookbookSearchBar: UISearchBar!

    @IBOutlet weak var cookbookTableView: UITableView!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searching = true
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCookbooks = cookbooks.filter({ (text) -> Bool in
            let tmp = text.name! as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            print(tmp)
            print(range)
            print(searchText)
            return range.location != NSNotFound
        })
        if searchText == "" {
            searching = false
        } else {
            searching = true
        }
        animateTable()
//        cookbookTableView.reloadData()
    }
    
    func animateTable() {
        cookbookTableView.reloadData()
        
        let cells = cookbookTableView.visibleCells
        
        let tableViewWidth = cookbookTableView.bounds.size.width
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: tableViewWidth, y: 0)
        }
        
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 1.0, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }



    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension CookbookViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching == true {
            return filteredCookbooks.count
        } else {
            return cookbooks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CookbookCell", for: indexPath) as! CustomCookbookAndRecipeCell
        cell.cellDelegate = self
        cell.cellView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.cellView.layer.shadowOpacity = 1
        cell.cellView.layer.shadowOffset = CGSize(width: 4.0, height: -5.0)
        cell.cellView.layer.shadowRadius = 3
        cell.cellView.layer.cornerRadius = cell.cellView.layer.bounds.height / 20
        if searching {
            cell.editButton.setTitle(filteredCookbooks[indexPath.row].name, for: .normal)
            cell.editButton.sizeToFit()
            return cell
            
        } else {
            cell.editButton.setTitle(cookbooks[indexPath.row].name, for: .normal)
            cell.editButton.sizeToFit()
            return cell
        }
    }
    
   
    func didSelectButtonAtIndexPathOfCell(sender: CustomCookbookAndRecipeCell) {
        let index = cookbookTableView.indexPath(for: sender)
        let row = index?.row
        var cookbook = cookbooks[row!]
        
        if searching {
            cookbook = filteredCookbooks[row!]
        }

        
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
            self.cookbookTableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { ( textField : UITextField!) -> Void in
            textField.text = cookbook.name
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        segueFx()
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var cookbook: Cookbook?
        
        if searching {
            cookbook = filteredCookbooks.remove(at: indexPath.row)
        } else {
            cookbook = cookbooks.remove(at: indexPath.row)

        }
        managedObjectContext.delete(cookbook!)
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        cookbookTableView.deleteRows(at: [indexPath], with: .fade)
        fetchAllItems()
        
    }

    
    
    
    
    
}
