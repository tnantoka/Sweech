//
//  Sweech.swift
//  Sweech
//
//  Created by Tatsuya Tobioka on 6/11/16.
//  Copyright © 2016 tnantoka. All rights reserved.
//

import AVFoundation

public enum SweechFloatConfigration {
    case rate, pitchMultiplier, volume
    
    public var defaultValue: Float {
        switch self {
        case .rate:
            return AVSpeechUtteranceDefaultSpeechRate
        case .pitchMultiplier:
            return 1.0
        case .volume:
            return 1.0
        }
    }

    public var minimumValue: Float {
        switch self {
        case .rate:
            return AVSpeechUtteranceMinimumSpeechRate
        case .pitchMultiplier:
            return 0.5
        case .volume:
            return 0.0
        }
    }

    public var maximumValue: Float {
        switch self {
        case .rate:
            return AVSpeechUtteranceMaximumSpeechRate
        case .pitchMultiplier:
            return 2.0
        case .volume:
            return 1.0
        }
    }
    
    public static let step: Float = 0.1
}

open class Sweech: NSObject, AVSpeechSynthesizerDelegate {
    
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
    
    open var string: String = "" {
        didSet {
            if oldValue != string {
                utterance = AVSpeechUtterance(string: string)
            }
        }
    }
    open fileprivate(set) var utterance = AVSpeechUtterance()

    open var language: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.Language) ?? "en-US"
        }
        set {
            utterance.voice = voice
            
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.Language)
            UserDefaults.standard.synchronize()
        }
    }
    open var voice: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: language)
    }
    
    open var rate: Float {
        get {
            return UserDefaults.standard.float(forKey: UserDefaultsKey.Rate)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.Rate)
            UserDefaults.standard.synchronize()

            utterance.rate = rate
        }
    }
    open var pitchMultiplier: Float {
        get {
            return UserDefaults.standard.float(forKey: UserDefaultsKey.PitchMultiplier)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.PitchMultiplier)
            UserDefaults.standard.synchronize()

            utterance.pitchMultiplier = pitchMultiplier
        }
    }
    open var volume: Float {
        get {
            return muted ? 0.0 : UserDefaults.standard.float(forKey: UserDefaultsKey.Volume)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.Volume)
            UserDefaults.standard.synchronize()

            utterance.volume = volume
        }
    }
    open var muted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.Muted)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.Muted)
            UserDefaults.standard.synchronize()

            utterance.volume = volume
        }
    }
    
    open var didStart: DidCallback?
    open var didFinish: DidCallback?
    open var didPause: DidCallback?
    open var didResume: DidCallback?
    open var didCancel: DidCallback?

    open var willSpeack: WillCallback?
    
    public static let instance : Sweech = {
        $0.initialize()
        return $0
    }(Sweech())

    func initialize(){
        let defaults = [
            UserDefaultsKey.Rate: SweechFloatConfigration.rate.defaultValue,
            UserDefaultsKey.PitchMultiplier: SweechFloatConfigration.pitchMultiplier.defaultValue,
            UserDefaultsKey.Volume: SweechFloatConfigration.volume.defaultValue,
        ]
        UserDefaults.standard.register(defaults: defaults)
    }
    
    fileprivate override init() {
        super.init()
        synthesizer.delegate = self
    }

    open func speak() {
        // An AVSpeechUtterance shall not be enqueued twice
        if speaking {
            return
        }
        
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = volume
        
        synthesizer.speak(utterance)
    }
    open var speaking: Bool {
        return synthesizer.isSpeaking
    }
    
    open func pause(_ immediate: Bool = true) {
        synthesizer.pauseSpeaking(at: immediate ? .immediate : .word)
    }
    open var paused: Bool {
        return synthesizer.isPaused
    }
    
    open func resume() {
        synthesizer.continueSpeaking()
    }
    
    open func stop(_ immediate: Bool = true) {
        synthesizer.stopSpeaking(at: immediate ? .immediate : .word)
    }
    
    open func reset() {
        string = ""
        utterance = AVSpeechUtterance()

        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.Language)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.Rate)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.PitchMultiplier)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.Volume)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.Muted)
        
        didStart = nil
        didFinish = nil
        didPause = nil
        didResume = nil
        didCancel = nil
        
        willSpeack = nil
    }

    open func decrement(_ configuration: SweechFloatConfigration) {
        switch configuration {
        case .rate:
            rate = max(rate - SweechFloatConfigration.step, SweechFloatConfigration.rate.minimumValue)
        case .pitchMultiplier:
            pitchMultiplier = max(pitchMultiplier - SweechFloatConfigration.step, SweechFloatConfigration.pitchMultiplier.minimumValue)
        case .volume:
            volume = max(volume - SweechFloatConfigration.step, SweechFloatConfigration.volume.minimumValue)
        }
    }
    open func decrementable(_ configuration: SweechFloatConfigration) -> Bool {
        switch configuration {
        case .rate:
            return rate > SweechFloatConfigration.rate.minimumValue
        case .pitchMultiplier:
            return pitchMultiplier > SweechFloatConfigration.pitchMultiplier.minimumValue
        case .volume:
            return volume > SweechFloatConfigration.volume.minimumValue
        }
    }

    open func increment(_ configuration: SweechFloatConfigration) {
        switch configuration {
        case .rate:
            rate = min(rate + SweechFloatConfigration.step, SweechFloatConfigration.rate.maximumValue)
        case .pitchMultiplier:
            pitchMultiplier = min(pitchMultiplier + SweechFloatConfigration.step, SweechFloatConfigration.pitchMultiplier.maximumValue)
        case .volume:
            volume = min(volume + SweechFloatConfigration.step, SweechFloatConfigration.volume.maximumValue)
        }
    }
    open func incrementable(_ configuration: SweechFloatConfigration) -> Bool {
        switch configuration {
        case .rate:
            return rate < SweechFloatConfigration.rate.maximumValue
        case .pitchMultiplier:
            return pitchMultiplier < SweechFloatConfigration.pitchMultiplier.maximumValue
        case .volume:
            return volume < SweechFloatConfigration.volume.maximumValue
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        if let didStart = didStart {
            didStart(utterance)
        }
    }
    
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let didFinish = didFinish {
            didFinish(utterance)
        }
    }
    
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        if let didPause = didPause {
            didPause(utterance)
        }
    }
    
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        if let didResume = didResume {
            didResume(utterance)
        }
    }
    
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        if let didCancel = didCancel {
            didCancel(utterance)
        }
    }
    
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if let willSpeack = willSpeack {
            willSpeack(characterRange, utterance)
        }
    }
    
    open var voices: [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
    
    open var languages: [String] {
        return voices.map { $0.language }
    }
}
