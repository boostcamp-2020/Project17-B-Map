//
//  DataParser.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/28.
//

import Foundation

protocol DataParser {
    associatedtype DataType: Codable
    
    func parse(fileName: String, completion handler: @escaping (Result<[DataType], Error>) -> Void)
}
