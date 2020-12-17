//
//  MarkerLayerFactory.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/23.
//

import UIKit

final class MarkerLayerFactory {
    let maxFontSize: CGFloat = 20
    var size: CGFloat
    var text: String = ""
    
    init(size: CGFloat) {
        self.size = size
    }
    
    private func makeMarkerFrameLayer(_ rect: CGRect) -> CAShapeLayer {
        let circleCenter = CGPoint(x: rect.midX, y: rect.minY + rect.height / 3 + 1)
        let mainPath = UIBezierPath(arcCenter: circleCenter,
                                      radius: rect.width / 3,
                                      startAngle: (30 * .pi) / 180,
                                      endAngle: (150 * .pi) / 180,
                                      clockwise: false)
        mainPath.addArc(withCenter: .init(x: rect.midX, y: rect.maxY - 1),
                          radius: 0,
                          startAngle: (150 * .pi) / 180,
                          endAngle: (20 * .pi) / 180,
                          clockwise: false)
        
        let markerLayer = CAShapeLayer()
        markerLayer.frame = rect
        markerLayer.path = mainPath.cgPath
        markerLayer.shadowOffset = .init(width: 1, height: 1)
        markerLayer.fillColor = UIColor.naverGreen.cgColor
        markerLayer.shadowOpacity = 0.2
        
        let circlePath = UIBezierPath(arcCenter: circleCenter,
                                      radius: rect.width / 4,
                                      startAngle: 0,
                                      endAngle: .pi * 2,
                                      clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.frame = rect
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.white.cgColor
        circleLayer.shadowOffset = .init(width: 1, height: 1)
        circleLayer.shadowOpacity = 0.5
        markerLayer.addSublayer(circleLayer)
        markerLayer.contentsScale = UIScreen.main.scale
        return markerLayer
    }
    
    private func makeTextLayer(_ rect: CGRect) -> CALayer {
        let textLayer = MarkerTextLayer()
        textLayer.frame = .init(
            x: rect.minX + rect.width / 4,
            y: rect.minY - rect.height / 6 + rect.height / 4,
            width: rect.width / 2,
            height: rect.height / 2
        )
        textLayer.string = self.text
        var fontSize: CGFloat = rect.width / (CGFloat(text.count) * 1.5)
        fontSize = (fontSize < maxFontSize) ? fontSize : maxFontSize
        textLayer.font = UIFont.boldSystemFont(ofSize: fontSize)
        textLayer.fontSize = fontSize
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = UIColor.naverGreen.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
    private func makeLayer(_ size: CGFloat) -> CAShapeLayer {
        let rect = CGRect.init(x: 0, y: 0, width: size, height: size)
        let markerLayer = makeMarkerFrameLayer(rect)
        markerLayer.addSublayer(makeTextLayer(rect))
        return markerLayer
    }
}

// MARK: View to UIImage
extension MarkerLayerFactory {
    func snapshot() -> UIImage {
        let marker = makeLayer(size)
        let renderer = UIGraphicsImageRenderer(bounds: marker.bounds)
        return renderer.image { rendererContext in
            marker.render(in: rendererContext.cgContext)
        }
    }
}

final class MarkerTextLayer: CATextLayer {
    override func draw(in context: CGContext) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/10
        context.saveGState()
        context.translateBy(x: 0, y: yDiff)
        super.draw(in: context)
        context.restoreGState()
    }
}
