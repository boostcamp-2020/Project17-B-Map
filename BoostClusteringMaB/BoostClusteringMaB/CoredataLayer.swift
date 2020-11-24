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
    func fetch(by classification: String) throws -> [POI]
    func remove(at: Int) throws
    func removeAll() throws
    func save() throws
}

class CoreDataLayer: CoreDataManager {
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

    func fetch(by classification: String) throws -> [POI] {
        let request: NSFetchRequest = POI.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", classification)

        let pois = try childContext.fetch(request)

        return pois
    }
    
    func save() throws {
        try childContext.save()
        CoreDataContainer.shared.saveContext()
    }

    func remove(at: Int) throws {

    }

    func removeAll() throws {
        
    }
}
