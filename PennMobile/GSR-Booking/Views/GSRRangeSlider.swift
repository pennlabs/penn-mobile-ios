//
//  GSRRangeSlider.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol GSRRangeSliderDelegate {
    func parseData(startDate: Date, endDate: Date)
    func existsNonEmptyRoom() -> Bool
    func getMinDate() -> Date?
    func getMaxDate() -> Date?
}

class GSRRangeSlider: RangeSlider {
    fileprivate var startDate = Date.midnightYesterday
    fileprivate var endDate = Date.midnightToday
    
    fileprivate var minDate = Date.midnightYesterday
    fileprivate var maxDate = Date.midnightToday
    
    var delegate: GSRRangeSliderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCallbacks()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reload
    override func reload() {
        guard let start = delegate?.getMinDate(), let end = delegate?.getMaxDate() else { return }
        startDate = start
        endDate = end
        super.reload()
    }
}

// MARK: - Setup
extension GSRRangeSlider {
    fileprivate func setupUI() {
        self.setMinAndMaxValue(0, maxValue: 100)
        self.thumbSize = 24.0
        self.displayTextFontSize = 14.0
    }
    
    fileprivate func setupCallbacks() {
        self.setMinValueDisplayTextGetter { (minValue) -> String? in
            return self.delegate!.existsNonEmptyRoom() ? self.getStringTimeFromValue(minValue) : ""
        }
        self.setMaxValueDisplayTextGetter { (maxValue) -> String? in
            return self.delegate!.existsNonEmptyRoom() ? self.getStringTimeFromValue(maxValue) : ""
        }
        self.setValueFinishedChangingCallback { (min, max) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-hh-mma"
            print("Start: \(formatter.string(from: self.startDate))")
            print("Mid: \(formatter.string(from: self.endDate))")
            let totalMinutes = CGFloat(self.startDate.minutesFrom(date: self.endDate))
            print(totalMinutes)
            let minMinutes = (Int((CGFloat(min) / 100.0) * totalMinutes) / 60) * 60
            let maxMinutes = (Int((CGFloat(max) / 100.0) * totalMinutes) / 60) * 60
            print(maxMinutes)
            self.minDate = self.startDate.add(minutes: minMinutes).roundedDownToHour
            self.maxDate = self.startDate.add(minutes: maxMinutes).roundedDownToHour
            print("Start: \(formatter.string(from: self.minDate))")
            print("Mid: \(formatter.string(from: self.startDate.add(minutes: maxMinutes)))")
            print("End: \(formatter.string(from: self.maxDate))")
            self.delegate!.parseData(startDate: self.minDate, endDate: self.maxDate)
        }
    }
    
    private func getStringTimeFromValue(_ val: Int) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let totalMinutes = CGFloat(startDate.minutesFrom(date: endDate))
        let minutes = Int((CGFloat(val) / 100.0) * totalMinutes)
        let chosenDate = startDate.add(minutes: minutes)
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        formatter.dateFormat = "ha"
        return formatter.string(from: chosenDate)
    }
}
