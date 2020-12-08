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
        backgroundColor = UIColor.clear
        clipsToBounds = true
        textAlignment = .center
        textColor = .naverGreen
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.minY + rect.height / 3)
        
        let path = UIBezierPath()
        path.move(to: .init(x: rect.midX, y: rect.maxY))
        path.addLine(to: .init(x: rect.midX + rect.width / 4, y: rect.minY + rect.height / 3))
        path.addLine(to: .init(x: rect.midX - rect.width / 4, y: rect.minY + rect.height / 3))
        UIColor.naverGreen.set()
        path.fill()
        path.close()
        
        let mainCircle = UIBezierPath(arcCenter: center,
                                      radius: rect.width / 3,
                                      startAngle: 0,
                                      endAngle: .pi * 2,
                                      clockwise: true)
        UIColor.naverGreen.set()
        mainCircle.fill()
        mainCircle.close()
        
        let semiCircle = UIBezierPath(arcCenter: center,
                                      radius: rect.width / 4,
                                      startAngle: 0,
                                      endAngle: .pi * 2,
                                      clockwise: true)
        UIColor.white.set()
        semiCircle.fill()
        semiCircle.close()
        
        drawText(in: .init(
            x: rect.minX,
            y: rect.minY - rect.height / 6,
            width: rect.width,
            height: rect.height
        ))
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
