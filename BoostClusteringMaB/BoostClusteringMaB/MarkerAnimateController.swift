//
//  MarkerAnimator.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//
import UIKit
import NMapsMap

final class MarkerAnimateController {
    typealias AnimationModel = (latLng: NMGLatLng, size: CGFloat)
    private let mapView: NMFMapViewProtocol
    private var animator: UIViewPropertyAnimator?
    var view: UIView?
    
    init(frame: CGRect, mapView: NMFMapViewProtocol) {
        self.mapView = mapView
        configureAnimationView(frame: frame)
    }
    
    private func configureAnimationView(frame: CGRect) {
        view = UIView(frame: frame)
        view?.backgroundColor = .clear
        view?.isUserInteractionEnabled = false
    }
    
    func clusteringAnimation(old: [AnimationModel], new: [AnimationModel], isMerge: Bool, completion: (() -> Void)?) {
        let upper = isMerge ? new : old
        let lower = isMerge ? old : new
        
        let animations = lower.compactMap { lowerModel in
            guard let upperModel = upper
                    .map({ upperMarker in
                        (cluster: upperMarker, distance: lowerModel.latLng.distance(to: upperMarker.latLng))
                    })
                    .min(by: { (lhs, rhs) -> Bool in
                        lhs.distance < rhs.distance
                    })?
                    .cluster
            else { return nil }
            
            return isMerge ? (lowerModel, upperModel) : (upperModel, lowerModel)
        }.compactMap { (from: AnimationModel, to: AnimationModel) in
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
    
    private func moveWithAnimation(from srcModel: AnimationModel,
                                   to dstModel: AnimationModel) -> (() -> Void, () -> Void)? {
        let srcPoint = mapView.projection.point(from: srcModel.latLng)
        let dstPoint = mapView.projection.point(from: dstModel.latLng)
        
        guard srcPoint.isValid, dstPoint.isValid else { return nil }
        
        guard srcPoint != dstPoint else { return nil }
        
        let srcPointView = MarkerImageView(
            frame: CGRect(
                x: srcPoint.x - srcModel.size / 2,
                y: srcPoint.y - srcModel.size,
                width: srcModel.size,
                height: srcModel.size))
        srcPointView.transform = .identity
        view?.addSubview(srcPointView)
        
        let dstPointView = MarkerImageView(
            frame: CGRect(
                x: dstPoint.x - dstModel.size / 2,
                y: dstPoint.y - dstModel.size,
                width: dstModel.size,
                height: dstModel.size
            )
        )
        dstPointView.alpha = 0
        dstPointView.transform = CGAffineTransform(scaleX: 0, y: 0)
        view?.addSubview(dstPointView)
        
        let scaleValue = dstModel.size / srcModel.size
        
        return (animation: {
            srcPointView.center = dstPointView.center
            srcPointView.transform = CGAffineTransform(scaleX: scaleValue, y: scaleValue)
            srcPointView.alpha = 0
            
            dstPointView.transform = .identity
            dstPointView.alpha = 1
        }, completion: {
            srcPointView.removeFromSuperview()
            dstPointView.removeFromSuperview()
        })
    }
}
