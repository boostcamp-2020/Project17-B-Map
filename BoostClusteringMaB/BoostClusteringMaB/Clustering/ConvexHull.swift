//
//  ConvexHull.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//

import Foundation

final class ConvexHull {
    private var points = [LatLng]() // x,y
    private var relativePoints = [LatLng]() // p,q
    private var infos: [Info] = []
    
    struct Info {
        let x: Double
        let y: Double
        let p: Double
        let q: Double
    }
    
    init(poiPoints: [LatLng]) {
        points = deduplication(points: poiPoints)
        configureInfos()
        infos = sortedPointsWithoutFirst()
    }
    
    private func configureInfos() {
        guard let stdPoint = points.first else { return }

        relativePoints = points
            .dropFirst()
            .map { $0 - stdPoint }
        
        relativePoints.insert(stdPoint, at: 0)
        
        zip(points, relativePoints).forEach { point, reletivePoint in
            self.infos.append(Info(x: point.lng, y: point.lat, p: reletivePoint.lng, q: reletivePoint.lat))
        }
    }
    
    private func deduplication(points: [LatLng]) -> [LatLng] {
        let setPoiPoints = Set(points)
        return Array(setPoiPoints).sorted(by: {
            ($0.lat, $0.lng) < ($1.lat, $1.lng)
        })
    }
    
    private func sortedPointsWithoutFirst() -> [Info] {
        var sortedPoints = infos.dropFirst().sorted(by: { left, right in
            if left.q * right.p != left.p * right.q {
                return left.q * right.p < left.p * right.q
            }
            
            if left.y != right.y {
                return left.y < right.y
            }
            
            return left.x < right.x
        })
        
        if let first = infos.first {
            sortedPoints.insert(first, at: 0)
        }
        
        return sortedPoints
    }
    
    func run() -> [LatLng] {
        var stack = [Int]()
        stack.append(0)
        stack.append(1)
        
        guard infos.count > 2 else { return [] }
        
        var next = 2
        
        while next < infos.count {
            while stack.count >= 2 {
                guard let second = stack.popLast() else { return [] }
                guard let first = stack.last else { return [] }
                
                if ccw(point1: infos[first], point2: infos[second], point3: infos[next]) > 0 {
                    stack.append(second)
                    break
                }
            }
            stack.append(next)
            next += 1
        }
        
        var result = stack.map { infos[$0] }
        
        result.append(result[0])
        
        return result.map({LatLng(lat: $0.y, lng: $0.x)})
    }
    
    private func ccw(point1: Info, point2: Info, point3: Info) -> Int {
        var temp = point1.x * point2.y + point2.x * point3.y + point3.x * point1.y
        temp = temp - point2.x * point1.y - point3.x * point2.y - point1.x * point3.y
        
        if temp > 0 {
            return 1
        } else if temp < 0 {
            return -1
        }
        return 0
    }
}
