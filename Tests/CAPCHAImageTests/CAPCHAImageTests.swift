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
    let offset: CGFloat = 0

    // helper
    func getUIImage(frame: CGRect) throws -> UIImage {
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
                label.attributedText = NSAttributedString(string: string, attributes: attributed)
                label.textColor = colorFactory?(index)
                label.transform = rotateEffect(index)
                label.sizeToFit()
                label.frame.origin.x = frameXFactory(index) +
                    lastMaxX +
                    offset
                lastMaxX = label.frame.maxX
                label.frame.origin.y = frameYFactory(index)
                return label
            }
        let canvas = UIView()
        canvas.frame = frame
        labels.forEach(canvas.addSubview(_:))
        return canvas.snapshot(for: .init(style: .dark))
    }

    func rotateEffect(_ index: Int) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: rotateAngleFactory(index))
    }
}

import UIKit
final class CAPCHAImageTests: XCTestCase {
    func test10DigitCAPCHAWithNoRandom() throws {
        let sut = makeSUT(text: (1 ... 9).map(\.description).joined())
        let image = try sut.getUIImage(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
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
