//
//  JsonParser.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation

class JsonParser {
    private let coreDataLayer = CoreDataLayer()
    
    func jsonToData(name: String, completion handler: @escaping () -> Void) {
        guard let path = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: path),
              let jsonResult = try? JSONDecoder().decode(Places.self, from: data)
        else { return }
        
        try? coreDataLayer.add(places: jsonResult.places) {
            try? self.coreDataLayer.save()
            handler()
        }
    }
}
