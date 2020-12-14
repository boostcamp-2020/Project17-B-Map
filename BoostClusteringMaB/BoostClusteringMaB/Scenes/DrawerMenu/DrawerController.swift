//
//  DrawerController.swift
//  DotAnimation
//
//  Created by ParkJaeHyun on 2020/12/13.
//

import UIKit
import NMapsMap

final class DrawerController: UIViewController {
    private var isMenuExpanded = false
    private let tableView = UITableView()
    private var visualEffectView: UIVisualEffectView = {
        let visualEffect = UIVisualEffectView()
        visualEffect.alpha = 0.3
        return visualEffect
    }()

    private var mapTypes = MapTypes()
    private var layerGroup = LayerGroup()
    private var mapSettings = MapSettings()

    private let mapView: NMFMapView
    private var prevRow: Int = -1

    enum Sections: String, CaseIterable {
        case mapType = "MapType"
        case layerGroup = "LayerGroup"
        case setting = "Setting"
    }

    // MARK: - Initial
    init(mapView: NMFMapView) {
        self.mapView = mapView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVisualEffectView()
        configureTableView()
        configureGestures()
        mapSettings.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNaverMapView()
    }

    // MARK: - Configure
    private func configureNaverMapView() {
        let mapTypesRow = mapTypes.sections.filter({ mapTypes.isCheck(key: $0) }).first

        if mapTypesRow == "일반지도" {
            mapView.mapType = .basic
        } else if mapTypesRow == "위성지도" {
            mapView.mapType = .satellite
        } else if mapTypesRow == "하이브리드" {
            mapView.mapType = .hybrid
        } else if mapTypesRow == "지형도" {
            mapView.mapType = .terrain
        } else {
            mapTypes.isCheckBase = true
            mapView.mapType = .basic
        }

        let layerGroupRows = layerGroup.sections.filter({ layerGroup.isCheck(key: $0) })

        if layerGroupRows.contains("교통정보") {
            mapView.setLayerGroup(NMF_LAYER_GROUP_TRAFFIC, isEnabled: true)
        }
        if layerGroupRows.contains("자전거") {
            mapView.setLayerGroup(NMF_LAYER_GROUP_BICYCLE, isEnabled: true)
        }
        if layerGroupRows.contains("등산로") {
            mapView.setLayerGroup(NMF_LAYER_GROUP_MOUNTAIN, isEnabled: true)
        }
        if layerGroupRows.contains("지적편집도") {
            mapView.setLayerGroup(NMF_LAYER_GROUP_CADASTRAL, isEnabled: true)
        }

        mapView.lightness = CGFloat(mapSettings.valueLightness)
        mapView.buildingHeight = mapSettings.valueBuildingHeight
        mapView.symbolScale = CGFloat(mapSettings.valueSymbolScale)
    }

    private func configureVisualEffectView() {
        view.addSubview(visualEffectView)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor, constant: view.frame.width / 3),
            tableView.rightAnchor.constraint(equalTo: visualEffectView.rightAnchor)
        ])
    }

    private func configureGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeftGesture.direction = .right
        self.view.addGestureRecognizer(swipeLeftGesture)

        let overlayGesture = UITapGestureRecognizer(target: self, action: #selector(didClickOverlay))
        self.visualEffectView.addGestureRecognizer(overlayGesture)
    }

    @objc private func didSwipeLeft() {
        toggleMenu()
    }

    @objc private func didClickOverlay() {
        toggleMenu()
    }

    func toggleMenu() {
        isMenuExpanded = !isMenuExpanded
        visualEffectView.effect = nil

        let width = isMenuExpanded ? 0.0 : UIScreen.main.bounds.width

        UIView.transition(with: view, duration: 0.3, options: [.curveEaseInOut]) {
            self.view.frame = CGRect(x: width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        } completion: { _ in
            self.visualEffectView.effect = UIBlurEffect(style: .dark)
        }
    }
}

// MARK: - MapSettingsDelegate
extension DrawerController: MapSettingsDelegate {
    func onChangedBrightness(_ value: Float) {
        mapSettings.valueLightness = value
        mapView.lightness = CGFloat(value)
    }

    func onChangedBuildingHeight(_ value: Float) {
        mapSettings.valueBuildingHeight = value
        mapView.buildingHeight = value
    }

    func onChangedSignSize(_ value: Float) {
        mapSettings.valueSymbolScale = value
        mapView.symbolScale = CGFloat(value)
    }
}

extension DrawerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let section = indexPath.section
        let row = indexPath.row

        if section == 0 {
            guard prevRow != row else { return }
            prevRow = row
            let row = mapTypes[row]

            mapTypes.toggle(key: row)

            for (index, section) in mapTypes.sections.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = tableView.cellForRow(at: indexPath) else { return }
                let isCheck = mapTypes.isCheck(key: section)
                cell.accessoryType = isCheck ? .checkmark : .none
            }

            if row == "일반지도" {
                mapView.mapType = .basic
            } else if row == "위성지도" {
                mapView.mapType = .satellite
            } else if row == "하이브리드" {
                mapView.mapType = .hybrid
            } else if row == "지형도" {
                mapView.mapType = .terrain
            } else {
                mapView.mapType = .none
            }
        } else if section == 1 {
            let row = layerGroup[row]
            layerGroup.toggle(key: row)

            let isCheck = layerGroup.isCheck(key: "\(row)")
            cell.accessoryType = isCheck ? .checkmark : .none

            if row == "교통정보" {
                mapView.setLayerGroup(NMF_LAYER_GROUP_TRAFFIC, isEnabled: isCheck)
            } else if row == "자전거" {
                mapView.setLayerGroup(NMF_LAYER_GROUP_BICYCLE, isEnabled: isCheck)
            } else if row == "등산로" {
                mapView.setLayerGroup(NMF_LAYER_GROUP_MOUNTAIN, isEnabled: isCheck)
            } else if row == "지적편집도" {
                mapView.setLayerGroup(NMF_LAYER_GROUP_CADASTRAL, isEnabled: isCheck)
            }
        }
    }
}

extension DrawerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mapTypes.count
        } else if section == 1 {
            return layerGroup.count
        } else if section == 2 {
            return mapSettings.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.isMultipleTouchEnabled = true
        let section = indexPath.section
        let row = indexPath.row

        if section == 0 {
            let mapTypesRow = mapTypes[row]
            let isCheck = mapTypes.isCheck(key: "\(mapTypesRow)")
            cell.textLabel?.text = mapTypesRow
            cell.accessoryType = isCheck ? .checkmark : .none
            if isCheck {
                prevRow = indexPath.row
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
            cell.imageView?.image = UIImage(named: mapTypesRow)
        } else if section == 1 {
            let layerGroupRow = layerGroup[row]
            let isCheck = layerGroup.isCheck(key: "\(layerGroupRow)")
            cell.textLabel?.text = layerGroupRow
            cell.accessoryType = isCheck ? .checkmark : .none
            cell.isSelected = isCheck
        } else if section == 2 {
            let mapSettingsRow = mapSettings[row]
            cell.textLabel?.text = mapSettingsRow
            cell.accessoryView = mapSettings.view(key: mapSettingsRow)
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = Sections.allCases[section].rawValue
        return "\(title)"
    }
}
