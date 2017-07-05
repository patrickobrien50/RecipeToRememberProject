//
//  Cookbook+CoreDataProperties.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/25/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import Foundation
import CoreData


extension Cookbook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cookbook> {
        return NSFetchRequest<Cookbook>(entityName: "Cookbook")
    }

    @NSManaged public var name: String?
    @NSManaged public var recipes: NSSet?

}

// MARK: Generated accessors for recipes
extension Cookbook {

    @objc(addRecipesObject:)
    @NSManaged public func addToRecipes(_ value: Recipe)

    @objc(removeRecipesObject:)
    @NSManaged public func removeFromRecipes(_ value: Recipe)

    @objc(addRecipes:)
    @NSManaged public func addToRecipes(_ values: NSSet)

    @objc(removeRecipes:)
    @NSManaged public func removeFromRecipes(_ values: NSSet)

}
