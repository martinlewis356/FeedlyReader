import AVFoundation

class TTSService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = TTSService()
    
    @Published var isPlaying = false
    @Published var selectedVoiceIdentifier = "zh-CN-XiaoxiaoNeural"
    @Published var settings = TTSSettings()
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var playingTexts: [String] = []
    private var currentTextIndex = 0
    
    struct TTSSettings {
        var rate: Float = AVSpeechUtteranceDefaultSpeechRate
        var pitch: Float = 1.0
        var volume: Float = 1.0
    }
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    
    func playText(_ text: String, language: String = "zh-CN") {
        stop()
        
        // 分割长文本
        let segments = text.split(by: 200)
        playingTexts = segments
        currentTextIndex = 0
        
        if let firstSegment = playingTexts.first {
            speakSegment(firstSegment, language: language)
        }
    }
    
    private func speakSegment(_ text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        if let voice = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }
        
        utterance.rate = settings.rate
        utterance.pitchMultiplier = settings.pitch
        utterance.volume = settings.volume
        
        speechSynthesizer.speak(utterance)
        isPlaying = true
    }
    
    func stop() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isPlaying = false
        playingTexts.removeAll()
        currentTextIndex = 0
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        currentTextIndex += 1
        
        if currentTextIndex < playingTexts.count {
            speakSegment(playingTexts[currentTextIndex], language: "zh-CN")
        } else {
            isPlaying = false
            playingTexts.removeAll()
            currentTextIndex = 0
        }
    }
}
