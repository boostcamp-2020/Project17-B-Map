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

    func clusteringAnimation(old: [NMGLatLng], new: [NMGLatLng], isMerge: Bool, completion: @escaping () -> Void) {
        let upper = isMerge ? new : old
        let lower = isMerge ? old : new
        let group = DispatchGroup()

        lower.compactMap { lowerMarker in
            guard let upperMarker = upper
                    .map({ upperMarker in
                        (upperMarker, lowerMarker.distance(to: upperMarker))
                    })
                    .min(by: { (lhs, rhs) -> Bool in
                        lhs.1 < rhs.1
                    })?
                    .0
            else { return nil }

            return isMerge ? (lowerMarker, upperMarker) : (upperMarker, lowerMarker)
        }.forEach { (from: NMGLatLng, to: NMGLatLng) -> Void in
            group.enter()
            moveWithAnimation(from: from, to: to, complete: {
                group.leave()
            })
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    private func moveWithAnimation(from source: NMGLatLng, to destination: NMGLatLng, complete: (() -> Void)?) {
        guard let sourcePoint = projection?.point(from: source),
              let destinationPoint = projection?.point(from: destination),
              sourcePoint.isValid,
              destinationPoint.isValid else {
            complete?()
            return
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

        UIView.animate(
            withDuration: 0.5,
            animations: {
                sourcePointView.center = CGPoint(x: destinationPoint.x, y: destinationPoint.y - radius * 2)
                sourcePointView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                sourcePointView.alpha = 0

                destinationPointView.transform = .identity
                destinationPointView.alpha = 1
            },
            completion: { _ in
                sourcePointView.removeFromSuperview()
                destinationPointView.removeFromSuperview()
                complete?()
            })
    }
}
