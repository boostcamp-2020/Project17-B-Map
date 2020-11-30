//
//  MarkerAnimator.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//
import UIKit
import NMapsMap

final class MarkerAnimateController {
    private let markerRadius: CGFloat
    private let mapView: NMFMapViewProtocol
    private var animator: UIViewPropertyAnimator?
    var view: UIView?
    
    init(frame: CGRect, markerRadius: CGFloat, mapView: NMFMapViewProtocol) {
        self.markerRadius = markerRadius
        self.mapView = mapView
        configureAnimationView(frame: frame)
    }
    
    private func configureAnimationView(frame: CGRect) {
        view = UIView(frame: frame)
        view?.backgroundColor = .clear
        view?.isUserInteractionEnabled = false
    }
    
    func clusteringAnimation(old: [NMGLatLng], new: [NMGLatLng], isMerge: Bool, completion: (() -> Void)?) {
        let upper = isMerge ? new : old
        let lower = isMerge ? old : new
        
        let animations = lower.compactMap { lowerMarker in
            guard let upperMarker = upper
                    .map({ upperMarker in
                        (cluster: upperMarker, distance: lowerMarker.distance(to: upperMarker))
                    })
                    .min(by: { (lhs, rhs) -> Bool in
                        lhs.distance < rhs.distance
                    })?
                    .cluster
            else { return nil }
            
            return isMerge ? (lowerMarker, upperMarker) : (upperMarker, lowerMarker)
        }.compactMap { (from: NMGLatLng, to: NMGLatLng) in
            moveWithAnimation(from: from, to: to)
        }
        
        stop()
        start(animations: animations, completion: completion)
    }
    
    private func start(animations: [(animation: () -> Void, completion: () -> Void)], completion: (() -> Void)?) {
        animator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                animations.forEach {
                    $0.animation()
                }
            }, completion: { finalPosition in
                animations.forEach { $0.completion() }
                guard finalPosition == .end else { return }
                completion?()
            })
    }
    
    private func stop() {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
    }
    
    private func moveWithAnimation(from source: NMGLatLng, to destination: NMGLatLng) -> (() -> Void, () -> Void)? {
        let srcPoint = mapView.projection.point(from: source)
        let dstPoint = mapView.projection.point(from: destination)
        
        guard srcPoint.isValid, dstPoint.isValid else { return nil }
        
        let srcPointView = MarkerImageView(
            frame: CGRect(
                x: srcPoint.x - markerRadius,
                y: srcPoint.y - markerRadius * 2,
                width: markerRadius * 2,
                height: markerRadius * 2))
        srcPointView.transform = .identity
        view?.addSubview(srcPointView)
        
        let dstPointView = MarkerImageView(
            frame: CGRect(
                x: dstPoint.x - markerRadius,
                y: dstPoint.y - markerRadius * 2,
                width: markerRadius * 2,
                height: markerRadius * 2
            )
        )
        dstPointView.alpha = 0
        dstPointView.transform = CGAffineTransform(scaleX: 0, y: 0)
        view?.addSubview(dstPointView)
        
        return (animation: {
            srcPointView.center = dstPointView.center
            srcPointView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            srcPointView.alpha = 0
            
            dstPointView.transform = .identity
            dstPointView.alpha = 1
        }, completion: {
            srcPointView.removeFromSuperview()
            dstPointView.removeFromSuperview()
        })
    }
}
