//
//  SweechTests.swift
//  SweechTests
//
//  Created by Tatsuya Tobioka on 6/11/16.
//  Copyright © 2016 tnantoka. All rights reserved.
//

import XCTest
import Sweech
import AVFoundation

class SweechTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Sweech.instance.reset()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testUtterance() {
        let sweech = Sweech.instance
        
        sweech.string = "text"
        let utteranceA = sweech.utterance
        
        sweech.string = "text"
        let utteranceB = sweech.utterance

        sweech.string = "text2"
        let utteranceC = sweech.utterance

        XCTAssertEqual(utteranceA, utteranceB)
        XCTAssertNotEqual(utteranceB, utteranceC)
    }

    func testSpeack() {
        let expectation = self.expectation(description: "")
        
        let sweech = Sweech.instance
        sweech.string = "text"
        sweech.didStart = { utterance in
            XCTAssertEqual(sweech.string, utterance.speechString)
            XCTAssertTrue(sweech.speaking)
            expectation.fulfill()
        }
// FIXME: Fail on Travis
//        sweech.didFinish = { utterance in
//            XCTAssertEqual(sweech.string, utterance.speechString)
//            expectation.fulfill()
//        }
        sweech.speak()

        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testPause() {
        let expectation = self.expectation(description: "")
        
        let sweech = Sweech.instance
        sweech.string = "text"
        sweech.didStart = { utterance in
            sweech.speak() // Skipped
            XCTAssertTrue(sweech.speaking)

            sweech.pause()
        }
        sweech.willSpeack = { range, utterance in
            XCTAssertEqual(range.location, 0)
            XCTAssertEqual(range.length, 4)
        }
        sweech.didPause = { _ in
            XCTAssertTrue(sweech.paused)
            
            sweech.resume()
        }
        sweech.didResume = { _ in
            XCTAssertFalse(sweech.paused)
            
            sweech.stop()
        }
        sweech.didCancel = { _ in
            XCTAssertFalse(sweech.speaking)
            
            expectation.fulfill()
        }
        sweech.speak()
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testUserDefaults() {
        let sweech = Sweech.instance
        
        XCTAssertEqual(sweech.language, "en-US")
        XCTAssertEqual(sweech.rate, SweechFloatConfigration.rate.defaultValue)
        XCTAssertEqual(sweech.pitchMultiplier, SweechFloatConfigration.pitchMultiplier.defaultValue)
        XCTAssertEqual(sweech.volume, SweechFloatConfigration.volume.defaultValue)
        XCTAssertEqual(sweech.muted, false)
    }
    
    func testIncrement() {
        let sweech = Sweech.instance
        
        sweech.decrement(.rate)
        XCTAssertEqual(sweech.rate, SweechFloatConfigration.rate.defaultValue - SweechFloatConfigration.step)
        XCTAssertTrue(sweech.incrementable(.rate))

        sweech.increment(.rate)
        XCTAssertEqual(sweech.rate, SweechFloatConfigration.rate.defaultValue)
        XCTAssertTrue(sweech.decrementable(.rate))
        
        
        sweech.decrement(.pitchMultiplier)
        XCTAssertEqual(sweech.pitchMultiplier, SweechFloatConfigration.pitchMultiplier.defaultValue - SweechFloatConfigration.step)
        XCTAssertTrue(sweech.incrementable(.pitchMultiplier))

        sweech.increment(.pitchMultiplier)
        XCTAssertEqual(sweech.pitchMultiplier, SweechFloatConfigration.pitchMultiplier.defaultValue)
        XCTAssertTrue(sweech.decrementable(.pitchMultiplier))

        
        sweech.decrement(.volume)
        XCTAssertEqual(sweech.volume, SweechFloatConfigration.volume.defaultValue - SweechFloatConfigration.step)
        XCTAssertTrue(sweech.incrementable(.volume))

        sweech.increment(.volume)
        XCTAssertEqual(sweech.volume, SweechFloatConfigration.volume.defaultValue)
        XCTAssertTrue(sweech.decrementable(.volume))
    }

    func testMute() {
        let sweech = Sweech.instance
        
        sweech.muted = true
        XCTAssertEqual(sweech.volume, 0.0)
        XCTAssertTrue(sweech.muted)
    }
    
    func testLanguage() {
        let sweech = Sweech.instance
        
        sweech.language = sweech.languages.first!
        XCTAssertEqual(sweech.voice?.language, sweech.languages.first)
    }
}
