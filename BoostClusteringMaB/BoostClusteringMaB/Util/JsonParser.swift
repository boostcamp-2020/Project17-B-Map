//
//  JsonParser.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation

class JsonParser: DataParser {
    typealias JsonDict = [String: Any]
    typealias JsonArray = [Any]
    typealias DataType = Place
    private let type = "json"
    
    enum JsonParserError: Error {
        case invalidFileName
    }
    
    func parse(fileName: String, completion handler: @escaping (Result<[Place], Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                guard let path = Bundle.main.url(forResource: fileName, withExtension: self.type) else {
                    handler(.failure(JsonParserError.invalidFileName))
                    return
                }
                
                let data = try Data(contentsOf: path)
                let places = try JSONDecoder().decode(Places.self, from: data)
                
                DispatchQueue.main.async {
                    handler(.success(places.places))
                }
            } catch {
                handler(.failure(error))
            }
        }
    }
    
    func parse(address: Data) -> String {
        let areas = ["area1", "area2", "area3", "area4"]
        let jsonData = try? JSONSerialization.jsonObject(with: address, options: []) as? JsonDict
        let jsonResults = jsonData?["results"] as? JsonArray
        let jsonFirst = jsonResults?.first as? JsonDict
        let jsonRegion = jsonFirst?["region"] as? JsonDict
        
        return areas.reduce("") { result, area in
            guard let areaName = (jsonRegion?[area] as? [String: Any])?["name"] as? String else { return result }
            return result + " " + areaName
        }
    }
}
