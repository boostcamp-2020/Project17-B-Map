//
//  JsonParser.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation

class JsonParser: DataParser {
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
}
