//
//  SpeechService.swift
//  Squat Counter
//
//  Created by sam hastings on 17/07/2023.
//

import Foundation
import AVKit

class SpeechService: NSObject {
    static let shared = SpeechService()
    
    // Create a speech synthesizer.
    //let synthesizer = AVSpeechSynthesizer()
    
    //MARK: - Speech methods
    func startSpeaking(text: String, synthesizer: AVSpeechSynthesizer)  {
        self.stopSpeaking(synthesizer: synthesizer)
        let utterance = AVSpeechUtterance(string: text)
        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-GB")


        // Assign the voice to the utterance.
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking(synthesizer: AVSpeechSynthesizer) {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
