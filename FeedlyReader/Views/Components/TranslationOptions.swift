struct TranslationOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var translationService: TranslationService
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("选择翻译引擎")) {
                    Picker("引擎", selection: $translationService.currentEngine) {
                        ForEach(TranslationService.Engine.allCases) { engine in
                            Text(engine.displayName).tag(engine)
                        }
                    }
                    .pickerStyle(.inline)
                    
                    if translationService.currentEngine == .googleML {
                        VStack(alignment: .leading) {
                            Text("需要下载翻译模型")
                            Button("下载模型") {
                                translationService.setupGoogleTranslator()
                            }
                        }
                    }
                }
                
                Section {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("翻译选项")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
