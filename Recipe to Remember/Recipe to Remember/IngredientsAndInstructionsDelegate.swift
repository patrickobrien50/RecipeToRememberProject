//
//  IngredientsAndInstructionsDelegate.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/25/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import Foundation
import UIKit

protocol IngredientAndInstructionViewControllerDelegate: class {
    func itemSaved(by controller: IngredientViewController, with ingredient: Ingredient)
    func itemEdited(by controller: IngredientViewController)
    func cancelButtonPressed(by controller: IngredientViewController)
}
