//
//  MarkerImageView.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/23.
//

import UIKit

class MarkerImageView: UILabel {
    let maxFontSize: CGFloat = 20
    var size: CGFloat {
        get {
            return frame.width
        }
        
        set {
            let fontSize: CGFloat = newValue / (CGFloat(text?.count ?? 1) * 1.5)
            font = .boldSystemFont(ofSize: (fontSize < maxFontSize) ? fontSize : maxFontSize)
            frame = .init(x: 0, y: 0, width: newValue, height: newValue)
        }
    }
    
    init(size: CGFloat) {
        super.init(frame: .init(x: 0, y: 0, width: size, height: size))
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
        backgroundColor = UIColor.clear
        textAlignment = .center
        textColor = .naverGreen
        numberOfLines = 0
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
            x: rect.minX + rect.width / 4,
            y: rect.minY - rect.height / 6 + rect.height / 4,
            width: rect.width / 2,
            height: rect.height / 2
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
