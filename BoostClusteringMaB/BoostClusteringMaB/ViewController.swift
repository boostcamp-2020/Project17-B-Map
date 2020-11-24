//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    let markerImageView = MarkerImageView(radius: 30)
    
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

        let marker = NMFMarker(position: .init(lat: 37.3591784, lng: 127.1026379))
        marker.setImageView(markerImageView, count: 1)
        marker.mapView = mapView

        let marker2 = NMFMarker(position: .init(lat: 37.3561884, lng: 127.1026479))
        marker2.setImageView(markerImageView, count: 2)
        marker2.mapView = mapView

        let marker3 = NMFMarker(position: .init(lat: 37.3501984, lng: 127.1026579))
        marker3.setImageView(markerImageView, count: 3)
        marker3.mapView = mapView

        let lat = NMGLatLng(lat: 130, lng: 30)

        print(lat.isWithinCoverage())
        print(lat.lat)
        print(lat.lng)
    }
}

extension NMFMarker {
    func setImageView(_ view: MarkerImageView, count: Int) {
        self.iconImage = .init(image: view.snapshot())
    }
}
