//
//  MainAnimationController.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//
import UIKit
import NMapsMap

final class MainAnimationController {
    typealias AnimationModel = (latLng: NMGLatLng, size: CGFloat)
    
    private lazy var dotView: UIView = {
        let dot = UIView(frame: .init(x: 0, y: 0, width: self.dotSize, height: self.dotSize))
        dot.layer.cornerRadius = self.dotSize / 2
        dot.backgroundColor = .red
        view?.addSubview(dot)
        return dot
    }()
    
    private let dotSize: CGFloat = 4
    private let mapView: NMFMapViewProtocol
    
    private var markerAnimator: UIViewPropertyAnimator?
    private var dotAnimator: UIViewPropertyAnimator?
    
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
    
    func pointDotAnimation(point: CGPoint) {
        dotView.center = .init(x: point.x, y: point.y)
        self.dotView.isHidden = false
        self.dotView.alpha = 1
        dotAnimator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0,
            options: .repeat,
            animations: {
                UIView.setAnimationRepeatCount(.infinity)
                self.dotView.alpha = 0
            }, completion: { _ in
                self.dotView.alpha = 1
            })
    }
    
    func removePointAnimation() {
        dotAnimator?.stopAnimation(false)
        dotAnimator?.finishAnimation(at: .current)
        self.dotView.isHidden = true
    }
    
    private func start(animations: [(animation: () -> Void, completion: () -> Void)], completion: (() -> Void)?) {
        markerAnimator = UIViewPropertyAnimator.runningPropertyAnimator(
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
        markerAnimator?.stopAnimation(false)
        markerAnimator?.finishAnimation(at: .current)
    }
    
    private func moveWithAnimation(from srcModel: AnimationModel,
                                   to dstModel: AnimationModel) -> (() -> Void, () -> Void)? {
        let scale = dstModel.size / srcModel.size
        let srcPoint = mapView.projection.point(from: srcModel.latLng)
        let dstPoint = mapView.projection.point(from: dstModel.latLng)
        
        guard srcPoint != dstPoint, dstPoint.isValid else { return nil }
        
        var srcPointView: MarkerImageView?
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
        
        if srcPoint.isValid {
            let pointView = MarkerImageView(
                frame: CGRect(
                    x: srcPoint.x - srcModel.size / 2,
                    y: srcPoint.y - srcModel.size,
                    width: srcModel.size,
                    height: srcModel.size))
            pointView.transform = .identity
            view?.addSubview(pointView)
            srcPointView = pointView
        }
        
        return (animation: {
            srcPointView?.center = dstPointView.center
            srcPointView?.transform = CGAffineTransform(scaleX: scale, y: scale)
            srcPointView?.alpha = 0
            
            dstPointView.transform = .identity
            dstPointView.alpha = 1
        }, completion: {
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
                srcPointView?.removeFromSuperview()
                dstPointView.removeFromSuperview()
            }
        })
    }
}
