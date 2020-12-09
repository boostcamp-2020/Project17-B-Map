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
        dot.alpha = 0
        view?.addSubview(dot)

        return dot
    }()

    private let dotSize: CGFloat = 30
    private let mapView: NMFMapViewProtocol
    private let animationDurtaion = 1.5

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

// MARK: - Dot Animation
extension MainAnimationController {
    func pointDotAnimation(point: CGPoint) {
        self.dotView.center = .init(x: point.x, y: point.y)
        self.startAnimation()
    }

    func startAnimation() {
        let animationGroup = self.setupAnimationGroup()
        self.dotView.layer.add(animationGroup, forKey: "dotAnimation")
    }

    func removePointAnimation() {
        self.dotView.layer.removeAnimation(forKey: "dotAnimation")
        dotView.alpha = 0
    }

    // MARK: - Dot Animation Group
    private func setupAnimationGroup() -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDurtaion
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [makeScaleAnimation(), makeOpacityAnimation()]

        return animationGroup
    }

    private func makeScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = animationDurtaion

        return scaleAnimation
    }

    private func makeOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.45, 0.8, 0]
        opacityAnimation.keyTimes = [0, 0.2, 1.3]
        opacityAnimation.duration = animationDurtaion

        return opacityAnimation
    }
}
