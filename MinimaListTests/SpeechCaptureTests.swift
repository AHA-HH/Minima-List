import AVFoundation
import Foundation
import Speech
import Testing
@testable import MinimaList

// Only the static rules are tested: creating a SpeechCapture would touch the microphone.
@MainActor
struct SpeechCaptureTests {
    let spoke = Date(timeIntervalSinceReferenceDate: 0)

    @Test func pauseBeforeAnySpeechNeverFinishes() {
        #expect(!SpeechCapture.shouldFinish(lastSpeechAt: nil, now: spoke.addingTimeInterval(60)))
    }

    @Test func silenceAfterSpeechFinishesAtTheThreshold() {
        #expect(!SpeechCapture.shouldFinish(lastSpeechAt: spoke, now: spoke.addingTimeInterval(1.4)))
        #expect(SpeechCapture.shouldFinish(lastSpeechAt: spoke, now: spoke.addingTimeInterval(1.5)))
        #expect(SpeechCapture.shouldFinish(lastSpeechAt: spoke, now: spoke.addingTimeInterval(3)))
    }

    @Test func availableWhenAuthorizedOrNotYetAsked() {
        #expect(SpeechCapture.unavailableReason(microphone: .authorized, speech: .authorized, recognizerAvailable: true, supportsOnDevice: true) == nil)
        #expect(SpeechCapture.unavailableReason(microphone: .notDetermined, speech: .notDetermined, recognizerAvailable: true, supportsOnDevice: true) == nil)
    }

    @Test func explainsWhyItIsUnavailable() throws {
        let mic = try #require(SpeechCapture.unavailableReason(microphone: .denied, speech: .authorized, recognizerAvailable: true, supportsOnDevice: true))
        #expect(mic.contains("Microphone"))
        #expect(SpeechCapture.unavailableReason(microphone: .restricted, speech: .authorized, recognizerAvailable: true, supportsOnDevice: true) == mic)

        let speech = try #require(SpeechCapture.unavailableReason(microphone: .authorized, speech: .denied, recognizerAvailable: true, supportsOnDevice: true))
        #expect(speech.contains("Speech recognition"))

        let language = try #require(SpeechCapture.unavailableReason(microphone: .authorized, speech: .authorized, recognizerAvailable: true, supportsOnDevice: false))
        #expect(language.contains("On-device"))
        #expect(SpeechCapture.unavailableReason(microphone: .authorized, speech: .authorized, recognizerAvailable: false, supportsOnDevice: true) == language)
    }

    @Test func microphoneReasonWinsWhenBothAreDenied() {
        let both = SpeechCapture.unavailableReason(microphone: .denied, speech: .denied, recognizerAvailable: true, supportsOnDevice: true)
        #expect(both?.contains("Microphone") == true)
    }
}
