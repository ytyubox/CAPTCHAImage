#if canImport(UIKit)
    import struct UIKit.CGFloat
#elseif canImport(AppKit)
    import AppKit
    public typealias UIFont = NSFont
    public typealias UIColor = NSColor
#endif

public typealias Factory<T> = (Int) -> T
public struct CAPTCHA<Image> {
    public init(
        rotateAngleFactory: @escaping Factory<CAPTCHA.F>,
        frameXFactory: @escaping Factory<CAPTCHA.F>,
        frameYFactory: @escaping Factory<CAPTCHA.F>,
        fontFactory: Factory<UIFont>?,
        colorFactory: Factory<UIColor>?,
        targetString: String
    ) {
        self.rotateAngleFactory = rotateAngleFactory
        self.frameXFactory = frameXFactory
        self.frameYFactory = frameYFactory
        self.fontFactory = fontFactory
        self.colorFactory = colorFactory
        self.targetString = targetString
    }

    // MARK: - Dependencies

    private let attributed: [NSAttributedString.Key: Any] = [:]
    public typealias F = CGFloat
    private let rotateAngleFactory, frameXFactory, frameYFactory: Factory<F>
    private let fontFactory: Factory<UIFont>?
    private let colorFactory: Factory<UIColor>?
    private let targetString: String
    let offset: CGFloat = 10
}

#if canImport(UIKit)
    import UIKit
    public extension CAPTCHA where Image == UIImage {
        internal func rotateEffect(_ index: Int, midX _: CGFloat, midY _: CGFloat) -> CATransform3D {
            let angle = rotateAngleFactory(index)
            return CATransform3DMakeRotation(angle, 0, 0, 1)
        }

        func getUIImage(backgroundColor: UIColor = .clear) throws -> Image {
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
            return try canvas.image(for: .dark)
        }
    }
#endif
