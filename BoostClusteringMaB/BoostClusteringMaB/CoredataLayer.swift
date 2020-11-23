//
//  CoreDataLayer.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/23.
//

import CoreData

protocol CoreDataManager {
    func add(place: Place, completion handler: (() -> Void)?) throws
    func fetch() throws -> [POI]
    func remove(at: Int) throws
    func removeAll() throws
    func save() throws
}

class CoreDataLayer {
    enum CoreDataError: Error {
        case invalidCoordinate
        case saveError(String)
        case invalidType
    }
    
    lazy var childContext: NSManagedObjectContext = {
        
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        childContext.parent = CoreDataContainer.shared.mainContext
        return childContext
    }()
    
    func add(place: Place, autoSave: Bool = true) throws {
        guard let latitude = Double(place.y),
              let longitude = Double(place.x) else {
            throw CoreDataError.invalidCoordinate
        }
        childContext.performAndWait {
            let poi = POI(context: childContext)
            poi.id = place.id
            poi.category = place.category
            poi.imageURL = place.imageUrl
            poi.latitude = latitude
            poi.longitude = longitude
            poi.name = place.name
        }
        
//        if autoSave {
            try save()
//        }
    }
    
    func fetch() throws -> [POI] {
        guard let pois = try childContext.fetch(POI.fetchRequest()) as? [POI] else {
            throw CoreDataError.invalidType
        }
        return pois
    }
    
    func perform(_ block: @escaping () -> Void) {
        childContext.perform(block)
    }
    
    func performAndWait(_ block: () -> Void) {
        childContext.performAndWait(block)
    }
    
    func save() throws {
        var saveError: Error?
        
        childContext.performAndWait {
            do {
//                if childContext.hasChanges {
                    try childContext.save()
//                }
            } catch {
                saveError = error
            }
        }
        
        if let error = saveError {
            throw CoreDataError.saveError(error.localizedDescription)
        }
    }
}
