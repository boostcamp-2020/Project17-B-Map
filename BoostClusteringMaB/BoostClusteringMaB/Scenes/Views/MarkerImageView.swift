//
//  MarkerImageView.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/23.
//

import UIKit

class MarkerImageView: UILabel {
    var radius: CGFloat {
        get {
            return frame.width / 2
        }
        
        set {
            frame = .init(x: 0, y: 0, width: newValue * 2, height: newValue * 2)
            layer.cornerRadius = newValue
        }
    }
    
    init(radius: CGFloat) {
        super.init(frame: .init(x: 0, y: 0, width: radius * 2, height: radius * 2))
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    private func configureView() {
        layer.cornerRadius = frame.width / 2
        backgroundColor = UIColor.naverGreen
        clipsToBounds = true
        textAlignment = .center
    }
}

// MARK: View to UIImage
extension MarkerImageView {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
