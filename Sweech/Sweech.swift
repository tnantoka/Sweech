//
//  Sweech.swift
//  Sweech
//
//  Created by Tatsuya Tobioka on 6/11/16.
//  Copyright © 2016 tnantoka. All rights reserved.
//

import AVFoundation

public enum SweechFloatConfigration {
    case Rate, PitchMultiplier, Volume
    
    public var defaultValue: Float {
        switch self {
        case .Rate:
            return AVSpeechUtteranceDefaultSpeechRate
        case .PitchMultiplier:
            return 1.0
        case .Volume:
            return 1.0
        }
    }

    public var minimumValue: Float {
        switch self {
        case .Rate:
            return AVSpeechUtteranceMinimumSpeechRate
        case .PitchMultiplier:
            return 0.5
        case .Volume:
            return 0.0
        }
    }

    public var maximumValue: Float {
        switch self {
        case .Rate:
            return AVSpeechUtteranceMaximumSpeechRate
        case .PitchMultiplier:
            return 2.0
        case .Volume:
            return 1.0
        }
    }
    
    public static let step: Float = 0.1
}

public class Sweech: NSObject, AVSpeechSynthesizerDelegate {
    
    public typealias DidCallback = (AVSpeechUtterance) -> Void
    public typealias WillCallback = (NSRange, AVSpeechUtterance) -> Void

    struct UserDefaultsKey {
        static let Language = "Sweech.UserDefaultsKey.Language"
        static let Rate = "Sweech.UserDefaultsKeyRate.Rate"
        static let PitchMultiplier = "Sweech.UserDefaultsKey.PitchMultiplier"
        static let Volume = "SweechUser.DefaultsKey.Volume"
        static let Muted = "SweechUser.DefaultsKey.Muted"
    }
    
    let synthesizer = AVSpeechSynthesizer()
    
    public var string: String = "" {
        didSet {
            if oldValue != string {
                utterance = AVSpeechUtterance(string: string)
            }
        }
    }
    public private(set) var utterance = AVSpeechUtterance()

    public var language: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKey.Language) ?? "en-US"
        }
        set {
            utterance.voice = voice
            
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: UserDefaultsKey.Language)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    public var voice: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: language)
    }
    
    public var rate: Float {
        get {
            return NSUserDefaults.standardUserDefaults().floatForKey(UserDefaultsKey.Rate)
        }
        set {
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey: UserDefaultsKey.Rate)
            NSUserDefaults.standardUserDefaults().synchronize()

            utterance.rate = rate
        }
    }
    public var pitchMultiplier: Float {
        get {
            return NSUserDefaults.standardUserDefaults().floatForKey(UserDefaultsKey.PitchMultiplier)
        }
        set {
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey: UserDefaultsKey.PitchMultiplier)
            NSUserDefaults.standardUserDefaults().synchronize()

            utterance.pitchMultiplier = pitchMultiplier
        }
    }
    public var volume: Float {
        get {
            return muted ? 0.0 : NSUserDefaults.standardUserDefaults().floatForKey(UserDefaultsKey.Volume)
        }
        set {
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey: UserDefaultsKey.Volume)
            NSUserDefaults.standardUserDefaults().synchronize()

            utterance.volume = volume
        }
    }
    public var muted: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.Muted)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.Muted)
            NSUserDefaults.standardUserDefaults().synchronize()

            utterance.volume = volume
        }
    }
    
    public var didStart: DidCallback?
    public var didFinish: DidCallback?
    public var didPause: DidCallback?
    public var didResume: DidCallback?
    public var didCancel: DidCallback?

    public var willSpeack: WillCallback?

    override public class func initialize() {
        let defaults = [
            UserDefaultsKey.Rate: SweechFloatConfigration.Rate.defaultValue,
            UserDefaultsKey.PitchMultiplier: SweechFloatConfigration.PitchMultiplier.defaultValue,
            UserDefaultsKey.Volume: SweechFloatConfigration.Volume.defaultValue,
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
    }
    
    public static let instance = Sweech()
    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    public func speak() {
        // An AVSpeechUtterance shall not be enqueued twice
        if speaking {
            return
        }
        
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = volume
        
        synthesizer.speakUtterance(utterance)
    }
    public var speaking: Bool {
        return synthesizer.speaking
    }
    
    public func pause(immediate: Bool = true) {
        synthesizer.pauseSpeakingAtBoundary(immediate ? .Immediate : .Word)
    }
    public var paused: Bool {
        return synthesizer.paused
    }
    
    public func resume() {
        synthesizer.continueSpeaking()
    }
    
    public func stop(immediate: Bool = true) {
        synthesizer.stopSpeakingAtBoundary(immediate ? .Immediate : .Word)
    }
    
    public func reset() {
        string = ""
        utterance = AVSpeechUtterance()

        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKey.Language)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKey.Rate)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKey.PitchMultiplier)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKey.Volume)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKey.Muted)
        
        didStart = nil
        didFinish = nil
        didPause = nil
        didResume = nil
        didCancel = nil
        
        willSpeack = nil
    }

    public func decrement(configuration: SweechFloatConfigration) {
        switch configuration {
        case .Rate:
            rate = max(rate - SweechFloatConfigration.step, SweechFloatConfigration.Rate.minimumValue)
        case .PitchMultiplier:
            pitchMultiplier = max(pitchMultiplier - SweechFloatConfigration.step, SweechFloatConfigration.PitchMultiplier.minimumValue)
        case .Volume:
            volume = max(volume - SweechFloatConfigration.step, SweechFloatConfigration.Volume.minimumValue)
        }
    }
    public func decrementable(configuration: SweechFloatConfigration) -> Bool {
        switch configuration {
        case .Rate:
            return rate > SweechFloatConfigration.Rate.minimumValue
        case .PitchMultiplier:
            return pitchMultiplier > SweechFloatConfigration.PitchMultiplier.minimumValue
        case .Volume:
            return volume > SweechFloatConfigration.Volume.minimumValue
        }
    }

    public func increment(configuration: SweechFloatConfigration) {
        switch configuration {
        case .Rate:
            rate = min(rate + SweechFloatConfigration.step, SweechFloatConfigration.Rate.maximumValue)
        case .PitchMultiplier:
            pitchMultiplier = min(pitchMultiplier + SweechFloatConfigration.step, SweechFloatConfigration.PitchMultiplier.maximumValue)
        case .Volume:
            volume = min(volume + SweechFloatConfigration.step, SweechFloatConfigration.Volume.maximumValue)
        }
    }
    public func incrementable(configuration: SweechFloatConfigration) -> Bool {
        switch configuration {
        case .Rate:
            return rate < SweechFloatConfigration.Rate.maximumValue
        case .PitchMultiplier:
            return pitchMultiplier < SweechFloatConfigration.PitchMultiplier.maximumValue
        case .Volume:
            return volume < SweechFloatConfigration.Volume.maximumValue
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
        if let didStart = didStart {
            didStart(utterance)
        }
    }
    
    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        if let didFinish = didFinish {
            didFinish(utterance)
        }
    }
    
    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didPauseSpeechUtterance utterance: AVSpeechUtterance) {
        if let didPause = didPause {
            didPause(utterance)
        }
    }
    
    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didContinueSpeechUtterance utterance: AVSpeechUtterance) {
        if let didResume = didResume {
            didResume(utterance)
        }
    }
    
    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didCancelSpeechUtterance utterance: AVSpeechUtterance) {
        if let didCancel = didCancel {
            didCancel(utterance)
        }
    }
    
    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if let willSpeack = willSpeack {
            willSpeack(characterRange, utterance)
        }
    }
    
    public var voices: [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
    
    public var languages: [String] {
        return voices.map { v in v.language }
    }
}
