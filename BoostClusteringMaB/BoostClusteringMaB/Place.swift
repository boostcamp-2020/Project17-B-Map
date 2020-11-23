//
//  Place.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/23.
//

import Foundation

struct Places: Decodable {
    let places: [Place]
}

struct Place: Decodable {
    let category: String
    let id: String
    let imageUrl: String?
    let name: String
    let x: String
    let y: String
}
