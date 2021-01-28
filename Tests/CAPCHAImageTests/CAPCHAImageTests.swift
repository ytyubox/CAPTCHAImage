import XCTest
import TestUtils

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
    private let attributed: [NSAttributedString.Key : Any] = [:]
    typealias F = CGFloat
    private let rotateAngleFactory, frameXFactory, frameYFactory:Factory<F>
    private let fontFactory:Factory<UIFont>?
    private let colorFactory:Factory<UIColor>?
    private let targetString:String
    let offset: CGFloat = 0
    
    // helper
    func getUIImage(frame: CGRect) throws -> UIImage {
        let chars = targetString
            .map(\.description)
        var lastMaxX: CGFloat = 0
        let labels:[UILabel] = chars
            .enumerated()
            .map{ (index, string) -> UILabel in
                let i = CGFloat(index)
                let label = UILabel()
                var attributed = self.attributed
                if let font = fontFactory?(index), attributed[.font] == nil{
                    attributed[.font] = font
                }
                label.attributedText = NSAttributedString( string: string, attributes: attributed)
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
        canvas.backgroundColor = .white
        labels.forEach(canvas.addSubview(_:))
        return canvas.snapshot(for: .init(style: .dark))
    }
    func rotateEffect(_ index: Int) -> CGAffineTransform {
        CGAffineTransform( rotationAngle: rotateAngleFactory(index))
    }
}


import UIKit
final class CAPCHAImageTests: XCTestCase {
    func test10DigitCAPCHAWithNoRandom() throws {
        let sut = makeSUT(text: (1...9).map(\.description).joined())
        let image = try sut.getUIImage(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTRecord(snapshot: image, named: "10Degits")
    }
    
    func testImage() {
        let labels = "123456789".map(\.description)
            .map{ string -> UILabel in
                let label = UILabel()
                label.attributedText = NSAttributedString(
                    string: string,
                    attributes: [.font: UIFont.random(in: 15...15)])
                label.textColor = .black
                let rotateEffect = CGAffineTransform(
                    rotationAngle: CGFloat.random(in: -(.pi(0.2))...(.pi(0.2))))
                label.transform = rotateEffect
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
    // MARK: - Helpers
    
    private func makeSUT(text: String) -> CAPCHA {
        CAPCHA(
            rotateAngleFactory: {_ in 0},
            frameXFactory: {_ in 0},
            frameYFactory: {_ in 0},
            fontFactory: {_ in .systemFont(ofSize: 15)},
            colorFactory: {  [UIColor.blue, UIColor.orange][$0%2]},
            targetString: text)
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
