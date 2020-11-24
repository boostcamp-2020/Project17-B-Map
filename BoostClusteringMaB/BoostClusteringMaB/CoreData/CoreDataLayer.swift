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
    func remove(poi: POI) throws
    func removeAll() throws
    func save() throws
}

final class CoreDataLayer {
    enum CoreDataError: Error {
        case invalidCoordinate
        case saveError(String)
        case invalidType
    }
    
    private lazy var childContext: NSManagedObjectContext = {
        
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        childContext.parent = CoreDataContainer.shared.mainContext
        return childContext
    }()
    
    func add(place: Place, completion handler: (() -> Void)? = nil) throws {
        guard let latitude = Double(place.y),
              let longitude = Double(place.x) else {
            throw CoreDataError.invalidCoordinate
        }
        childContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            let poi = POI(context: self.childContext)
            poi.id = place.id
            poi.category = place.category
            poi.imageURL = place.imageURL
            poi.latitude = latitude
            poi.longitude = longitude
            poi.name = place.name
            handler?()
        }
    }
    
    func fetch() throws -> [POI] {
        guard let pois = try childContext.fetch(POI.fetchRequest()) as? [POI] else {
            throw CoreDataError.invalidType
        }
        return pois
    }
    
    func remove(poi: POI) {
        childContext.delete(poi)
    }
    
    func removeAll() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "POI")
        let removeAll = NSBatchDeleteRequest(fetchRequest: request)
        try childContext.execute(removeAll)
    }
    
    func save() throws {
        try childContext.save()
        CoreDataContainer.shared.saveContext()
    }
}
