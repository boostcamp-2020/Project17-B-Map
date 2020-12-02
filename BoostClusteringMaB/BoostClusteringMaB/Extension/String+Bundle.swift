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

    /// CSV, JSON Load
    /// - Parameters:
    ///   - forResource: 파일명
    ///   - ofType: 파일 타입
    /// - Throws: 유효하지 않은 파일명
    init(forResource: String, ofType: String) throws {
        guard let filepath = Bundle.main.path(forResource: forResource, ofType: ofType) else {
            throw BundleError.invalidFileName
        }
        self = try String(contentsOfFile: filepath)
    }
}
