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

    @IBOutlet weak var shadowView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsTextView.delegate = self
        instructionsTextView.isUserInteractionEnabled = true
        instructionsTextView.isEditable = editingTextBool ?? true
        instructionsTextView.text = recipe?.instructions ?? ""
        instructionsTextView.layer.cornerRadius = 10
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shadowOffset = CGSize(width: 3.0, height: -3.0)
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 3
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateTextView()
    }
    @IBOutlet weak var instructionsTextView: UITextView!
    
    

    @IBAction func doneButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
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
    
    func animateTextView() {
        
        
        let textViewHeight = instructionsTextView.bounds.size.height
        

        instructionsTextView.transform = CGAffineTransform(translationX: 0, y: textViewHeight)
        shadowView.transform = CGAffineTransform(translationX: 0, y: textViewHeight)
        
        
        
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.instructionsTextView.transform = CGAffineTransform.identity
                self.shadowView.transform = CGAffineTransform.identity
            }, completion: nil)
        
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
