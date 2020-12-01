//
//  CoreDataLayer.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/23.
//

import CoreData

enum CoreDataError: Error {
    case invalidCoordinate
    case invalidFetch
    case saveError
}

typealias CoreDataHandler = (Result<Void, CoreDataError>) -> Void
typealias POIHandler = (Result<[ManagedPOI], CoreDataError>) -> Void

protocol CoreDataManager {
    func add(place: Place, completion handler: CoreDataHandler?)
    func add(places: [Place], completion handler: CoreDataHandler?)
    func fetch(sorted: Bool, completion handler: POIHandler)
    func fetch(by classification: String, sorted: Bool, completion handler: POIHandler)
    func fetch(southWest: LatLng,
               northEast: LatLng,
               sorted: Bool,
               completion handler: POIHandler)
    func remove(poi: ManagedPOI, completion handler: CoreDataHandler?)
    func removeAll(completion handler: CoreDataHandler?)
}

final class CoreDataLayer: CoreDataManager {
    private lazy var childContext: NSManagedObjectContext = {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        childContext.parent = CoreDataContainer.shared.mainContext
        return childContext
    }()

    private func add(place: Place, isSave: Bool, completion handler: CoreDataHandler? = nil) {
        guard let latitude = Double(place.y),
              let longitude = Double(place.x) else {
            handler?(.failure(.invalidCoordinate))
            return
        }
        
        childContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            let poi = ManagedPOI(context: self.childContext)
            poi.id = place.id
            poi.category = place.category
            poi.imageURL = place.imageURL
            poi.latitude = latitude
            poi.longitude = longitude
            poi.name = place.name
            if isSave {
                do {
                    try self.save()
                } catch {
                    handler?(.failure(.saveError))
                    return
                }
            }
            handler?(.success(()))
        }
    }

    func add(place: Place, completion handler: CoreDataHandler? = nil) {
        add(place: place, isSave: true, completion: handler)
    }

    func add(places: [Place], completion handler: CoreDataHandler? = nil) {
        let group = DispatchGroup()
        
        places.forEach { place in
            group.enter()
            add(place: place, isSave: false) { result in
                switch result {
                case .failure(let error):
                    handler?(.failure(error))
                    return
                case .success(_):
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            do {
                try self.save()
                handler?(.success(()))
            } catch {
                handler?(.failure(.saveError))
            }
        }
    }

    func fetch(sorted: Bool = true,
               completion handler: POIHandler) {
        let request: NSFetchRequest = ManagedPOI.fetchRequest()
        request.sortDescriptors = makeSortDescription(sorted: sorted)
        do {
            let pois = try childContext.fetch(request)
            handler(.success(pois))
        } catch {
            handler(.failure(.invalidFetch))
        }
    }
    
    func fetch(by classification: String,
               sorted: Bool = true,
               completion handler: POIHandler) {
        let request: NSFetchRequest = ManagedPOI.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", classification)
        request.sortDescriptors = makeSortDescription(sorted: sorted)
        do {
            let pois = try childContext.fetch(request)
            handler(.success(pois))
        } catch {
            handler(.failure(.invalidFetch))
        }
    }
    
    func fetch(southWest: LatLng,
               northEast: LatLng,
               sorted: Bool = true,
               completion handler: POIHandler) {
        guard northEast.lat > southWest.lat,
              northEast.lng > southWest.lng else {
            handler(.failure(.invalidCoordinate))
            return
        }
        
        let latitudePredicate = NSPredicate(format: "latitude BETWEEN {%@, %@}",
                                            argumentArray: [southWest.lat, northEast.lat])
        let longitudePredicate = NSPredicate(format: "longitude BETWEEN {%@, %@}",
                                             argumentArray: [southWest.lng, northEast.lng])
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [latitudePredicate, longitudePredicate])
        
        let request: NSFetchRequest = ManagedPOI.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = makeSortDescription(sorted: sorted)

        do {
            let pois = try childContext.fetch(request)
            handler(.success(pois))
        } catch {
            handler(.failure(.invalidFetch))
        }
    }
    
    private func makeSortDescription(sorted: Bool) -> [NSSortDescriptor]? {
        let latitudeSort = NSSortDescriptor(key: "latitude", ascending: true)
        let longitudeSort = NSSortDescriptor(key: "longitude", ascending: true)
        
        return sorted ? [latitudeSort, longitudeSort] : nil
    }
    
    func remove(poi: ManagedPOI, completion handler: CoreDataHandler?) {
        do {
            childContext.delete(poi)
            try self.save()
            handler?(.success(()))
        } catch {
            handler?(.failure(.saveError))
        }
    }
    
    func removeAll(completion handler: CoreDataHandler?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "POI")
        let removeAll = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try childContext.execute(removeAll)
            try self.save()
            handler?(.success(()))
        } catch {
            handler?(.failure(.saveError))
        }
    }
    
    private func save() throws {
        if childContext.hasChanges {
            try childContext.save()
            CoreDataContainer.shared.saveContext()
        }
    }
}
