//
//  MapTypes.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/14.
//

import Foundation

class MapTypes {
    let sections = ["일반지도", "위성지도", "하이브리드", "지형도"]
    var count: Int {
        sections.count
    }
    
    @IsCheck(key: "Base") var isCheckBase: Bool
    @IsCheck(key: "Satellite") var isCheckSatellite: Bool
    @IsCheck(key: "Hybrid") var isCheckHybrid: Bool
    @IsCheck(key: "Terrain") var isCheckTerrain: Bool
    
    func isCheck(key: String) -> Bool {
        switch key {
        case "일반지도":
            return isCheckBase
        case "위성지도":
            return isCheckSatellite
        case "하이브리드":
            return isCheckHybrid
        case "지형도":
            return isCheckTerrain
        default:
            return false
        }
    }
    
    func toggle(key: String) {
        switch key {
        case "일반지도":
            isCheckBase.toggle()
            isCheckSatellite = false
            isCheckHybrid = false
            isCheckTerrain = false
            return
        case "위성지도":
            isCheckSatellite.toggle()
            isCheckBase = false
            isCheckHybrid = false
            isCheckTerrain = false
            return
        case "하이브리드":
            isCheckHybrid.toggle()
            isCheckBase = false
            isCheckSatellite = false
            isCheckTerrain = false
            return
        case "지형도":
            isCheckTerrain.toggle()
            isCheckBase = false
            isCheckSatellite = false
            isCheckHybrid = false
            return
        default:
            return
        }
    }
    
    subscript(index: Int) -> String {
        return sections[index]
    }
}
