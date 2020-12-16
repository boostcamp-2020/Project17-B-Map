//
//  MainAnimationController.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//
import UIKit
import NMapsMap

final class MainAnimationController {
    typealias AnimationModel = (latLng: NMGLatLng, image: UIImage)
    typealias AnimationClosure = (animation: (() -> Void)?, completion: (() -> Void)?)
    
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
}

extension MainAnimationController {
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
            makeMarkerAnimation(from: from, to: to, isMerge: isMerge)
        }
        
        makerAnimationStop()
        markerAnimationStart(animations: animations, completion: completion)
    }
    
    private func markerAnimationStart(animations: [AnimationClosure],
                                      completion: (() -> Void)?) {
        markerAnimator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                animations.forEach {
                    $0.animation?()
                }
            }, completion: { finalPosition in
                animations.forEach { $0.completion?() }
                guard finalPosition == .end else { return }
                completion?()
            })
    }
    
    func makerAnimationStop() {
        markerAnimator?.stopAnimation(false)
        markerAnimator?.finishAnimation(at: .current)
    }
    
    private func makeMarkerImageView(point: CGPoint, image: UIImage) -> UIImageView {
        let markerImageView = UIImageView(image: image)
        markerImageView.frame = CGRect(
            x: point.x - image.size.width / 2,
            y: point.y - image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        return markerImageView
    }
    
    private func makeSourceMarkerView(point: CGPoint, image: UIImage) -> UIImageView {
        let dstPointView = makeMarkerImageView(point: point, image: image)
        dstPointView.transform = .identity
        view?.addSubview(dstPointView)
        return dstPointView
    }
    
    private func makeDestinationMarkerView(point: CGPoint, image: UIImage) -> UIImageView {
        let dstPointView = makeMarkerImageView(point: point, image: image)
        dstPointView.alpha = 0
        dstPointView.transform = CGAffineTransform(scaleX: 0, y: 0)
        view?.addSubview(dstPointView)
        return dstPointView
    }
    
    private func makeMarkerAnimation(from srcModel: AnimationModel,
                                     to dstModel: AnimationModel, isMerge: Bool) -> AnimationClosure? {
        let srcPoint = mapView.projection.point(from: srcModel.latLng)
        let dstPoint = mapView.projection.point(from: dstModel.latLng)
        
        guard srcPoint != dstPoint else {
            let dstView = makeDestinationMarkerView(point: srcPoint, image: dstModel.image)
            dstView.transform = .identity
            dstView.alpha = 1
            return (
                animation: {
                    dstView.alpha = 0.5
                }, completion: {
                    dstView.removeFromSuperview()
                }
            ) }
        
        let srcView = (srcPoint.isValid) ? makeSourceMarkerView(point: srcPoint, image: srcModel.image) : nil
        let dstView = (dstPoint.isValid) ? makeDestinationMarkerView(point: dstPoint, image: dstModel.image) : nil
        
        return (animation: {
            dstView?.transform = .identity
            dstView?.alpha = 1
            
            srcView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            srcView?.alpha = 0
            guard let dstCenter = dstView?.center,
                  isMerge && (dstModel.image.size.width == dstModel.image.size.height) ||
                  !isMerge && (srcModel.image.size.width == srcModel.image.size.height) else { return }
            srcView?.center = dstCenter
        }, completion: {
                srcView?.removeFromSuperview()
                dstView?.removeFromSuperview()
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
