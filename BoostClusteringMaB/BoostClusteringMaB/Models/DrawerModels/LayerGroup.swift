//
//  LayerGroup.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/14.
//

import Foundation

class LayerGroup {
    let sections = ["교통정보", "자전거", "등산로", "지적편집도"]
    var count: Int {
        sections.count
    }
    
    private var isChecks: [Bool] {
        return [isCheckTraffic, isCheckBicycle, isCheckHikingTrail, isCheckCadastralEditing]
    }
    
    @IsCheck(key: "Traffic") var isCheckTraffic: Bool
    @IsCheck(key: "Bicycle") var isCheckBicycle: Bool
    @IsCheck(key: "HikingTrail") var isCheckHikingTrail: Bool
    @IsCheck(key: "CadastralEditing") var isCheckCadastralEditing: Bool
    
    func isCheck(key: String) -> Bool {
        switch key {
        case "교통정보":
            return isCheckTraffic
        case "자전거":
            return isCheckBicycle
        case "등산로":
            return isCheckHikingTrail
        case "지적편집도":
            return isCheckCadastralEditing
        default:
            return false
        }
    }
    
    func toggle(key: String) {
        switch key {
        case "교통정보":
            isCheckTraffic.toggle()
            return
        case "자전거":
            isCheckBicycle.toggle()
            return
        case "등산로":
            isCheckHikingTrail.toggle()
            return
        case "지적편집도":
            isCheckCadastralEditing.toggle()
            return
        default:
            return
        }
    }
    
    subscript(index: Int) -> String {
        return sections[index]
    }
}
