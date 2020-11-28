//
//  CoreDataLayer.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/23.
//

import CoreData

protocol CoreDataManager {
    func add(place: Place, completion handler: (() -> Void)?) throws
    func add(places: [Place], completion handler: (() -> Void)?) throws
    func fetch(sorted: Bool) throws -> [POI]
    func fetch(by classification: String, sorted: Bool) throws -> [POI]
    func fetch(southWest: LatLng, northEast: LatLng, sorted: Bool) throws -> [POI]
    func remove(poi: POI) throws
    func removeAll() throws
    func save() throws
}

final class CoreDataLayer: CoreDataManager {
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
    
    func add(places: [Place], completion handler: (() -> Void)? = nil) throws {
        let group = DispatchGroup()
        
        try places.forEach { place in
            group.enter()
            try add(place: place) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            handler?()
        }
    }
    
    func fetch(sorted: Bool = true) throws -> [POI] {
        let request: NSFetchRequest = POI.fetchRequest()
        request.sortDescriptors = makeSortDescription(sorted: sorted)
        
        return try childContext.fetch(request)
    }
    
    func fetch(by classification: String, sorted: Bool = true) throws -> [POI] {
        let request: NSFetchRequest = POI.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", classification)
        request.sortDescriptors = makeSortDescription(sorted: sorted)
        
        let pois = try childContext.fetch(request)
        
        return pois
    }
    
    func fetch(southWest: LatLng, northEast: LatLng, sorted: Bool = true) throws -> [POI] {
        guard northEast.lat > southWest.lat,
              northEast.lng > southWest.lng else {
            throw CoreDataError.invalidCoordinate
        }
        
        let latitudePredicate = NSPredicate(format: "latitude BETWEEN {%@, %@}",
                                            argumentArray: [southWest.lat, northEast.lat])
        let longitudePredicate = NSPredicate(format: "longitude BETWEEN {%@, %@}",
                                             argumentArray: [southWest.lng, northEast.lng])
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [latitudePredicate, longitudePredicate])
        
        let request: NSFetchRequest = POI.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = makeSortDescription(sorted: sorted)
        
        return try childContext.fetch(request)
    }
    
    private func makeSortDescription(sorted: Bool) -> [NSSortDescriptor]? {
        let latitudeSort = NSSortDescriptor(key: "latitude", ascending: true)
        let longitudeSort = NSSortDescriptor(key: "longitude", ascending: true)
        
        return sorted ? [latitudeSort, longitudeSort] : nil
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
        if childContext.hasChanges {
            try childContext.save()
            CoreDataContainer.shared.saveContext()
        }
    }
}
