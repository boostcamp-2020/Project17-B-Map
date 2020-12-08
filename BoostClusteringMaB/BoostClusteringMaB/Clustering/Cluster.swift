//
//  Cluster.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import Foundation

class Cluster: Equatable {
    static func == (lhs: Cluster, rhs: Cluster) -> Bool {
        return lhs.center == rhs.center
    }
    
    static let greatestFinite: Cluster = Cluster(center: LatLng.greatestFinite)
    
    var center: LatLng
    var pois: LinkedList<POI>

    private var poisLatLng: LatLng {
        self.pois.now?.value.latLng ?? .zero
    }

    init(center: LatLng) {
        self.center = center
        self.pois = LinkedList<POI>()
    }
    
    func add(poi: POI) {
        pois.add(poi)
    }
    
    @discardableResult
    func remove(poi: POI) -> POI? {
        return pois.remove()
    }
    
    func updateCenter() {
        var newCenter = LatLng.zero
        
        pois.setNowToHead()
        for _ in 0..<pois.size {
            let nowPoint = LatLng(lat: poisLatLng.lat, lng: poisLatLng.lng)
            newCenter += nowPoint
            //newCenter = newCenter + (points.now?.value ?? LatLng.zero)
            pois.moveNowToNext()
        }
        newCenter.lat /= Double(pois.size)
        newCenter.lng /= Double(pois.size)
        
        center = newCenter
    }
    
    func combine(other: Cluster) {
        self.pois.merge(other: other.pois)
        updateCenter()
    }
    
    // 오차 제곱 합
    //    func sumOfSquaredOfError() -> Double {
    //        var sum: Double = 0
    //        points.setNowToHead()
    //        for _ in 0..<points.size {
    //            sum += center.squaredDistance(to: (points.now?.value ?? LatLng.zero))
    //            points.moveNowToNext()
    //        }
    //        return sum
    //    }
    
    //중심점과 클러스터내의 점들간의 거리의 평균
    func deviation() -> Double {
        var sum: Double = 0
        pois.setNowToHead()
        for _ in 0..<pois.size {
            let nowPoint = LatLng(lat: poisLatLng.lat, lng: poisLatLng.lng)
            sum += center.distance(to: nowPoint)
            pois.moveNowToNext()
        }
        let result = sum / Double(pois.size)
        return result
    }
    
    func area() -> [LatLng] {
        let poisAllValues = pois.allValues()
        
        let points = poisAllValues.map { LatLng(lat: $0.latLng.lat, lng: $0.latLng.lng) }

        let convexHull = ConvexHull(poiPoints: points)
        let convexHullPoints = convexHull.run()
        return convexHullPoints
    }

    func southWestAndNorthEast() -> (southWest: LatLng, northEast: LatLng) {
        var minX = Double.greatestFiniteMagnitude
        var minY = Double.greatestFiniteMagnitude
        var maxX: Double = 0
        var maxY: Double = 0

        pois.setNowToHead()

        for _ in 0..<pois.size {
            let x = poisLatLng.lng
            let y = poisLatLng.lat
            if x < minX {
                minX = x
            }

            if y < minY {
                minY = y
            }

            if x > maxX {
                maxX = x
            }

            if y > maxY {
                maxY = y
            }

            pois.moveNowToNext()
        }

        return (LatLng(lat: minY, lng: minX), LatLng(lat: maxY, lng: maxX))
    }

    func southWest() -> LatLng {
        var minX = Double.greatestFiniteMagnitude
        var minY = Double.greatestFiniteMagnitude
        pois.setNowToHead()
        for _ in 0..<pois.size {
            let x = poisLatLng.lng
            let y = poisLatLng.lat
            if x < minX {
                minX = x
            }
            if y < minY {
                minY = y
            }
            pois.moveNowToNext()
        }
        return LatLng(lat: minY, lng: minX)
    }
    
    func northEast() -> LatLng {
        var maxX: Double = 0
        var maxY: Double = 0
        pois.setNowToHead()
        for _ in 0..<pois.size {
            let x = poisLatLng.lng
            let y = poisLatLng.lat
            if x > maxX {
                maxX = x
            }
            if y > maxY {
                maxY = y
            }
            pois.moveNowToNext()
        }
        return LatLng(lat: maxY, lng: maxX)
    }
}
