import AVFoundation
import Speech

/// Listens with on-device speech recognition and hands back one utterance (design §8.8). Never uses the server.
@MainActor @Observable final class SpeechCapture {
    nonisolated static let silenceThreshold: TimeInterval = 1.5

    private(set) var isListening = false
    private(set) var transcript = ""
    /// Permission statuses aren't observable, so this is refreshed on creation and after each permission request.
    private(set) var unavailableReason: String?

    @ObservationIgnored private let recognizer = SFSpeechRecognizer(locale: .current)
    @ObservationIgnored private let engine = AVAudioEngine()
    @ObservationIgnored private var request: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var task: SFSpeechRecognitionTask?
    @ObservationIgnored private var lastSpeechAt: Date?
    @ObservationIgnored private var silenceCheck: Task<Void, Never>?
    /// The permission requests before listening; cancel() must reach it, or the mic could start for a widget that's gone.
    @ObservationIgnored private var pendingStart: Task<Void, Never>?
    /// Tags recognition callbacks, so a late one from a stopped session can't touch the next.
    @ObservationIgnored private var session = 0

    init() {
        refreshAvailability()
    }

    /// A pause before anything is said never ends listening; only silence after speech does.
    static func shouldFinish(lastSpeechAt: Date?, now: Date, threshold: TimeInterval = silenceThreshold) -> Bool {
        guard let lastSpeechAt else { return false }
        return now.timeIntervalSince(lastSpeechAt) >= threshold
    }

    /// `nil` when voice capture can be used, including before permission has been asked.
    static func unavailableReason(
        microphone: AVAuthorizationStatus,
        speech: SFSpeechRecognizerAuthorizationStatus,
        recognizerAvailable: Bool,
        supportsOnDevice: Bool
    ) -> String? {
        if microphone == .denied || microphone == .restricted {
            return "Microphone access is off. Turn it on in System Settings › Privacy & Security › Microphone."
        }
        if speech == .denied || speech == .restricted {
            return "Speech recognition is off. Turn it on in System Settings › Privacy & Security › Speech Recognition."
        }
        if !recognizerAvailable || !supportsOnDevice {
            return "On-device speech recognition isn't available for your language."
        }
        return nil
    }

    func start(onFinish: @escaping (String) -> Void) {
        guard !isListening, pendingStart == nil else { return }
        pendingStart = Task {
            if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
                _ = await AVCaptureDevice.requestAccess(for: .audio)
            }
            if SFSpeechRecognizer.authorizationStatus() == .notDetermined {
                await withCheckedContinuation { done in SFSpeechRecognizer.requestAuthorization { _ in done.resume() } }
            }
            refreshAvailability()
            // A cancelled start leaves pendingStart alone: cancel() cleared it, and a newer start may own it now.
            guard !Task.isCancelled else { return }
            pendingStart = nil
            guard unavailableReason == nil,
                  AVCaptureDevice.authorizationStatus(for: .audio) == .authorized,
                  SFSpeechRecognizer.authorizationStatus() == .authorized
            else { return }
            begin(onFinish: onFinish)
        }
    }

    /// Stops listening, or a start still waiting on permission, and drops the transcript without calling `onFinish`.
    func cancel() {
        pendingStart?.cancel()
        pendingStart = nil
        guard isListening else { return }
        isListening = false
        silenceCheck?.cancel()
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        silenceCheck = nil
        lastSpeechAt = nil
        transcript = ""
    }

    private func refreshAvailability() {
        unavailableReason = Self.unavailableReason(
            microphone: AVCaptureDevice.authorizationStatus(for: .audio),
            speech: SFSpeechRecognizer.authorizationStatus(),
            recognizerAvailable: recognizer?.isAvailable ?? false,
            supportsOnDevice: recognizer?.supportsOnDeviceRecognition ?? false
        )
    }

    private func begin(onFinish: @escaping (String) -> Void) {
        guard let recognizer else { return }
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        // With no audio input (a desktop Mac with no mic), the format is 0 Hz and installTap would raise, not throw.
        guard format.sampleRate > 0, format.channelCount > 0 else { return }
        input.installTap(onBus: 0, bufferSize: 1024, format: format, block: Self.tap(into: request))
        engine.prepare()
        do {
            try engine.start()
        } catch {
            input.removeTap(onBus: 0)
            return
        }
        self.request = request
        transcript = ""
        lastSpeechAt = nil
        isListening = true
        session += 1
        task = recognizer.recognitionTask(with: request, resultHandler: Self.resultHandler(for: self, session: session))
        silenceCheck = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                guard !Task.isCancelled, let self, self.isListening else { return }
                if Self.shouldFinish(lastSpeechAt: self.lastSpeechAt, now: .now) {
                    let text = self.transcript
                    self.cancel()
                    onFinish(text)
                    return
                }
            }
        }
    }

    private func heard(_ text: String?, failed: Bool, in session: Int) {
        guard isListening, session == self.session else { return }
        if let text, text != transcript {
            transcript = text
            lastSpeechAt = .now
        }
        if failed { cancel() }
    }

    // The tap and the result handler run on background threads, so they're built outside the main actor.
    nonisolated private static func tap(into request: SFSpeechAudioBufferRecognitionRequest) -> AVAudioNodeTapBlock {
        { buffer, _ in request.append(buffer) }
    }

    nonisolated private static func resultHandler(for capture: SpeechCapture, session: Int) -> (SFSpeechRecognitionResult?, Error?) -> Void {
        { [weak capture] result, error in
            let text = result?.bestTranscription.formattedString
            let failed = error != nil
            Task { @MainActor in capture?.heard(text, failed: failed, in: session) }
        }
    }
}
