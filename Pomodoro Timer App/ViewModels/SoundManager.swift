//
//  SoundManager.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 2024.
//

import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    enum CompletionSound: String, CaseIterable {
        case chime = "Chime"
        case bell = "Bell"
        case ding = "Ding"
        case none = "None"

        var systemSoundID: SystemSoundID? {
            switch self {
            case .chime: return 1025
            case .bell: return 1013
            case .ding: return 1057
            case .none: return nil
            }
        }
    }

    func playCompletionSound(_ sound: CompletionSound) {
        guard let soundID = sound.systemSoundID else { return }
        AudioServicesPlaySystemSound(soundID)
    }

    func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
