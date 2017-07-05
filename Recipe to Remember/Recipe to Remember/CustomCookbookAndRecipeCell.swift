//
//  CustomCookbookAndRecipeCell.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/27/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import Foundation
import UIKit

class CustomCookbookAndRecipeCell: UITableViewCell {
    
    weak var cellDelegate: CustomCookbookAndRecipeCellDelegate?
    
    @IBOutlet weak var editButton: UIButton!
    @IBAction func editButtonPressed(_ sender: UIButton) {
        print("Button Pressed")
        cellDelegate?.didSelectButtonAtIndexPathOfCell(sender: self)
    }
}
