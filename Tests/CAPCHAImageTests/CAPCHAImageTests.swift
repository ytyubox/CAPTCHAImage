import XCTest
import TestUtils
@testable import CAPCHAImage

import UIKit
final class CAPCHAImageTests: XCTestCase {
    
    func testImage() {
        let labels = "123456789".map(\.description)
            .map{ string -> UILabel in
                let label = UILabel()
                label.text = string
                label.textColor = .black
                let rotateEffect = CGAffineTransform(
                    rotationAngle: CGFloat.random(in: -(.pi(0.2))...(.pi(0.2))))
                label.transform = rotateEffect
                label.font = .random(in: 8...20)
                label.sizeToFit()
                label.frame.origin.x = CGFloat.random(in: -5...5)
                label.frame.origin.y = CGFloat.random(in: -20...5)
                return label
            }
        let sut = UIStackView(arrangedSubviews: labels)
        sut.distribution = .equalSpacing
        sut.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        XCTRecord(snapshot: sut.snapshot(for: .init(style: .dark)), named: "LABEL")
    }
    
}

extension UIFont {
    private typealias Factory = (CGFloat, UIFont.Weight) -> UIFont
    private static var factorys:[Factory] {
        
        [
//            UIFont.systemFont,
            //        UIFont.monospacedSystemFont,
            UIFont.monospacedDigitSystemFont,
        ]
    }
    static func random(in range:  ClosedRange<CGFloat>) -> UIFont {
        let fontFactory = factorys.randomElement()!
        return fontFactory(CGFloat.random(in: range), UIFont.Weight.random())
    }
}

extension UIFont.Weight {
    static func random() -> UIFont.Weight {
        let all: [UIFont.Weight] = [
            .ultraLight,
                .thin,
            .light,
            .regular,
            .medium,
            .semibold,
            .bold,
            .heavy,
            .black,

        ]
        return all.randomElement()!
    }
}

extension CGFloat {
    static func pi(_ ratio: CGFloat) -> CGFloat {
        .pi * ratio
    }
}
