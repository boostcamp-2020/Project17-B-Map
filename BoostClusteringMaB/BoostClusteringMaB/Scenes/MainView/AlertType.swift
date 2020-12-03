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
            return "POI를 추가하시겠습니까?"
        case .delete:
            return "POI를 제거하시겠습니까?"
        }
    }
    
    var message: String {
        switch self {
        case .append:
            return "OK를 누르면 추가합니다."
        case .delete:
            return "OK를 누르면 제거합니다."
        }
    }
}
