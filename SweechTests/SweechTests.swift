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
        self.measureBlock {
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
        let expectation = expectationWithDescription("")
        
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

        waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testPause() {
        let expectation = expectationWithDescription("")
        
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
        
        waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testUserDefaults() {
        let sweech = Sweech.instance
        
        XCTAssertEqual(sweech.language, "en-US")
        XCTAssertEqual(sweech.rate, SweechFloatConfigration.Rate.defaultValue)
        XCTAssertEqual(sweech.pitchMultiplier, SweechFloatConfigration.PitchMultiplier.defaultValue)
        XCTAssertEqual(sweech.volume, SweechFloatConfigration.Volume.defaultValue)
        XCTAssertEqual(sweech.muted, false)
    }
    
    func testIncrement() {
        let sweech = Sweech.instance
        
        sweech.decrement(.Rate)
        XCTAssertEqual(sweech.rate, SweechFloatConfigration.Rate.defaultValue - SweechFloatConfigration.step)
        XCTAssertTrue(sweech.incrementable(.Rate))

        sweech.increment(.Rate)
        XCTAssertEqual(sweech.rate, SweechFloatConfigration.Rate.defaultValue)
        XCTAssertTrue(sweech.decrementable(.Rate))
        
        
        sweech.decrement(.PitchMultiplier)
        XCTAssertEqual(sweech.pitchMultiplier, SweechFloatConfigration.PitchMultiplier.defaultValue - SweechFloatConfigration.step)
        XCTAssertTrue(sweech.incrementable(.PitchMultiplier))

        sweech.increment(.PitchMultiplier)
        XCTAssertEqual(sweech.pitchMultiplier, SweechFloatConfigration.PitchMultiplier.defaultValue)
        XCTAssertTrue(sweech.decrementable(.PitchMultiplier))

        
        sweech.decrement(.Volume)
        XCTAssertEqual(sweech.volume, SweechFloatConfigration.Volume.defaultValue - SweechFloatConfigration.step)
        XCTAssertTrue(sweech.incrementable(.Volume))

        sweech.increment(.Volume)
        XCTAssertEqual(sweech.volume, SweechFloatConfigration.Volume.defaultValue)
        XCTAssertTrue(sweech.decrementable(.Volume))
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
