import UIKit

@IBDesignable
open class RangeSlider: UIControl {

    public typealias ValueChangedCallback = (_ minValue: Int, _ maxValue: Int) -> Void
    public typealias ValueFinishedChangingCallback = (_ minValue: Int, _ maxValue: Int) -> Void
    public typealias MinValueDisplayTextGetter = (_ minValue: Int) -> String?
    public typealias MaxValueDisplayTextGetter = (_ maxValue: Int) -> String?

    fileprivate let trackLayer = TrackLayer()
    fileprivate let minValueThumbLayer = ThumbLayer()
    fileprivate let minValueDisplayLayer = TextLayer()
    fileprivate let maxValueThumbLayer = ThumbLayer()
    fileprivate let maxValueDisplayLayer = TextLayer()

    fileprivate var beginTrackLocation = CGPoint.zero
    fileprivate var rangeValues = Array(0...100)

    fileprivate var valueChangedCallback: ValueChangedCallback?
    fileprivate var valueFinishedChangingCallback: ValueFinishedChangingCallback?
    fileprivate var minValueDisplayTextGetter: MinValueDisplayTextGetter?
    fileprivate var maxValueDisplayTextGetter: MaxValueDisplayTextGetter?
    
    var minValue: Int
    var maxValue: Int
    var thumbRadius: CGFloat

    open override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var trackHeight: CGFloat = 6.0 {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            updateLayerFrames()
        }
    }

   @IBInspectable open var minValueThumbTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
      didSet {
         minValueThumbLayer.thumbTint = minValueThumbTintColor.cgColor
         updateLayerFrames()
      }
   }

   @IBInspectable open var maxValueThumbTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
      didSet {
         maxValueThumbLayer.thumbTint = maxValueThumbTintColor.cgColor
         updateLayerFrames()
      }
   }

    @IBInspectable open var trackHighlightTintColor: UIColor = UIColor(red: 2.0 / 255, green: 192.0 / 255, blue: 92.0 / 255, alpha: 1.0) {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var thumbSize: CGFloat = 32.0 {
        didSet {
            thumbRadius = thumbSize / 2.0
            updateLayerFrames()
        }
    }
    
    @IBInspectable open var displayWidth: CGFloat = 24.0 {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var thumbOutlineSize: CGFloat = 2.0 {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var displayTextFontSize: CGFloat = 14.0 {
        didSet {
            updateLayerFrames()
        }
    }

    public override init(frame: CGRect) {
        minValue = rangeValues[0]
        maxValue = rangeValues[rangeValues.count - 1]
        thumbRadius = thumbSize / 2.0
        super.init(frame: frame)
        setupLayers()
    }

    public required init?(coder aDecoder: NSCoder) {
        minValue = rangeValues[0]
        maxValue = rangeValues[rangeValues.count - 1]
        thumbRadius = thumbSize / 2.0
        super.init(coder: aDecoder)
        setupLayers()
    }

    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerFrames()
    }

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        beginTrackLocation = touch.location(in: self)
        if minValueThumbLayer.frame.contains(beginTrackLocation) {
            minValueThumbLayer.isHighlight = true
        } else if maxValueThumbLayer.frame.contains(beginTrackLocation) {
            maxValueThumbLayer.isHighlight = true
        }

        return minValueThumbLayer.isHighlight || maxValueThumbLayer.isHighlight
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let count = rangeValues.count
        var index = Int(location.x * CGFloat(count) / (bounds.width - thumbSize))

        if maxValue == minValue && location.x > beginTrackLocation.x && !maxValueThumbLayer.isHighlight {
            maxValueThumbLayer.isHighlight = true
            minValueThumbLayer.isHighlight = false
        }

        if index < 0 {
            index = 0
        } else if index > count - 1 {
            index = count - 1
        }

        if minValueThumbLayer.isHighlight {
            if index > rangeValues.index(of: maxValue)! {
                minValue = maxValue
            } else {
                minValue = rangeValues[index]
            }
        } else if maxValueThumbLayer.isHighlight {
            if index < rangeValues.index(of: minValue)! {
                maxValue = minValue
            } else {
                maxValue = rangeValues[index]
            }
        }
        updateLayerFrames()
        valueChangedCallback?(minValue, maxValue)
        return true
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        minValueThumbLayer.isHighlight = false
        maxValueThumbLayer.isHighlight = false
        valueFinishedChangingCallback?(minValue, maxValue)
    }

    @nonobjc
    open func setRangeValues(_ rangeValues: [Int]) {
        self.rangeValues = rangeValues
        setMinAndMaxValue(rangeValues[0], maxValue: rangeValues[rangeValues.count - 1])
    }

    open func setMinAndMaxValue(_ minValue: Int, maxValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        updateLayerFrames()
    }

    open func setValueChangedCallback(_ callback: ValueChangedCallback?) {
        self.valueChangedCallback = callback
    }
    
    open func setValueFinishedChangingCallback(_ callback: ValueFinishedChangingCallback?) {
        self.valueFinishedChangingCallback = callback
    }

    open func setMinValueDisplayTextGetter(_ getter: MinValueDisplayTextGetter?) {
        self.minValueDisplayTextGetter = getter
    }

    open func setMaxValueDisplayTextGetter(_ getter: MaxValueDisplayTextGetter?) {
        self.maxValueDisplayTextGetter = getter
    }

    func setupLayers() {
        layer.backgroundColor = UIColor.clear.cgColor

        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)

        minValueThumbLayer.rangeSlider = self
        minValueThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(minValueThumbLayer)

        minValueDisplayLayer.rangeSlider = self
        minValueDisplayLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(minValueDisplayLayer)

        maxValueThumbLayer.rangeSlider = self
        maxValueThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(maxValueThumbLayer)

        maxValueDisplayLayer.rangeSlider = self
        maxValueDisplayLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(maxValueDisplayLayer)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        trackLayer.frame = CGRect(x: 0,
                                  y: (bounds.height - trackHeight + 1) / 2,
                                  width: bounds.width,
                                  height: trackHeight)
        trackLayer.setNeedsDisplay()

        let offsetY = (bounds.height - thumbSize) / 2.0
        let displayLayerOffsetY = offsetY - thumbRadius - 10

        let minValuePosition = position(minValue) - thumbRadius
        minValueThumbLayer.frame = CGRect(x: minValuePosition,
                                          y: offsetY,
                                          width: thumbSize,
                                          height: thumbSize)
        minValueThumbLayer.setNeedsDisplay()

        minValueDisplayLayer.frame = CGRect(x: minValuePosition,
                                            y: displayLayerOffsetY,
                                            width: displayWidth,
                                            height: displayTextFontSize + 4)

        if let minValueDisplayText = minValueDisplayTextGetter?(minValue) {
            minValueDisplayLayer.string = minValueDisplayText
        } else {
            minValueDisplayLayer.string = "\(minValue)"
        }

        minValueDisplayLayer.setNeedsDisplay()


        let maxValuePosition = position(maxValue) - thumbRadius
        maxValueThumbLayer.frame = CGRect(x: maxValuePosition,
                                          y: offsetY,
                                          width: thumbSize,
                                          height: thumbSize)
        maxValueThumbLayer.setNeedsDisplay()

        maxValueDisplayLayer.frame = CGRect(x: maxValuePosition,
                                            y: displayLayerOffsetY,
                                            width: displayWidth,
                                            height: displayTextFontSize + 4)
        
        if let maxValueDisplayText = maxValueDisplayTextGetter?(maxValue) {
            maxValueDisplayLayer.string = maxValueDisplayText
        } else {
            maxValueDisplayLayer.string = "\(maxValue)"
        }

        maxValueDisplayLayer.setNeedsDisplay()

        CATransaction.commit()
    }

    func position(_ value: Int) -> CGFloat {
        let index = rangeValues.index(of: value)!
        let count = rangeValues.count
        if index == 0 {
            return thumbRadius
        } else if index == count - 1 {
            return bounds.width - thumbRadius
        }

        return (bounds.width - thumbSize) * CGFloat(index) / CGFloat(count) + thumbRadius
    }
    
    func reload() {
        updateLayerFrames()
        valueFinishedChangingCallback?(minValue, maxValue)
    }
    
    open var isSliding: Bool {
        get {
            return !maxValueThumbLayer.isHighlight || !maxValueThumbLayer.isHighlight
        }
    }
}
