//
//  ConvexHull.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//

import Foundation

struct Info {
    let x: Double
    let y: Double
    let p: Double
    let q: Double
}

class ConvexHull {
    let stdPoint: LatLng
    let points: [LatLng] // x,y
    var relativePoints: [LatLng] // p,q
    var infos: [Info] = []
    
    init(stdPoint: LatLng, points: [LatLng]) {
        self.stdPoint = stdPoint
        self.points = points
        relativePoints = points
            .dropFirst()
            .map { $0 - stdPoint }
        relativePoints.insert(stdPoint, at: 0)
        zip(points, relativePoints).forEach { point, reletivePoint in
            self.infos.append(Info(x: point.lng, y: point.lat, p: reletivePoint.lng, q: reletivePoint.lat))
        }
        
        infos.sort(by: { left, right in
            if left.q * right.p != left.p * right.q {
                return left.q * right.p < left.p * right.q
            }
            
            if left.y != right.y {
                return left.y < right.y;
            }
            
            return left.x < right.x;
        })
        
    }
    
    func ccw(point1: Info, point2: Info, point3: Info) -> Int {
        var temp = point1.x * point2.y + point2.x * point3.y + point3.x * point1.y
        temp = temp - point2.x * point1.y - point3.x * point2.y - point1.x * point3.y
        
        if temp > 0 {
            return 1
        } else if temp < 0 {
            return -1
        }
        return 0
    }
    
    func run() -> [LatLng] {
        var stack = [Int]()
        stack.append(0)
        stack.append(1)
        
        guard infos.count > 2 else { return [] }
        
        var next: Int = 2
        
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
        result.append(infos[0])
        return result.map{LatLng(lat: $0.y, lng: $0.x)}
    }
}
