//
//  XCTestCase+timeout.swift
//  BoostClusteringMaBTests
//
//  Created by 현기엽 on 2020/11/23.
//

import XCTest

extension XCTestCase {
    func timeout(_ timeout: TimeInterval, completion: (XCTestExpectation) throws -> Void) rethrows {
        let exp = expectation(description: "Timeout: \(timeout) seconds")
        
        try completion(exp)
        
        waitForExpectations(timeout: timeout) { error in
            guard let error = error else { return }
            XCTFail("Timeout error: \(error)")
        }
    }
}
