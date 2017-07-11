//
//  RecipeViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 7/2/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class RecipeViewController: UIViewController, CustomCookbookAndRecipeCellDelegate, UISearchBarDelegate {

    @IBOutlet weak var recipesSearchBar: UISearchBar!
    @IBOutlet weak var recipesTableView: UITableView!
    
    
    var cookbook: Cookbook? {
        didSet {
            self.title = cookbook?.name
        }
    }
    
    var recipes = [Recipe]()
    var filteredRecipes = [Recipe]()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var player: AVAudioPlayer?
    var searching = false
    var movingBackwards: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        recipesSearchBar.delegate = self
        recipesTableView.rowHeight = 134
        recipesTableView.tableFooterView = UIView()
 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if movingBackwards == true {
            animateTableBackwards()
        } else {
            animateTable()
            movingBackwards = true
        }
        print(movingBackwards!)
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        if movingBackwards! {
//            reversePageTurningFx()
//        }
//    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertController: UIAlertController = UIAlertController(title: "Add a recipe.", message: "Setting up a recipe for you, now just give it a name.", preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action -> Void in
        }
        
        let addAction: UIAlertAction = UIAlertAction(title: "Add", style: .default) {
            action -> Void in
            let text = (alertController.textFields?.first!)?.text
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "Recipe", into: self.managedObjectContext) as! Recipe
            
            newItem.name = text!
            newItem.cookbook = self.cookbook
            self.recipes.append(newItem)
            do {
                try self.managedObjectContext.save()
            } catch {
                print("This is the error: \(error)")
            }
            
            let indexPath: IndexPath = IndexPath(row: self.recipes.count - 1, section: 0)
            self.recipesTableView.reloadData()
            self.recipesTableView.reloadRows(at: [indexPath], with: .left)

            print("Here are the recipes", self.recipes)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { ( textField : UITextField!) -> Void in
            textField.placeholder = "Name this Recipe"
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func pageTurningFx() {
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
    
    func reversePageTurningFx() {
        guard let url = Bundle.main.url(forResource: "Reverse page turning", withExtension:".m4a") else {
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
    
    func animateTable() {
        recipesTableView.reloadData()
        
        let cells = recipesTableView.visibleCells
        
        let tableViewWidth = recipesTableView.bounds.size.width
        
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
    
    func animateTableBackwards() {
        recipesTableView.reloadData()
        
        let cells = recipesTableView.visibleCells
        
        let tableViewWidth = recipesTableView.bounds.size.width
        
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
        request.predicate = NSPredicate(format: "cookbook == %@", cookbook!)
        do {
            let result = try managedObjectContext.fetch(request)
            recipes = result as! [Recipe]
        } catch {
            print("\(error)")
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searching = true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredRecipes = recipes.filter({ (text) -> Bool in
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
        recipesTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        movingBackwards = true
        if segue.identifier == "RecipeSegue" {
            let ingredientsController = segue.destination as! IngredientAndInstructionViewController
            let indexPath: NSIndexPath
            
            if sender is UITableViewCell {
                indexPath = recipesTableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            } else {
                indexPath = sender as! NSIndexPath
            }
            let recipe = recipes[indexPath.row]
            ingredientsController.recipe = recipe
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

extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching == true {
            return filteredRecipes.count
        } else {
            return recipes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! CustomCookbookAndRecipeCell
        cell.cellDelegate = self
        cell.cellView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.cellView.layer.shadowOpacity = 1
        cell.cellView.layer.shadowOffset = CGSize(width: 2.0, height: -3.0)
        cell.cellView.layer.shadowRadius = 3
        cell.cellView.layer.cornerRadius = cell.cellView.layer.bounds.height / 10
        if searching {
            cell.editButton.setTitle(filteredRecipes[indexPath.row].name, for: .normal)
            cell.editButton.sizeToFit()
            return cell
            
        } else {
            cell.editButton.setTitle(recipes[indexPath.row].name, for: .normal)
            cell.editButton.sizeToFit()
            return cell
        }
    }
    
    
    func didSelectButtonAtIndexPathOfCell(sender: CustomCookbookAndRecipeCell) {
        let index = recipesTableView.indexPath(for: sender)
        let row = index?.row
        var recipe = recipes[row!]
        
        if searching {
            recipe = filteredRecipes[row!]
        }
        
        
        let alertController = UIAlertController(title: "Editing Recipe Name", message: "What would you like to rename this recipe", preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action -> Void in
        }
        let addAction: UIAlertAction = UIAlertAction(title: "Save", style: .default) {
            action -> Void in
            
            let text  = alertController.textFields?.first?.text
            recipe.name = text
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
            self.recipesTableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { ( textField : UITextField!) -> Void in
            textField.text = recipe.name
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        pageTurningFx()
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var recipe: Recipe?
        
        if searching {
            recipe = filteredRecipes.remove(at: indexPath.row)
        } else {
            recipe = recipes.remove(at: indexPath.row)
            
        }
        managedObjectContext.delete(recipe!)
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        recipesTableView.deleteRows(at: [indexPath], with: .fade)
        fetchAllItems()
        
    }

}
