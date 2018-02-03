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
}

class GSRRangeSlider: RangeSlider {
    fileprivate var startDate = Parser.midnight
    fileprivate var endDate = Parser.midnight.tomorrow
    
    fileprivate var minDate = Parser.midnight
    fileprivate var maxDate = Parser.midnight.tomorrow
    
    var delegate: GSRRangeSliderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCallbacks()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            let totalMinutes = CGFloat(self.startDate.minutesFrom(date: self.endDate))
            let minMinutes = (Int((CGFloat(min) / 100.0) * totalMinutes) / 60) * 60
            let maxMinutes = (Int((CGFloat(max) / 100.0) * totalMinutes) / 60) * 60
            self.minDate = self.startDate.add(minutes: minMinutes).localTime.roundedDownToHour
            self.maxDate = self.startDate.add(minutes: maxMinutes).localTime.roundedDownToHour
            self.delegate!.parseData(startDate: self.minDate, endDate: self.maxDate)
        }
    }
    
    private func getStringTimeFromValue(_ val: Int) -> String? {
        let formatter = Parser.formatter
        let totalMinutes = CGFloat(startDate.minutesFrom(date: endDate))
        let minutes = Int((CGFloat(val) / 100.0) * totalMinutes)
        let chosenDate = startDate.add(minutes: minutes)
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        formatter.dateFormat = "ha"
        return formatter.string(from: chosenDate)
    }
}

// MARK: - Updating
extension GSRRangeSlider {
    func setStartDate(to date: Date) {
        self.startDate = date
    }
}
