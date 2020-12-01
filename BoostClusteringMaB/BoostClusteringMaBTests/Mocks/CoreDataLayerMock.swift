//
//  CoreDataLayerMock.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/28.
//

@testable import BoostClusteringMaB

class CoreDataLayerMock: CoreDataManager {
    func add(place: Place, completion handler: CoreDataHandler?) {
        
    }
    
    func add(places: [Place], completion handler: CoreDataHandler?) {
        
    }
    
    func remove(poi: POI, completion handler: CoreDataHandler?) {
        
    }
    
    func removeAll(completion handler: CoreDataHandler?) {
        
    }
    
    func fetch(sorted: Bool) -> [POI]? {
        return nil
    }
    
    func fetch(by classification: String, sorted: Bool) -> [POI]? {
        return nil
    }
    
    func fetch(southWest: LatLng, northEast: LatLng, sorted: Bool) -> [POI]? {
        return nil
    }
    
}
