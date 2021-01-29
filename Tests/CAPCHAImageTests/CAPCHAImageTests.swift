import TestUtils
import XCTest

typealias Factory<T> = (Int) -> T
struct CAPCHA {
    internal init(rotateAngleFactory: @escaping Factory<CAPCHA.F>, frameXFactory: @escaping Factory<CAPCHA.F>, frameYFactory: @escaping Factory<CAPCHA.F>, fontFactory: Factory<UIFont>?, colorFactory: Factory<UIColor>?, targetString: String) {
        self.rotateAngleFactory = rotateAngleFactory
        self.frameXFactory = frameXFactory
        self.frameYFactory = frameYFactory
        self.fontFactory = fontFactory
        self.colorFactory = colorFactory
        self.targetString = targetString
    }

    // MARK: - Dependencies

    private let attributed: [NSAttributedString.Key: Any] = [:]
    typealias F = CGFloat
    private let rotateAngleFactory, frameXFactory, frameYFactory: Factory<F>
    private let fontFactory: Factory<UIFont>?
    private let colorFactory: Factory<UIColor>?
    private let targetString: String
    let offset: CGFloat = 10

    // helper
    func getUIImage(backgroundColor: UIColor = .clear) throws -> UIImage {
        let chars = targetString
            .map(\.description)
        var lastMaxX: CGFloat = 0
        let labels: [UILabel] = chars
            .enumerated()
            .map { (index, string) -> UILabel in
                let label = UILabel()
                label.textAlignment = .center
                var attributed = self.attributed
                if let font = fontFactory?(index), attributed[.font] == nil {
                    attributed[.font] = font
                }
                if let color = colorFactory?(index), attributed[.foregroundColor] == nil {
                    attributed[.foregroundColor] = color
                }
                label.attributedText = NSAttributedString(string: string, attributes: attributed)
                label.sizeToFit()
                let addictionalX = frameXFactory(index) // + offset
                let addictionalY = frameYFactory(index)
                label.frame.origin.x = addictionalX + lastMaxX
                label.frame.origin.y = addictionalY
                label.bounds.size.width += addictionalX
                label.frame.size.height += addictionalY
                lastMaxX = label.frame.maxX
                return label
            }
        for (index, label) in labels.enumerated() {
            label.layer.transform = rotateEffect(index, midX: label.frame.midX, midY: label.frame.midY)
        }
        let canvas = UIView()
        canvas.frame.size.height = labels.map(\.frame.maxY).max()!
        canvas.frame.size.width = lastMaxX
        canvas.backgroundColor = backgroundColor
        labels.forEach(canvas.addSubview(_:))
        return canvas.snapshot(for: .init(style: .dark))
    }

    func rotateEffect(_ index: Int, midX _: CGFloat, midY _: CGFloat) -> CATransform3D {
        let angle = rotateAngleFactory(index)
        return CATransform3DMakeRotation(angle, 0, 0, 1)
    }
}

import UIKit
final class CAPCHAImageTests: XCTestCase {
    func test10DigitCAPCHAWithNoRotatation() throws {
        let sut = makeSUT()
        let image = try sut.getUIImage()
        XCTAssert(snapshot: image, named: "10DigitsNoRotation")
    }

    func test10DigitCAPCHAWithRotatationby45Degree() throws {
        let sut = makeSUT(rotateAngleFactory: {
            _ in
            .degree(45)
        })
        let image = try sut.getUIImage()
        XCTAssert(snapshot: image, named: "10DigitsWithAllRotation45Degree")
    }

    func test10DigitCAPCHAWithRotatationby90Degree() throws {
        let sut = makeSUT(rotateAngleFactory: {
            _ in
            .degree(90)
        })
        let image = try sut.getUIImage()
        XCTAssert(snapshot: image, named: "10DigitsWithAllRotation90Degree")
    }

    // MARK: - Helpers

    private func makeSUT(
        text: String = "123456789",
        rotateAngleFactory: @escaping Factory<CAPCHA.F> = { _ in 0 },
        frameXFactory: @escaping Factory<CAPCHA.F> = { _ in 0 },
        frameYFactory: @escaping Factory<CAPCHA.F> = { _ in 0 },
        fontFactory: @escaping Factory<UIFont> = { _ in .systemFont(ofSize: 15) },
        colorFactory: @escaping Factory<UIColor> = { [UIColor.blue, UIColor.orange][$0 % 2] }
    ) -> CAPCHA {
        CAPCHA(
            rotateAngleFactory: rotateAngleFactory,
            frameXFactory: frameXFactory,
            frameYFactory: frameYFactory,
            fontFactory: fontFactory,
            colorFactory: colorFactory,
            targetString: text
        )
    }
}

extension CGFloat {
    static func degree(_ amount: CGFloat) -> CGFloat {
        .pi * amount / 180
    }
}
