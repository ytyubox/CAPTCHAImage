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
                var attributed = self.attributed
                if let font = fontFactory?(index), attributed[.font] == nil {
                    attributed[.font] = font
                }
                if let color = colorFactory?(index), attributed[.foregroundColor] == nil {
                    attributed[.foregroundColor] = color
                }
                label.attributedText = NSAttributedString(string: string, attributes: attributed)
                label.sizeToFit()
                print(label.frame.width, terminator: " ")
                label.layer.transform = rotateEffect(index, midX: label.frame.midX, midY: label.frame.midY)
                let addictionalX = frameXFactory(index) // + offset
                let addictionalY = frameYFactory(index)
//                print(addictionalX)
                label.frame.origin.x = addictionalX + lastMaxX
                print(label.frame.width, terminator: " ")
                label.frame.origin.y = addictionalY
                label.bounds.size.width += addictionalX
                print(label.frame.width, terminator: " ")
                label.frame.size.height += addictionalY
                label.backgroundColor = .red
                print(label.frame.width)
                lastMaxX = label.frame.maxX
                return label
            }
        let canvas = UIView()
        canvas.frame.size.height = labels.map(\.frame.maxY).max()!
        canvas.frame.size.width = lastMaxX + offset
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
    func test10DigitCAPCHAWithNoRandom() throws {
        let sut = makeSUT(text: (1 ... 9).map(\.description).joined())
        let image = try sut.getUIImage()
        XCTAssert(snapshot: image, named: "10Degits")
    }

    // MARK: - Helpers

    private func makeSUT(text: String) -> CAPCHA {
        CAPCHA(
            rotateAngleFactory: { _ in 0 },
            frameXFactory: { _ in 0 },
            frameYFactory: { _ in 0 },
            fontFactory: { _ in .systemFont(ofSize: 15) },
            colorFactory: { [UIColor.blue, UIColor.orange][$0 % 2] },
            targetString: text
        )
    }
}
