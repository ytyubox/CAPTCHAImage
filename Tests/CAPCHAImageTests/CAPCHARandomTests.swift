//
/*
 *		Created by 游宗諭 in 2021/1/28
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 10.15
 */

import TestUtils
import UIKit
import XCTest
class CAPCHARandomTests: XCTestCase {
    func testImage() throws {
        let text = "1" // "123456759"
        let capcha = CAPCHA(
            rotateAngleFactory: { _ in
                .pi(1 / 16)
//                .random(in:
//                          -(.pi(0.01)) ... .pi(0.02)
//                )
            },
            frameXFactory: { _ in .random(in: -1 ... 1) },
            frameYFactory: { _ in .random(in: -1 ... 1) },
            fontFactory: { _ in .random(in: 15 ... 15) },
            colorFactory: { _ in .black },
            targetString: text
        )
        let sut = try capcha.getUIImage(backgroundColor: .white)
        XCTRecord(snapshot: sut, named: "skip-LABEL", remindAssert: false)
    }
}

extension UIFont {
    private typealias Factory = (CGFloat, UIFont.Weight) -> UIFont
    private static var factorys: [Factory] {
        [
            //            UIFont.systemFont,
            //        UIFont.monospacedSystemFont,
            UIFont.monospacedDigitSystemFont,
        ]
    }

    static func random(in range: ClosedRange<CGFloat>) -> UIFont {
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
