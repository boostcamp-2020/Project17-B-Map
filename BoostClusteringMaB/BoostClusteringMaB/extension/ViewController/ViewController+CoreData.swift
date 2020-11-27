//
//  ViewController+CoreData.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation

extension ViewController {
    private func jsonToData(name: String) {
        guard let path = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: path),
              let jsonResult = try? JSONDecoder().decode(Places.self, from: data)
        else { return }
        
        jsonResult.places.forEach {
            try? coreDataLayer.add(place: $0) {
                try? self.coreDataLayer.save()
            }
        }
    }
}
