//
//  CSVParser.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/24.
//

import Foundation

class CSVParser {
    enum CSVParSerError: Error {
        case empty
    }

    var pois = [Place]()

    func convertCSVIntoArray(file name: String) {
        guard let filepath = Bundle.main.path(forResource: name, ofType: "csv"),
              let data = try? String(contentsOfFile: filepath) else {
            return
        }

        var rows = data.components(separatedBy: "\n")

        rows.removeFirst()

        for row in rows {
            let columns = row.components(separatedBy: ",")

            if columns.count == 6 {
                let id = columns[0]
                let name = columns[1]
                let category = columns[2]
                let x = columns[3]
                let y = columns[4]
                let imageURL = columns[5]

                let place = Place(id: id, name: name, x: x, y: y, imageURL: imageURL, category: category)
                pois.append(place)
            }
        }
    }

    func add(to coreDataManager: CoreDataManager) throws {
        guard !pois.isEmpty else {
            throw CSVParSerError.empty
        }
        try pois.forEach({ place in
            try coreDataManager.add(place: place, completion: nil)
        })

        try coreDataManager.save()
    }
}
