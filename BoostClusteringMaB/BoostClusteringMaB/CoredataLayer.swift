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
    func fetch(southWest: LatLng, northEast: LatLng) throws -> [POI]
    func remove(at: Int) throws
    func removeAll() throws
    func save() throws
}

class CoreDataLayer {
    enum CoreDataError: Error {
        case invalidCoordinate
        case saveError(String)
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
        let request: NSFetchRequest = POI.fetchRequest()
        return try childContext.fetch(request)
    }
    
    func fetch(southWest: LatLng, northEast: LatLng) throws -> [POI] {
        guard northEast.lat < southWest.lat,
              northEast.lng > southWest.lng else {
            throw CoreDataError.invalidCoordinate
        }
        
        let latitudePredicate = NSPredicate(format: "latitude BETWEEN {%@, %@}", argumentArray: [northEast.lat, southWest.lat])
        let longitudePredicate = NSPredicate(format: "longitude BETWEEN {%@, %@}", argumentArray: [southWest.lng, northEast.lng])
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [latitudePredicate, longitudePredicate])
        
        let request: NSFetchRequest = POI.fetchRequest()
        request.predicate = predicate
        return try childContext.fetch(request)
    }
    
    func save() throws {
        try childContext.save()
    }
}
