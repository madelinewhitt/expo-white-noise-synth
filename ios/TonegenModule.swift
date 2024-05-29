import ExpoModulesCore
import AVFoundation

public class ToneGenerator {
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var buffer: AVAudioPCMBuffer?
    private var frameLength: AVAudioFrameCount = 0
    private var isPlaying: Bool = false

    public func getIsPlaying() -> Bool {
        return isPlaying
    }

    public func play(frequency: Double, amplitudes: [Double] = [1.0], adsr: ADSR? = nil) {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 11025.0, channels: 1),
        let buffer = createBuffer(frequency: frequency, amplitudes: amplitudes, format: format, adsr: adsr) else {
            fatalError("Unable to create AVAudioFormat or AVAudioPCMBuffer objects")
        }

        self.buffer = buffer

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)

        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)

        do {
            try audioEngine.start()
            playerNode.play()
            isPlaying = true
        } catch {
            fatalError("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }

    public func stop() {
        playerNode.stop()
        audioEngine.stop()
        isPlaying = false
    }

    public func setFrequency(frequency: Double, amplitudes: [Double] = [1.0], adsr: ADSR? = nil) {
        guard let format = buffer?.format,
        let buffer = createBuffer(frequency: frequency, amplitudes: amplitudes, format: format, adsr: adsr) else {
            fatalError("Unable to create AVAudioPCMBuffer object")
        }

        self.buffer = buffer
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        playerNode.play()
    }

    private func createBuffer(frequency: Double, amplitudes: [Double], format: AVAudioFormat, adsr: ADSR? = nil) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        frameLength = AVAudioFrameCount(sampleRate / frequency)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameLength) else {
            return nil
        }

        guard let floatChannelData = buffer.floatChannelData else {
            return nil
        }

        for frame in 0..<Int(frameLength) {
            let time = Double(frame) / sampleRate
            var sampleValue: Float32 = 0.0

            for (index, amplitude) in amplitudes.enumerated() {
                let harmonicFrequency = frequency * Double(index + 1)
                sampleValue += Float32(amplitude * sin(2.0 * Double.pi * harmonicFrequency * time))
            }

            floatChannelData[0][frame] = sampleValue
        }

        normalize(buffer: buffer)

        if let adsr = adsr {
            applyADSR(buffer: buffer, adsr: adsr)
        }

        buffer.frameLength = frameLength

        return buffer
    }

    private func normalize(buffer: AVAudioPCMBuffer) {
        guard let floatChannelData = buffer.floatChannelData else {
            return
        }

        let frameLength = Int(buffer.frameLength)
        var maxAmplitude: Float32 = 0.0

        for frame in 0..<frameLength {
            maxAmplitude = max(maxAmplitude, abs(floatChannelData[0][frame]))
        }

        if maxAmplitude > 0.0 {
            let normalizationFactor = 1.0 / maxAmplitude
            for frame in 0..<frameLength {
                floatChannelData[0][frame] *= normalizationFactor
            }
        }
    }

    private func applyADSR(buffer: AVAudioPCMBuffer, adsr: ADSR) {
        guard let floatChannelData = buffer.floatChannelData else {
            return
        }

        let sampleRate = buffer.format.sampleRate
        let frameLength = Int(buffer.frameLength)
        let totalDuration = Double(frameLength) / sampleRate

        let attackEnd = Int(adsr.attack * sampleRate)
        let decayEnd = attackEnd + Int(adsr.decay * sampleRate)
        let releaseStart = frameLength - Int(adsr.release * sampleRate)

        for frame in 0..<frameLength {
            let time = Double(frame) / sampleRate
            var amplitude: Float32 = 1.0

            if frame < attackEnd {
                amplitude = Float32(time / adsr.attack)
            } else if frame < decayEnd {
                amplitude = Float32(1.0 - ((time - adsr.attack) / adsr.decay) * (1.0 - adsr.sustain))
            } else if frame < releaseStart {
                amplitude = Float32(adsr.sustain)
            } else {
                amplitude = Float32(adsr.sustain * (1.0 - (time - (totalDuration - adsr.release)) / adsr.release))
            }

            floatChannelData[0][frame] *= amplitude
        }
    }
}

public struct ADSR {
    var attack: Double
    var decay: Double
    var sustain: Double
    var release: Double

    public init(attack: Double, decay: Double, sustain: Double, release: Double) {
        self.attack = attack
        self.decay = decay
        self.sustain = sustain
        self.release = release
    }
}

public class ToneGeneratorModule: Module {
    public func definition() -> ModuleDefinition {
        Name("ToneGenerator")

        let toneGenerator = ToneGenerator()

        Function("getIsPlaying") { () in
            return toneGenerator.getIsPlaying()
        }

        AsyncFunction("play") { (frequency: Double, amplitudes: [Double], adsr: [Double]) in
            let adsrEnvelope = ADSR(attack: adsr[0], decay: adsr[1], sustain: adsr[2], release: adsr[3])
            toneGenerator.play(frequency: frequency, amplitudes: amplitudes, adsr: adsrEnvelope)
        }

        AsyncFunction("stop") { () in
            toneGenerator.stop()
        }

        AsyncFunction("setFrequency") { (frequency: Double, amplitudes: [Double], adsr: [Double]) in
            let adsrEnvelope = ADSR(attack: adsr[0], decay: adsr[1], sustain: adsr[2], release: adsr[3])
            toneGenerator.setFrequency(frequency: frequency, amplitudes: amplitudes, adsr: adsrEnvelope)
        }
    }
}

