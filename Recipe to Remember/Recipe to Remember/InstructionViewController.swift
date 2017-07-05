//
//  InstructionViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/26/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData

class InstructionViewController: UIViewController, UITextViewDelegate {
    
    var recipe: Recipe?{
        didSet{
            self.title = recipe?.name
        }
    }
    
    var editingTextBool: Bool?
    
    var text: String?
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsTextView.delegate = self
        instructionsTextView.isUserInteractionEnabled = true
        instructionsTextView.isEditable = editingTextBool ?? true
        instructionsTextView.text = recipe?.instructions ?? ""
        instructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        instructionsTextView.layer.borderWidth = CGFloat(0.5)
        self.automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(InstructionViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InstructionViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var instructionsTextView: UITextView!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        instructionsTextView.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin . y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView){
        recipe?.instructions = instructionsTextView.text
        print(recipe?.name ?? "Found nil")
        print(recipe?.instructions)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
