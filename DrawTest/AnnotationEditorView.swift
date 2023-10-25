//
//  AcuRendererView.swift
//  BlueprintTest
//
//  Created by Aleksei Zhuravlev on 14.10.2023.
//

import Foundation
import PDFKit
import UIKit

class AnnotationsEditorView: UIView {
    private let backgroundView: BackgroundView

    init?(data: Data) {
        guard let view = BackgroundViewPdf(data: data) else { return nil }
        backgroundView = view as! BackgroundView

        super.init(frame: .zero)

        setupViews(view: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}

class BackgroundViewPage {
    let index: Int
    let size: CGSize

    init(index: Int, size: CGSize) {
        self.index = index
        self.size = size
    }
}

protocol BackgroundView {
    var pages: [BackgroundViewPage] { get }
    func convert(point: CGPoint, from pageIndex: Int) -> CGPoint
    func convert(point: CGPoint, to pageIndex: Int) -> CGPoint
}

class BackgroundViewPdf: UIView {
    private var originalDelegate: UIScrollViewDelegate?

    private let pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.displayBox = .cropBox
        pdfView.enableDataDetectors = false
        pdfView.isInMarkupMode = true
        return pdfView
    }()

    private let annotationsView: AnnotationsView = {
        let annotationsView = AnnotationsView()
        annotationsView.translatesAutoresizingMaskIntoConstraints = false
        annotationsView.isUserInteractionEnabled = false
        return annotationsView
    }()

    init?(data: Data) {
        guard let document = PDFDocument(data: data) else { return nil }

        super.init(frame: .zero)

//        document.delegate = self
        pdfView.document = document

        annotationsView.backgroundView = self

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pdfView.autoScales = true
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit * 0.1
        pdfView.maxScaleFactor = pdfView.scaleFactorForSizeToFit * 5.0
    }

    private func setupViews() {
        guard let documentView = pdfView.documentView else { return }

        addSubview(pdfView)
        addSubview(annotationsView)

        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pdfView.leftAnchor.constraint(equalTo: leftAnchor),
            pdfView.rightAnchor.constraint(equalTo: rightAnchor),

            annotationsView.topAnchor.constraint(equalTo: topAnchor),
            annotationsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            annotationsView.leftAnchor.constraint(equalTo: leftAnchor),
            annotationsView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        annotationsView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)

        pdfView.scrollView?.isDirectionalLockEnabled = false
        pdfView.scrollView?.bounces = false
        pdfView.scrollView?.bouncesZoom = false
        
        originalDelegate = pdfView.scrollView?.delegate
        pdfView.scrollView?.delegate = self
    }
}

// extension BackgroundViewPdf: PDFDocumentDelegate {
//    func classForPage() -> AnyClass {
//        AnnotationPDFPage.self
//    }
// }

extension BackgroundViewPdf: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        annotationsView.rebuildShapes()
        originalDelegate?.scrollViewDidScroll?(scrollView)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        annotationsView.rebuildShapes()
        originalDelegate?.scrollViewDidZoom?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        originalDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        originalDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return originalDelegate?.viewForZooming?(in: scrollView)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        originalDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        originalDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
//        annotationsView.rebuildShapes()
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return originalDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? false
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}

extension BackgroundViewPdf: BackgroundView {
    var pages: [BackgroundViewPage] {
        var result: [BackgroundViewPage] = []
        let pageCount = pdfView.document?.pageCount ?? 0
        for i in 0 ..< pageCount {
            guard let page = pdfView.document?.page(at: i) else { continue }
            let pageBounds = page.bounds(for: .mediaBox)
            let pageIndex = i
            let pageSize = CGSize(width: pageBounds.width, height: pageBounds.height)
            result.append(BackgroundViewPage(index: pageIndex, size: pageSize))
        }
        return result
    }

    func convert(point: CGPoint, from pageIndex: Int) -> CGPoint {
        guard let page = pdfView.document?.page(at: pageIndex) else { return point }
        return pdfView.convert(point, from: page)
    }

    func convert(point: CGPoint, to pageIndex: Int) -> CGPoint {
        guard let page = pdfView.document?.page(at: pageIndex) else { return point }
        return pdfView.convert(point, to: page)
    }
}

extension PDFView {
    var scrollView: UIScrollView? {
        return subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
}

class AnnotationPDFPage: PDFPage {
    override func draw(with box: PDFDisplayBox, to ctx: CGContext) {
        super.draw(with: box, to: ctx)

//        let string: NSString = "FREE SAMPLE"
//        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red, .font: UIFont.boldSystemFont(ofSize: 65)]
//        let stringSize = string.size(withAttributes: attributes)

//        UIGraphicsPushContext(context)
//        context.saveGState()
//
//        let pageBounds = bounds(for: box)
//        context.translateBy(x: (pageBounds.size.width - stringSize.width) / 2, y: pageBounds.size.height)
//        context.scaleBy(x: 1.0, y: -1.0)
//
//        string.draw(at: CGPoint(x: 0, y: 55), withAttributes: attributes)
//
//        context.restoreGState()
//        UIGraphicsPopContext()

        ctx.saveGState()

        let s = ctx.convertToUserSpace(CGSize(width: 10, height: 0))

        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 50, y: 0)
        let p3 = CGPoint(x: 50, y: 50)
        let p4 = CGPoint(x: 0, y: 50)

        ctx.setFillColor(UIColor.red.cgColor)
        ctx.setStrokeColor(UIColor.green.cgColor)
        ctx.setLineWidth(s.width)

        ctx.beginPath()
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        ctx.addLine(to: p3)
        ctx.addLine(to: p4)
        ctx.closePath()
        ctx.drawPath(using: CGPathDrawingMode.fillStroke)

        ctx.restoreGState()
    }
}
