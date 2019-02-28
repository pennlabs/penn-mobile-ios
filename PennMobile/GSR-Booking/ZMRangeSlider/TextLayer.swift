import UIKit

class TextLayer: CATextLayer {

    weak var rangeSlider: RangeSlider?

    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }

        self.fontSize = slider.displayTextFontSize
        self.foregroundColor = slider.trackHighlightTintColor.cgColor
        self.alignmentMode = CATextLayerAlignmentMode.center
        super.draw(in: ctx)
    }
}
