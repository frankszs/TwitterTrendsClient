//
//  Storage.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 3/12/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import Foundation
import CoreData

public class Storage{
    
    private init(){}
    
    static var context : NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data
    
    static var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Data Methods
    
    static func trendIsSaved(trend : Trend) -> Bool{
        
        do{
            let savedTrends : [SavedTrend] =  try Storage.context.fetch(SavedTrend.fetchRequest())
            
            for savedTrend in savedTrends{
                if savedTrend.query == trend.query{
                    return true
                }
            }
           
        } catch {return false}
        return false
    }
    
    static func deleteSavedTrend(using trend : Trend) -> Bool{
        
        do{
            let savedTrends : [SavedTrend] =  try Storage.context.fetch(SavedTrend.fetchRequest())
            
            for savedTrend in savedTrends{
                if savedTrend.query == trend.query{
                    Storage.context.delete(savedTrend)
                    return true
                }
            }
            
        } catch {return false}
        return false
    }
}
