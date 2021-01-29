#if canImport(UIKit)
    import CAPTCHAImage
    import TestUtils
    import XCTest

    final class CAPTCHAImageTests: XCTestCase {
        func test10DigitCAPTCHAWithNoRotatation() throws {
            let sut = makeSUT()
            let image = try sut.getUIImage()
            XCTAssert(snapshot: image, named: "10DigitsNoRotation")
        }

        func test10DigitCAPTCHAWithRotatationby45Degree() throws {
            let sut = makeSUT(rotateAngleFactory: {
                _ in
                .degree(45)
            })
            let image = try sut.getUIImage()
            XCTAssert(snapshot: image, named: "10DigitsWithAllRotation45Degree")
        }

        func test10DigitCAPTCHAWithRotatationby90Degree() throws {
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
            rotateAngleFactory: @escaping Factory<CAPTCHA<UIImage>.F> = { _ in 0 },
            frameXFactory: @escaping Factory<CAPTCHA<UIImage>.F> = { _ in 0 },
            frameYFactory: @escaping Factory<CAPTCHA<UIImage>.F> = { _ in 0 },
            fontFactory: @escaping Factory<UIFont> = { _ in .systemFont(ofSize: 15) },
            colorFactory: @escaping Factory<UIColor> = { [UIColor.blue, UIColor.orange][$0 % 2] }
        ) -> CAPTCHA<UIImage> {
            CAPTCHA(
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

#endif
