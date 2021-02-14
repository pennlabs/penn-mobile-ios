import UIKit

class ThumbLayer: CALayer {

    var isHighlight = false {
        didSet {
            setNeedsDisplay()
        }
    }

    weak var rangeSlider: RangeSlider?

    var thumbTint : CGColor = UIColor.gray.cgColor
   
    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }

        let thumbFrame = bounds.insetBy(dx: slider.thumbOutlineSize / 2.0, dy: slider.thumbOutlineSize / 2.0)
        let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: thumbFrame.height * 0.5)
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()

        ctx.setStrokeColor(thumbTint)
        ctx.setLineWidth(slider.thumbOutlineSize)
        ctx.addPath(thumbPath.cgPath)
        ctx.strokePath()

        if isHighlight {
            ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}
