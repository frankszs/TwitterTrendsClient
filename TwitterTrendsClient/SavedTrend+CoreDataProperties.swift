//
//  SavedTrend+CoreDataProperties.swift
//  
//
//  Created by f0dsterz on 2/12/17.
//
//

import Foundation
import CoreData


extension SavedTrend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedTrend> {
        return NSFetchRequest<SavedTrend>(entityName: "SavedTrend")
    }

    @NSManaged public var name: String?
    @NSManaged public var query: String?

}
