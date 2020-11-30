//
//  String+Bundle.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/28.
//

import Foundation

extension String {
    enum BundleError: Error {
        case invalidFileName
    }
    
    init(forResource: String, ofType: String) throws {
        guard let filepath = Bundle.main.path(forResource: forResource, ofType: ofType) else {
            throw BundleError.invalidFileName
        }
        self = try String(contentsOfFile: filepath)
    }
}
