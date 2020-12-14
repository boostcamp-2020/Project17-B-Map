//
//  Value.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/14.
//

import Foundation

@propertyWrapper
struct Value {
    private let key: String
    
    var wrappedValue: Float {
        get { UserDefaults.standard.float(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    init(key: String) {
        self.key = key
    }
}
