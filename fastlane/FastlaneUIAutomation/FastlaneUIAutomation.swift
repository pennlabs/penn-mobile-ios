//
//  FastlaneUIAutomation.swift
//  FastlaneUIAutomation
//
//  Created by Dominic Holmes on 9/8/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import XCTest

class FastlaneUIAutomation: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        // Fastlane setup
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        
        snapshot("01Dining", waitForLoadingIndicator: true)
        app.tables/*@START_MENU_TOKEN@*/.cells.containing(.image, identifier:"1920 Commons")/*[[".cells.containing(.staticText, identifier:\"11 - 3  |  5 - 7:30\")",".cells.containing(.staticText, identifier:\"1920 Commons\")",".cells.containing(.image, identifier:\"1920 Commons\")"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element.tap()
        snapshot("02Building", waitForLoadingIndicator: true)
        app.navigationBars["Dining"].buttons["Dining"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.children(matching: .other).element(boundBy: 1).tap()
        // GSR takes a while, run with fast wifi to avoid loading indicators on the screenshots
        snapshot("03GSR", timeWaitingForIdle: 5)
        tabBarsQuery.otherElements["Laundry - tab - 3 of 5"].tap()
        // Laundry takes a while, run with fast wifi to avoid loading indicators on the screenshots
        snapshot("03Laundry", timeWaitingForIdle: 5)
        tabBarsQuery.otherElements["Fitness - tab - 4 of 5"].tap()
        snapshot("05Fitness", waitForLoadingIndicator: true)
        tabBarsQuery.otherElements["More - tab - 5 of 5"].tap()
        snapshot("06More", waitForLoadingIndicator: true)
        
    }
    
}
