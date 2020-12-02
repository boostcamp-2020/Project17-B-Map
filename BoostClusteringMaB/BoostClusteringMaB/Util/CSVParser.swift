//
//  CSVParser.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/24.
//

import Foundation

class CSVParser: DataParser {
    typealias DataType = Place
    private let type = "csv"
    
    enum CSVParserError: Error {
        case invalidFileName
        case invalidCSVForm
    }
    
    func parse(fileName: String, completion handler: @escaping (Result<[Place], Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                let data = try String(forResource: fileName, ofType: self.type)
                self.parse(data: data, completion: handler)
            } catch {
                handler(.failure(error))
            }
        }
    }
    
    private func parse(data: String, completion handler: (Result<[Place], Error>) -> Void) {
        let rows = data.components(separatedBy: "\n")
        do {
            let places = try rows[1...].map { row in
                try parse(row: row)
            }
            
            handler(.success(places))
        } catch {
            handler(.failure(error))
        }
    }
    
    private func parse(row: String) throws -> Place {
        let columns = row.components(separatedBy: ",")
        
        guard columns.count == 6 else {
            throw CSVParserError.invalidCSVForm
        }
        
        let id = columns[0]
        let name = columns[1]
        let category = columns[2]
        let x = columns[3]
        let y = columns[4]
        let imageURL = columns[5]
        
        return Place(id: id, name: name, x: x, y: y, imageURL: imageURL, category: category)
    }
}
