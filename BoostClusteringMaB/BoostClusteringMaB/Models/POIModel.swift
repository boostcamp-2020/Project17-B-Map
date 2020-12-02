//
//  POIModel.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import Foundation

// MARK: - Issue
struct Places: Codable {
    let places: [Place]
}

// MARK: - Place
struct Place: Codable {
    let id: String
    let name: String
    let x: String
    let y: String
    let imageURL: String?
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, x, y
        case imageURL = "imageUrl"
        case category
    }
}
