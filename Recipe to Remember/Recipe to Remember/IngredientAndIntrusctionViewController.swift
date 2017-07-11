//
//  RecipeViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/22/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class IngredientAndInstructionViewController: UIViewController, IngredientAndInstructionViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    var ingredients = [Ingredient]()
    
    var recipe: Recipe? {
        didSet {
            self.title = recipe?.name
        }
    }
    var movingBackwards = true
    
    @IBOutlet weak var startCookingButton: UIButton!
    @IBOutlet weak var editInstructionsButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    var player: AVAudioPlayer?

    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let transition = CircularTransition()
    
    @IBAction func addIngredientButton(_ sender: UIBarButtonItem) {
        
    
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = self.view.center
        transition.circleColor = self.view.backgroundColor!
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = self.view.center
        transition.circleColor = self.view.backgroundColor!
        
        return transition
    }
    
    @IBOutlet weak var ingredientTableView: UITableView!
    

    override func viewWillAppear(_ animated: Bool) {
        movingBackwards = true
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        if movingBackwards {
//            reversePageTurningFx()
//        }
//    }
    
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

    
    func fetchAllItems() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        request.predicate = NSPredicate(format: "recipe == %@", recipe!)
        do {
            let result = try managedObjectContext.fetch(request)
            ingredients = result as! [Ingredient]
        } catch {
            print("\(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientTableView.dataSource = self
        ingredientTableView.delegate = self
        ingredientTableView.layer.cornerRadius = 10
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shadowOffset = CGSize(width: 3, height: -3)
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 3
        editInstructionsButton.layer.cornerRadius = 5
        startCookingButton.layer.cornerRadius = 5
        print(recipe?.name ?? "Found nil")
        fetchAllItems()

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IngredientSegue" {
            let navigationController = segue.destination as! UINavigationController
            let ingredientController = navigationController.topViewController as! IngredientViewController
            ingredientController.delegate = self
        } else if segue.identifier == "EditIngredientSegue" {
            let navigationController = segue.destination as! UINavigationController
            let ingredientController = navigationController.topViewController as! IngredientViewController
            ingredientController.delegate = self
            let cell = sender as? UITableViewCell
            let index = ingredientTableView.indexPath(for: cell!)?.row
            let ingredient = ingredients[index!]
            ingredientController.ingredientToEdit = ingredient
        } else if segue.identifier == "EditInstructionsSegue" {
            let instructionViewController = segue.destination as! InstructionViewController
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            instructionViewController.editingTextBool = true
            instructionViewController.transitioningDelegate = self
            instructionViewController.modalPresentationStyle = .custom
            let recipe = self.recipe
            print("This is the recipe we will be editing: \(String(describing: recipe?.name))")
            instructionViewController.recipe = recipe
        } else if segue.identifier == "StartCookingSegue" {
            let instructionViewController = segue.destination as! InstructionViewController
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            instructionViewController.editingTextBool = false
            let recipe = self.recipe
            instructionViewController.recipe = recipe
            instructionViewController.transitioningDelegate = self
            instructionViewController.modalPresentationStyle = .custom
        }
    }
    
    func itemSaved(by controller: IngredientViewController, with ingredient: Ingredient) {
        let newIngredient = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: self.managedObjectContext) as! Ingredient
        newIngredient.name = ingredient.name
        newIngredient.measurement = ingredient.measurement
        newIngredient.rowOneValue = ingredient.rowOneValue
        newIngredient.rowTwoValue = ingredient.rowTwoValue
        newIngredient.rowThreeValue = ingredient.rowThreeValue
        newIngredient.recipe = recipe
        ingredients.append(newIngredient)
        print(newIngredient)
        do {
            try self.managedObjectContext.save()
        } catch {
            print("This is the error: \(error)")
        }
        dismiss(animated: true, completion: nil)
        ingredientTableView.reloadData()

    }
    
    func itemEdited(by controller: IngredientViewController) {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
        dismiss(animated: true, completion: nil)
        ingredientTableView.reloadData()
    }
    
    func cancelButtonPressed(by controller: IngredientViewController) {
        dismiss(animated: true, completion: nil)
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

extension IngredientAndInstructionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        cell.textLabel?.text = ingredients[indexPath.row].name
        cell.detailTextLabel?.text = ingredients[indexPath.row].measurement
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let ingredient = ingredients.remove(at: indexPath.row)
        managedObjectContext.delete(ingredient)
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
        fetchAllItems()
        
    }
    
}
