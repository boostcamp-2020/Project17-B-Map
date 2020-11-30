//
//  MarkerAnimator.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//
import UIKit
import NMapsMap

class MarkerAnimateController {
    private var animationView: UIView?
    private weak var projection: NMFProjection?
    private var animator: UIViewPropertyAnimator?
    private var counter: UInt = 0

    init(view: UIView, projection: NMFProjection) {
        configureAnimationView(view: view)
        self.projection = projection
    }

    private func configureAnimationView(view: UIView) {
        let animationView = UIView(frame: view.frame)
        animationView.backgroundColor = .clear
        view.addSubview(animationView)
        animationView.isUserInteractionEnabled = false

        self.animationView = animationView
    }

    func clusteringAnimation(old: [NMGLatLng], new: [NMGLatLng], isMerge: Bool, completion: (() -> Void)?) {
        self.counter += 1
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
            },
            completion: { _ in
                animations.forEach {
                    $0.completion()
                }
                self.counter -= 1
                if self.counter == 0 {
                    completion?()
                }
            })
    }
    
    private func stop() {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
    }

    private func moveWithAnimation(from source: NMGLatLng, to destination: NMGLatLng) -> (() -> Void, () -> Void)? {
        guard let sourcePoint = projection?.point(from: source),
              let destinationPoint = projection?.point(from: destination),
              sourcePoint.isValid,
              destinationPoint.isValid else {
            return nil
        }

        // 애니메이션 마커의 크기, 마커의 지름을 따라감
        let radius: CGFloat = 30

        let sourcePointView = MarkerImageView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        sourcePointView.center = CGPoint(x: sourcePoint.x, y: sourcePoint.y - radius)
        sourcePointView.transform = .identity
        animationView?.addSubview(sourcePointView)

        let destinationPointView = MarkerImageView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        destinationPointView.center = CGPoint(x: destinationPoint.x, y: destinationPoint.y - radius)
        destinationPointView.alpha = 0
        destinationPointView.transform = CGAffineTransform(scaleX: 0, y: 0)
        animationView?.addSubview(destinationPointView)

        let animationClosure = {
            sourcePointView.center = CGPoint(x: destinationPoint.x, y: destinationPoint.y - radius * 2)
            sourcePointView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            sourcePointView.alpha = 0
            
            destinationPointView.transform = .identity
            destinationPointView.alpha = 1
        }
        let completion = {
            sourcePointView.removeFromSuperview()
            destinationPointView.removeFromSuperview()
        }
        
        return (animation: animationClosure, completion: completion)
    }
}
