//
//  MapSettings.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/14.
//

import UIKit

protocol MapSettingsDelegate: class {
    func onChangedBrightness(_ value: Float)
    func onChangedBuildingHeight(_ value: Float)
    func onChangedSignSize(_ value: Float)
}

final class MapSettings {
    let sections = ["밝기", "건물 높이", "기호 크기"]
    var count: Int {
        sections.count
    }
    
    weak var delegate: MapSettingsDelegate?
    
    @Value(key: "Brightness") var valueLightness: Float
    @Value(key: "BuildingHeight") var valueBuildingHeight: Float
    @Value(key: "SignSize") var valueSymbolScale: Float
    
    func isCheck(key: String) -> Float {
        switch key {
        case "밝기":
            return valueLightness
        case "건물 높이":
            return valueBuildingHeight
        case "기호 크기":
            return valueSymbolScale
        default:
            return 1.0
        }
    }
    
    func setUISlider(_ key: String) -> UISlider {
        let slider = UISlider()
        
        if key == "밝기" {
            slider.minimumValue = -1
            slider.maximumValue = 1
            slider.value = valueLightness
            if #available(iOS 14.0, *) {
                slider.focusGroupIdentifier = "밝기"
            } else {
                slider.tag = 0
            }
        } else if key == "건물 높이" {
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.value = valueBuildingHeight
            if #available(iOS 14.0, *) {
                slider.focusGroupIdentifier = "건물 높이"
            } else {
                slider.tag = 1
            }
        }
        
        slider.addTarget(self, action: #selector(onChangeValueSlider), for: .valueChanged)
        
        return slider
    }
    
    @objc func onChangeValueSlider(sender: UISlider) {
        if #available(iOS 14.0, *) {
            if sender.focusGroupIdentifier == "밝기" {
                valueLightness = sender.value
                delegate?.onChangedBrightness(valueLightness)
            } else if sender.focusGroupIdentifier == "건물 높이" {
                valueBuildingHeight = sender.value
                delegate?.onChangedBuildingHeight(valueBuildingHeight)
            }
        } else {
            if sender.tag == 0 {
                valueLightness = sender.value
                delegate?.onChangedBrightness(valueLightness)
            } else if sender.tag == 1 {
                valueBuildingHeight = sender.value
                delegate?.onChangedBuildingHeight(valueBuildingHeight)
            }
        }
    }
    
    func setUISegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: ["0.5", "1", "2"])
        segmentedControl.selectedSegmentIndex = Int(valueSymbolScale)
        segmentedControl.addTarget(self, action: #selector(onChangeValueSegmentedControl), for: .valueChanged)
        
        return segmentedControl
    }
    
    @objc func onChangeValueSegmentedControl(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            valueSymbolScale = 0.5
        case 1:
            valueSymbolScale = 1.0
        case 2:
            valueSymbolScale = 2.0
        default:
            valueSymbolScale = 1.0
        }
        
        delegate?.onChangedSignSize(valueSymbolScale)
    }
    
    func view(key: String) -> UIView {
        switch key {
        case "밝기":
            return setUISlider(key)
        case "건물 높이":
            return setUISlider(key)
        case "기호 크기":
            return setUISegmentedControl()
        default:
            return .init()
        }
    }
    
    subscript(index: Int) -> String {
        return sections[index]
    }
}
