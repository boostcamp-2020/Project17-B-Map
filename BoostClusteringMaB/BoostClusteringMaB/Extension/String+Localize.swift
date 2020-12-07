//
//  String+Localize.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/12/05.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
