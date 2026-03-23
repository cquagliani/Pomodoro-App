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
        case radar = "Radar"
        case apex = "Apex"
        case beacon = "Beacon"
        case bulletin = "Bulletin"
        case bamboo = "Bamboo"
        case chord = "Chord"
        case circles = "Circles"
        case complete = "Complete"
        case hello = "Hello"
        case input = "Input"
        case keys = "Keys"
        case note = "Note"
        case popcorn = "Popcorn"
        case pulse = "Pulse"
        case synth = "Synth"
        case alert = "Alert"
        case anticipate = "Anticipate"
        case bloom = "Bloom"
        case calypso = "Calypso"
        case choo = "Choo Choo"
        case descent = "Descent"
        case fanfare = "Fanfare"
        case ladder = "Ladder"
        case minuet = "Minuet"
        case newsFlash = "News Flash"
        case sherwood = "Sherwood Forest"
        case spell = "Spell"
        case suspense = "Suspense"
        case telegraph = "Telegraph"
        case tiptoes = "Tiptoes"
        case typewriters = "Typewriters"
        case update = "Update"
        case none = "None"

        var soundFileName: String? {
            switch self {
            case .chime: return nil    // uses system sound ID
            case .bell: return nil     // uses system sound ID
            case .ding: return nil     // uses system sound ID
            case .radar: return "radar"
            case .apex: return "apex"
            case .beacon: return "beacon"
            case .bulletin: return "bulletin"
            case .bamboo: return "bamboo"
            case .chord: return "chord"
            case .circles: return "circles"
            case .complete: return "complete"
            case .hello: return "hello"
            case .input: return "input"
            case .keys: return "keys"
            case .note: return "note"
            case .popcorn: return "popcorn"
            case .pulse: return "pulse"
            case .synth: return "synth"
            case .alert: return "alert"
            case .anticipate: return "anticipate"
            case .bloom: return "bloom"
            case .calypso: return "calypso"
            case .choo: return "choo-choo"
            case .descent: return "descent"
            case .fanfare: return "fanfare"
            case .ladder: return "ladder"
            case .minuet: return "minuet"
            case .newsFlash: return "news-flash"
            case .sherwood: return "sherwood-forest"
            case .spell: return "spell"
            case .suspense: return "suspense"
            case .telegraph: return "telegraph"
            case .tiptoes: return "tiptoes"
            case .typewriters: return "typewriters"
            case .update: return "update"
            case .none: return nil
            }
        }

        var systemSoundID: SystemSoundID? {
            switch self {
            case .chime: return 1025
            case .bell: return 1013
            case .ding: return 1057
            default: return nil
            }
        }
    }

    func playCompletionSound(_ sound: CompletionSound) {
        // Stop any currently playing sound
        audioPlayer?.stop()
        audioPlayer = nil

        // Try system sound ID first (for legacy chime/bell/ding)
        if let soundID = sound.systemSoundID {
            AudioServicesPlaySystemSound(soundID)
            return
        }

        // Try file-based sound from system UISounds directory
        guard let fileName = sound.soundFileName else { return }

        let searchPaths = [
            "/System/Library/Audio/UISounds/\(fileName).caf",
            "/System/Library/Audio/UISounds/New/\(fileName).caf",
            "/System/Library/Audio/UISounds/nano/\(fileName).caf",
            "/System/Library/Audio/UISounds/3rd_party/\(fileName).caf"
        ]

        for path in searchPaths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                    return
                } catch {
                    continue
                }
            }
        }

        // Fallback: try creating a system sound from the path
        if let url = CFURLCreateWithFileSystemPath(nil, "/System/Library/Audio/UISounds/\(fileName).caf" as CFString, .cfurlposixPathStyle, false) {
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url, &soundID)
            if soundID != 0 {
                AudioServicesPlaySystemSound(soundID)
                // Dispose after a delay to allow playback
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    AudioServicesDisposeSystemSoundID(soundID)
                }
            }
        }
    }

    func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
