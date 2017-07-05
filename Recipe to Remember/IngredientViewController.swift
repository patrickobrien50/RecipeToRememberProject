//
//  IngredientViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/25/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData

class IngredientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var componentOneRow = 0
    var componentTwoRow = 0
    var componentThreeRow = 0
    
    var ingredientToEdit: Ingredient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is self", self)
        print("This is the ingredient \(ingredientToEdit)")
        nameTextField.text = ingredientToEdit?.name ?? ""
        measurementPickerView.selectRow(Int(ingredientToEdit?.rowOneValue ?? 0), inComponent: 0, animated: true)
        measurementPickerView.selectRow(Int(ingredientToEdit?.rowTwoValue ?? 0), inComponent: 1, animated: true)
        measurementPickerView.selectRow(Int(ingredientToEdit?.rowThreeValue ?? 0), inComponent: 2, animated: true)
        componentOneRow = Int(ingredientToEdit?.rowOneValue ?? 0)
        componentTwoRow = Int(ingredientToEdit?.rowTwoValue ?? 0)
        componentThreeRow = Int(ingredientToEdit?.rowThreeValue ?? 0)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelButtonPressed(by: self)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        if ingredientToEdit == nil {
            let ingredient = Ingredient(entity: NSEntityDescription.entity(forEntityName: "Ingredient", in: managedObjectContext)!, insertInto: managedObjectContext)
            if nameTextField.text == "" {
                let alertController: UIAlertController = UIAlertController(title: "Invalid Entry", message: "You must name the ingredient before adding it to your recipe!", preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) {
                    action -> Void in
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                ingredient.name = nameTextField.text
                let amount = pickerView(measurementPickerView, titleForRow: componentOneRow, forComponent: 0)
                let amountFraction = pickerView(measurementPickerView, titleForRow: componentTwoRow, forComponent: 1)
                let measurement = pickerView(measurementPickerView, titleForRow: componentThreeRow, forComponent: 2)
                if componentOneRow == 0 && componentTwoRow == 0 {
                    let alertController: UIAlertController = UIAlertController(title: "Invalid Entry", message: "You must have a proper quantity before adding an ingredient to your recipe!", preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) {
                        action -> Void in
                    }
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    ingredient.rowOneValue = Int64(componentOneRow)
                    ingredient.rowTwoValue = Int64(componentTwoRow)
                    ingredient.rowThreeValue = Int64(componentThreeRow)
                    if componentOneRow != 0 && componentTwoRow != 0 {
                        ingredient.measurement = "\(amount!)\(amountFraction!) \(measurement!)"
                        delegate?.itemSaved(by: self, with: ingredient)
                    } else if componentOneRow == 0 && componentTwoRow != 0 {
                        ingredient.measurement = "\(amountFraction!) \(measurement!)"
                        delegate?.itemSaved(by: self, with: ingredient)
                    } else {
                        ingredient.measurement = "\(amount!) \(measurement!)"
                        delegate?.itemSaved(by: self, with: ingredient)
                    }
                }
            }
        } else {
            let amount = pickerView(measurementPickerView, titleForRow: componentOneRow, forComponent: 0)
            let amountFraction = pickerView(measurementPickerView, titleForRow: componentTwoRow, forComponent: 1)
            let measurement = pickerView(measurementPickerView, titleForRow: componentThreeRow, forComponent: 2)
            ingredientToEdit?.name = nameTextField.text
            ingredientToEdit?.rowOneValue = Int64(componentOneRow)
            ingredientToEdit?.rowTwoValue = Int64(componentTwoRow)
            ingredientToEdit?.rowThreeValue = Int64(componentThreeRow)
            if componentTwoRow != 0 {
                ingredientToEdit?.measurement = "\(amount!)\(amountFraction!) \(measurement!)"
                delegate?.itemEdited(by: self)
            } else if componentOneRow == 0 && componentTwoRow != 0 {
                ingredientToEdit?.measurement = "\(amountFraction!) \(measurement!)"
                delegate?.itemEdited(by: self)
            } else {
                ingredientToEdit?.measurement = "\(amount!) \(measurement!)"
                delegate?.itemEdited(by: self)
            }
        }
    }
    weak var delegate: IngredientAndInstructionViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
        
    @IBOutlet weak var measurementPickerView: UIPickerView!
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row, component)
        switch component {
        case 0:
            componentOneRow = row
            print("Component One Row: ", componentOneRow)
        case 1:
            componentTwoRow = row
            print("Component Two Row: ", componentOneRow)

        case 2:
            componentThreeRow = row
            print("Component Three Row: ", componentOneRow)

        default: break
            
        }
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 100
        case 1:
            return 6
        case 2:
            return 8
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row)"
        case 1:
            switch row {
            case 0:
                return ""
            case 1:
                return "¼"
            case 2:
                return "⅓"
            case 3:
                return "½"
            case 4:
                return "⅔"
            case 5:
                return "¾"
            default:
                return " "
            }
        case 2:
            switch row {
            case 0:
                return "ct"
            case 1:
                return "oz"
            case 2:
                return "cups"
            case 3:
                return "pint"
            case 4:
                return "tsp"
            case 5:
                return "tbsp"
            case 6:
                return "grams"
            case 7:
                return "lbs"
            default:
                return ""
            }
        default:
            return ""
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
