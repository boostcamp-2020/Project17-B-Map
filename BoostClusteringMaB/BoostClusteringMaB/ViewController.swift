//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    let markerView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 30, height: 30))
        view.backgroundColor = .systemPink
        return view
    }()

    let label: UILabel = {
        let label = UILabel(frame: .init(x: 0, y: 0, width: 10, height: 10))
        label.text = String(Int.random(in: 5000...50000))
        label.backgroundColor = .yellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)

        markerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: markerView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: markerView.centerXAnchor),
            label.trailingAnchor.constraint(equalTo: markerView.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: markerView.leadingAnchor)
        ])

        markerView.layoutIfNeeded()

        let marker = NMFMarker(position: .init(lat: 37.3591784, lng: 127.1026379))
        marker.setMarker(markerView)
        marker.mapView = mapView

        let marker2 = NMFMarker(position: .init(lat: 37.3561884, lng: 127.1026479))
        marker2.setMarker(markerView)
        marker2.mapView = mapView

        let marker3 = NMFMarker(position: .init(lat: 37.3501984, lng: 127.1026579))
        marker3.setMarker(markerView)
        marker3.mapView = mapView

        let lat = NMGLatLng(lat: 130, lng: 30)

        print(lat.isWithinCoverage())
        print(lat.lat)
        print(lat.lng)
    }
}

extension NMFMarker {
    func setMarker(_ view: UIView) {
        self.iconImage = NMFOverlayImage(image: view.snapshot())
    }
}

extension UIView {
    /// View를 UIImage로 생성
    ///
    /// 지정한 view를 이미지로 만들어줌
    /// ```
    /// let uiImage: UIImage = view.snapshot()
    /// ```
    /// - Returns: UIImage()
    func snapshot(_ view: UIView...) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return UIImage() }
        self.layer.render(in: currentContext)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return img
    }
}
