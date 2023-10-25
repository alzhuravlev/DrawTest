//
//  AnnotationView.swift
//  BlueprintTest
//
//  Created by Aleksei Zhuravlev on 12.10.2023.
//

import Foundation
import QuartzCore
import UIKit

class AnnotationsView: UIView {
    private let annotationsLayer = AnnotationsLayer()

    var backgroundView: BackgroundView? {
        didSet {
            annotationsLayer.backgroundView = backgroundView
        }
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        annotationsLayer.frame = bounds
    }

    private func setupViews() {
        layer.addSublayer(annotationsLayer)
    }

    func rebuildShapes() {
        annotationsLayer.rebuildShapes()
    }
}

class AnnotationsLayer: CAShapeLayer {
    var backgroundView: BackgroundView? {
        didSet {
            rebuildShapes()
        }
    }

    override init() {
        super.init()
    }

    override init(layer: Any) {
        let annotationLayer = layer as? AnnotationsLayer
        self.backgroundView = annotationLayer?.backgroundView
        super.init(layer: layer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        guard let backgroundView else { return }

        ctx.setFillColor(UIColor.red.withAlphaComponent(0.4).cgColor)
        ctx.setStrokeColor(UIColor.green.withAlphaComponent(1.0).cgColor)
        ctx.setLineWidth(10)

        backgroundView.pages.forEach { page in
            let p1 = backgroundView.convert(point: CGPoint(x: page.size.width/3, y: page.size.height/3), from: page.index)
            let p2 = backgroundView.convert(point: CGPoint(x: page.size.width/3*2, y: page.size.height/3*2), from: page.index)

            ctx.move(to: CGPoint(x: p1.x, y: p1.y))
            ctx.addLine(to: CGPoint(x: p2.x, y: p1.y))
            ctx.addLine(to: CGPoint(x: p2.x, y: p2.y))
            ctx.addLine(to: CGPoint(x: p1.x, y: p2.y))
            ctx.closePath()
        }


        ctx.drawPath(using: CGPathDrawingMode.fillStroke)
    }

    func rebuildShapes() {
        
        if (true) {
            setNeedsDisplay()
        } else {
            
            guard let backgroundView else { return }
            
            let p = UIBezierPath()
            
            fillColor = UIColor.red.withAlphaComponent(0.4).cgColor
            
            strokeColor = UIColor.green.withAlphaComponent(1.0).cgColor
            lineWidth = 10
            
            backgroundView.pages.forEach { page in
                let p1 = backgroundView.convert(point: CGPoint(x: page.size.width/3, y: page.size.height/3), from: page.index)
                let p2 = backgroundView.convert(point: CGPoint(x: page.size.width/3*2, y: page.size.height/3*2), from: page.index)
                
                p.move(to: CGPoint(x: p1.x, y: p1.y))
                p.addLine(to: CGPoint(x: p2.x, y: p1.y))
                p.addLine(to: CGPoint(x: p2.x, y: p2.y))
                p.addLine(to: CGPoint(x: p1.x, y: p2.y))
                p.close()
            }
            
            path = p.cgPath
        }
    }
}
