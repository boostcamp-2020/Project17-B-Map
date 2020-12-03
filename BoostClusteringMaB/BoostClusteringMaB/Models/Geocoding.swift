//
//  Geocoding.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/12/02.
//

import Foundation

// MARK: - Geocoding
struct Geocoding: Codable {
    let status: Status?
    let results: [GeocodingResult]?
}

// MARK: - Result
struct GeocodingResult: Codable {
    let name: String?
    let code: Code?
    let region: Region?
    let land: Land?
}

// MARK: - Code
struct Code: Codable {
    let id, type, mappingID: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type
        case mappingID = "mappingId"
    }
}

// MARK: - Land
struct Land: Codable {
    let type, number1, number2: String?
    let addition0, addition1, addition2, addition3, addition4: Addition?
    let coords: Coords?
    let name: String?
}

// MARK: - Addition
struct Addition: Codable {
    let type, value: String?
}

// MARK: - Coords
struct Coords: Codable {
    let center: Center?
}

// MARK: - Center
struct Center: Codable {
    let crs: String?
    let x, y: Double?
}

// MARK: - Region
struct Region: Codable {
    let area0, area1, area2, area3, area4: Area?
}

// MARK: - Area
struct Area: Codable {
    let name: String?
    let coords: Coords?
}

// MARK: - Area1
struct Area1: Codable {
    let name: String?
    let coords: Coords?
    let alias: String?
}

// MARK: - Status
struct Status: Codable {
    let code: Int?
    let name, message: String?
}
