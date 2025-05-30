struct TTSControls: View {
    @EnvironmentObject var ttsService: TTSService
    let textToRead: String
    
    var body: some View {
        HStack {
            Button {
                ttsService.isPlaying ? ttsService.stop() : playSpeech()
            } label: {
                Image(systemName: ttsService.isPlaying ? "stop.fill" : "play.fill")
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                    .background(ttsService.isPlaying ? Color.red : Color.blue)
                    .clipShape(Circle())
            }
            
            Slider(value: $ttsService.settings.rate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate, step: 0.05) {
                Text("语速")
            } minimumValueLabel: {
                Image(systemName: "tortoise")
            } maximumValueLabel: {
                Image(systemName: "hare")
            }
            .disabled(ttsService.isPlaying)
            
            Picker("语音", selection: $ttsService.selectedVoiceIdentifier) {
                Text("女声").tag("zh-CN-XiaoxiaoNeural")
                Text("男声").tag("zh-CN-YunyangNeural")
            }
            .pickerStyle(.menu)
            .disabled(ttsService.isPlaying)
        }
        .padding()
        .background(.thickMaterial)
    }
    
    private func playSpeech() {
        guard !textToRead.isEmpty else { return }
        ttsService.playText(textToRead)
    }
}
