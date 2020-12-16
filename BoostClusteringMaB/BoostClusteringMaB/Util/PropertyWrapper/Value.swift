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
    private let defaultValue: Float

    var wrappedValue: Float {
        get {
            let userDefaultsFloat = UserDefaults.standard.float(forKey: key)
            return userDefaultsFloat == 0.0 ? defaultValue : userDefaultsFloat
        }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    init(key: String, defaultValue: Float = 0.0) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
