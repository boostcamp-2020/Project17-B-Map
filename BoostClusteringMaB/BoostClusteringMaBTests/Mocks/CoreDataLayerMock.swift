//
//  CoreDataLayerMock.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/28.
//

@testable import BoostClusteringMaB

class CoreDataLayerMock: CoreDataManager {
    func remove(poi: POI) throws {

    }

    func add(place: Place, completion handler: (() -> Void)?) throws {

    }

    func add(places: [Place], completion handler: (() -> Void)?) throws {

    }

    func fetch(sorted: Bool) throws -> [POI] {
        []
    }

    func fetch(by classification: String, sorted: Bool) throws -> [POI] {
        []
    }

    func fetch(southWest: LatLng, northEast: LatLng, sorted: Bool) throws -> [POI] {
        return []
    }

    func removeAll() throws {

    }

    func save() throws {

    }
}
