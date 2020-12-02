//
//  ManagedPOI+CoreDataClass.swift
//  
//
//  Created by ParkJaeHyun on 2020/12/01.
//
//

import Foundation
import CoreData

@objc(ManagedPOI)
public class ManagedPOI: NSManagedObject {
    func toPOI() -> POI {
        let latlng = LatLng(lat: latitude, lng: longitude)
        let poi = POI(category: category, id: id, imageURL: imageURL, latLng: latlng, name: name)
        return poi
    }

    func fromPOI(_ poi: POI) {
        category = poi.category
        id = poi.id
        imageURL = poi.imageURL
        latitude = poi.latLng.lat
        longitude = poi.latLng.lng
        name = poi.name
    }
}
