//
//  AutomatedScreenshotUITests.swift
//  AutomatedScreenshotUITests
//
//  Created by Dominic Holmes on 2/23/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import XCTest
import SimulatorStatusMagic

class AutomatedScreenshotUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        // Fastlane Setup
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        SDStatusBarManager.sharedInstance().carrierName = "AirPennNet"
        SDStatusBarManager.sharedInstance().timeString = "9:41"
        SDStatusBarManager.sharedInstance().bluetoothState = .hidden
        SDStatusBarManager.sharedInstance().batteryDetailEnabled = false
        SDStatusBarManager.sharedInstance().enableOverrides()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SDStatusBarManager.sharedInstance().disableOverrides()
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Home
        let app = XCUIApplication()
        app.buttons["CONTINUE AS GUEST"].tap()
        snapshot("01Home", timeWaitingForIdle: 3)
        
        // Dining
        let tabBarsQuery = app.tabBars
        tabBarsQuery.children(matching: .other).element(boundBy: 1).tap()
        snapshot("02Dining", waitForLoadingIndicator: true)
        
        // GSR
        tabBarsQuery.otherElements["GSR - tab - 3 of 5"].tap()
        snapshot("03GSR", timeWaitingForIdle: 5)
        // GSR takes a while, run with fast wifi to avoid loading indicators on the screenshots
        snapshot("03GSR", timeWaitingForIdle: 5)
        
        // Laundry
        tabBarsQuery.otherElements["Laundry - tab - 4 of 5"].tap()
        // Laundry takes a while, run with fast wifi to avoid loading indicators on the screenshots
        snapshot("04Laundry", timeWaitingForIdle: 5)
        
        // More
        tabBarsQuery.otherElements["More - tab - 5 of 5"].tap()
        snapshot("05More", waitForLoadingIndicator: true)
    }

}
