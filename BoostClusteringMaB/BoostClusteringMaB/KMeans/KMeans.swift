//
//  KMeans.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

//구현 과정
/*
 입력값
 k: 클러스터 수
 Objects : n 개의 데이터 오브젝트를 포함하는 집합
 출력값: k 개의 클러스터
 
 알고리즘
 
 1. 데이터 오브젝트 집합 D에서 k 개의 데이터 오브젝트를 임의로 추출하고, 이 데이터 오브젝트들을 각 클러스터의 중심 (centroid) 으로 설정한다. (초기값 설정) O
 집합 D의 각 데이터 오브젝트들에 대해 k 개의 클러스터 중심 오브젝트와의 거리를 각각 구하고, 각 데이터 오브젝트가 어느 중심점 (centroid) 와 가장 유사도가 높은지 알아낸다. 그리고 그렇게 찾아낸 중심점으로 각 데이터 오브젝트들을 할당한다.
 클러스터의 중심점을 다시 계산한다. 즉, 2에서 재할당된 클러스터들을 기준으로 중심점을 다시 계산한다.
 각 데이터 오브젝트의 소속 클러스터가 바뀌지 않을 때까지 혹은 최대 반복횟수까지 2, 3 과정을 반복한다.
 */

import Foundation

class KMeans {
	let k: Int
	let points: [LatLng] // 8000개 예상
	var clusters: [Cluster]
	var isChanged: Bool // [point]가 변했는지 체크하기위한 변수
	var centroids: [LatLng] {
		return clusters.map { $0.center }
	}
	
	init(k: Int, points: [LatLng]) {
		self.k = k
		self.points = points
		self.clusters = []
		self.isChanged = false
	}
	
	//시간은 maxK를 조정하는방식으로 줌레벨에 따라 + 애니메이션
	func run() {
		let maxIteration = 5 // 없으면 2~30번 돈다.
		//let initCenters = randomCenters(count: k, points: points)
		let initCenters = randomCentersByPointsIndex(count: k, points: points)
		clusters = generateClusters(centers: initCenters)
		classifyPoints() // O(n)
		updateCenters() // O(n)
		
		var iteration = 0
		//O(i)
		repeat {
			updatePoints() // O(nk)
			updateCenters() // O(n)
			iteration += 1
		} while isChanged && (iteration < maxIteration)
	}
	
	//1 임의로 중심점을 추출 + 그걸로 클러스터 생성
	private func randomCenters(count: Int, points: [LatLng]) -> [LatLng] {
		var centers = Set<LatLng>()
		while centers.count < count {
			guard let random = points.randomElement() else { continue }
			centers.insert(random)
		}
		return Array(centers)
	}
	
	//1 임의로 중심점을 추출 ( 좌표 정렬해서 적절한 간격으로 뽑음 )
	private func randomCentersByPointsIndex(count: Int, points: [LatLng]) -> [LatLng] {
		guard let firstPoint = points.first else { return [] }
		var result = [firstPoint]
		switch count {
		case 1:
			return result
		default:
			let diff = points.count / (count - 1)
			(1..<count).forEach {
				result.append(points[$0 * diff - 1])
			}
			return result
		}
	}
	
	private func generateClusters(centers: [LatLng]) -> [Cluster] {
		return centers.map { Cluster(center: $0) }
	}
	
	//2 모든 점들에 대해서 k개의 center중 가장 가까운 center의 클러스터에 넣어준다 -> 이를 할당
	private func classifyPoints() {
		points.forEach {
			let cluster = findNearestCluster(point: $0)
			cluster.add(point: $0)
		}
	}
	
	//3 클러스터의 중심점을 다시 계산한다
	private func updateCenters() {
		clusters.forEach {
			$0.updateCenter()
		}
	}
	
	//O(nk)
	private func updatePoints() {
		isChanged = false
		
		clusters.forEach { cluster in
			let points = cluster.points
			points.setNowToHead()
			for _ in 0..<points.size {
				guard let point = points.now?.value else { points.moveNowToNext(); break }
				let nearestCluster = findNearestCluster(point: point)
				if cluster == nearestCluster { points.moveNowToNext(); continue }
				
				isChanged = true
				nearestCluster.add(point: point)
				cluster.remove(point: point)
				points.moveNowToNext()
			}
		}
	}
	
	private func findNearestCluster(point: LatLng) -> Cluster {
		var minDistance = Double.greatestFiniteMagnitude
		var nearestCluster = Cluster(center: LatLng.greatestFinite)

		clusters.forEach {
			let newDistance = $0.center.squaredDistance(to: point)
			if newDistance < minDistance {
				nearestCluster = $0
				minDistance = newDistance
			}
		}
		return nearestCluster
	}
	
	//MARK: - Clustering 내부 평가
	
	//오차 제곱합
	func sumOfSquaredOfError() -> Double {
		var sum: Double = 0
		clusters.forEach {
			sum += $0.sumOfSquaredOfError()
		}
		return sum
	}
	
	//Davies-Bouldin index (낮을수록 좋음)
	func daviesBouldinIndex() -> Double {
		var sum: Double = 0
		
		for i in 0..<clusters.count {
			var maxValue: Double = 0
			for j in 0..<clusters.count {
				if i == j { continue }
				let deviations = clusters[i].deviation() + clusters[j].deviation()
				let distanceCenters = clusters[i].center.distance(to: clusters[j].center)
				maxValue = max(maxValue, deviations / distanceCenters)
			}
			sum += maxValue
		}
		
		let result = sum / Double(clusters.count)
		return result
	}
}