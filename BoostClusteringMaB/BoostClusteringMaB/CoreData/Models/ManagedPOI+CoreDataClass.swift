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
        let poi = POI(address: address, category: category, id: id, imageURL: imageURL, latLng: latlng, name: name)
        return poi
    }
    
    func fromPOI(_ poi: Place, _ addressPlace: String) {
        address = addressPlace
        category = poi.category
        id = poi.id
        imageURL = poi.imageURL
        latitude = Double(poi.y) ?? 0
        longitude = Double(poi.x) ?? 0
        name = poi.name
    }
}
