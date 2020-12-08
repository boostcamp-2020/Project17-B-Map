//
//  ManagedPOI+CoreDataProperties.swift
//  
//
//  Created by ParkJaeHyun on 2020/12/01.
//
//

import Foundation
import CoreData

extension ManagedPOI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPOI> {
        return NSFetchRequest<ManagedPOI>(entityName: "ManagedPOI")
    }
    
    @NSManaged public var category: String?
    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?

}
