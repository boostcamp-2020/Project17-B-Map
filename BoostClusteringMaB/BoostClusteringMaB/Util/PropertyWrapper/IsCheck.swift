//
//  IsCheck.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/14.
//

import Foundation

@propertyWrapper
struct IsCheck {
    private let key: String
    
    var wrappedValue: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    init(key: String) {
        self.key = key
    }
}
