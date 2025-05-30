import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var translationService: TranslationService
    @EnvironmentObject var ttsService: TTSService
    
    @State private var selectedTheme = "自动"
    @State private var showLanguageOptions = false
    
    let themes = ["自动", "浅色", "深色"]
    
    var body: some View {
        Form {
            Section(header: Text("常规设置")) {
                Picker("主题", selection: $selectedTheme) {
                    ForEach(themes, id: \.self) {
                        Text($0)
                    }
                }
                
                Toggle("启用离线模式", isOn: .constant(false))
                    .disabled(true)
            }
            
            Section(header: Text("翻译设置")) {
                Picker("默认翻译引擎", selection: $translationService.$currentEngine) {
                    ForEach(TranslationService.Engine.allCases) { engine in
                        Text(engine.displayName).tag(engine)
                    }
                }
                
                if translationService.currentEngine == .googleML {
                    Button("管理翻译模型") {
                        showLanguageOptions.toggle()
                    }
                    .sheet(isPresented: $showLanguageOptions) {
                        TranslationLanguageView()
                    }
                }
            }
            
            Section(header: Text("朗读设置")) {
                Picker("默认语音", selection: $ttsService.$selectedVoiceIdentifier) {
                    Text("女声 - 晓晓").tag("zh-CN-XiaoxiaoNeural")
                    Text("男声 - 云扬").tag("zh-CN-YunyangNeural")
                }
                
                HStack {
                    Text("语速")
                    Spacer()
                    Slider(value: $ttsService.settings.rate, 
                           in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate,
                           step: 0.05) {
                    } minimumValueLabel: {
                        Image(systemName: "tortoise")
                    } maximumValueLabel: {
                        Image(systemName: "hare")
                    }
                    .frame(width: 180)
                }
                
                HStack {
                    Text("音高")
                    Spacer()
                    Slider(value: $ttsService.settings.pitch, in: 0.5...2.0, step: 0.1) {
                    } minimumValueLabel: {
                        Image(systemName: "waveform.path")
                    } maximumValueLabel: {
                        Image(systemName: "waveform.path.ecg")
                    }
                    .frame(width: 180)
                }
            }
            
            Section(header: Text("关于")) {
                HStack {
                    Text("版本")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.gray)
                }
                
                Link("帮助中心", destination: URL(string: "https://help.feedlyreader.com")!)
                Link("隐私政策", destination: URL(string: "https://feedlyreader.com/privacy")!)
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") {
                selectedTheme = savedTheme
            }
        }
        .onChange(of: selectedTheme) { newValue in
            UserDefaults.standard.set(newValue, forKey: "selectedTheme")
            // 实际应用中此处应触发主题变更
        }
    }
}

struct TranslationLanguageView: View {
    @EnvironmentObject var translationService: TranslationService
    @Environment(\.presentationMode) var presentationMode
    
    let languages = [
        ("中文", "zh"),
        ("英语", "en"),
        ("日语", "ja"),
        ("韩语", "ko"),
        ("法语", "fr"),
        ("西班牙语", "es")
    ]
    
    var body: some View {
        NavigationView {
            List(languages, id: \.1) { name, code in
                HStack {
                    Text(name)
                    Spacer()
                    if translationService.isLanguageDownloaded(code: code) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .onTapGesture {
                    if !translationService.isLanguageDownloaded(code: code) {
                        translationService.downloadLanguageModel(code: code)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("语言下载")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(TranslationService.shared)
                .environmentObject(TTSService.shared)
        }
    }
}
