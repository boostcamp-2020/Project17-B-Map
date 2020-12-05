//
//  AlertType.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/12/02.
//

import Foundation

enum AlertType {
    case append
    case delete
    
    var title: String {
        switch self {
        case .append:
            return "appendPOITitle".localized
        case .delete:
            return "deletePOITitle".localized
        }
    }
    
    var message: String {
        switch self {
        case .append:
            return "appendPOIMessage".localized
        case .delete:
            return "deletePOIMessage".localized
        }
    }
}
