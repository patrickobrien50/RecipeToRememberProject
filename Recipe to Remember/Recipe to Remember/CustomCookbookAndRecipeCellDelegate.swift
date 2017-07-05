//
//  CustomCookbookAndRecipeCellDelegate.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/27/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import Foundation
import UIKit

protocol CustomCookbookAndRecipeCellDelegate: class {
    func didSelectButtonAtIndexPathOfCell(sender: CustomCookbookAndRecipeCell)
}
