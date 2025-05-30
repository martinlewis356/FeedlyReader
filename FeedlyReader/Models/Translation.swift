import Foundation
import MLKitTranslate

class TranslationService: ObservableObject {
    static let shared = TranslationService()
    
    enum Engine: String, CaseIterable, Identifiable {
        case system, apple, googleML, openAI
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .system: return "系统翻译"
            case .apple: return "Apple翻译"
            case .googleML: return "Google翻译"
            case .openAI: return "AI翻译"
            }
        }
    }
    
    @Published var currentEngine: Engine = .googleML
    var googleTranslator: Translator?
    var downloadedLanguages = Set<String>()
    
    private init() {
        loadDownloadedLanguages()
        setupDefaultTranslator()
    }
    
    private func setupDefaultTranslator() {
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: .chinese)
        googleTranslator = Translator.translator(options: options)
        
        // 检查默认语言是否已下载
        if !isLanguageDownloaded(code: "zh") {
            downloadLanguageModel(code: "zh")
        }
    }
    
    func translate(text: String) async -> String? {
        guard !text.isEmpty else { return "" }
        
        switch currentEngine {
        case .googleML:
            return await googleTranslate(text: text)
        case .openAI:
            return await openAITranslate(text: text)
        case .apple:
            return await appleTranslate(text: text)
        case .system:
            return await systemTranslate(text: text)
        }
    }
    
    private func googleTranslate(text: String) async -> String? {
        guard let translator = googleTranslator else { return nil }
        
        do {
            return try await translator.translate(text)
        } catch {
            print("Google翻译失败: \(error)")
            return nil
        }
    }
    
    private func openAITranslate(text: String) async -> String? {
        // 实际实现需要替换为真正的OpenAI API调用
        // 这里只返回模拟结果
        return "AI翻译结果: \(String(text.prefix(200)))..."
    }
    
    private func appleTranslate(text: String) async -> String? {
        // 实际实现需要调用Apple的翻译API
        return "Apple翻译结果: \(String(text.prefix(200)))..."
    }
    
    private func systemTranslate(text: String) async -> String? {
        // 实际实现需要调用系统翻译API
        return "系统翻译结果: \(String(text.prefix(200)))..."
    }
    
    // 语言管理方法
    func downloadLanguageModel(code: String) {
        let options = TranslatorOptions(
            sourceLanguage: .english,
            targetLanguage: TranslateLanguage(rawValue: code) ?? .chinese
        )
        
        let translator = Translator.translator(options: options)
        
        translator.downloadModelIfNeeded { [weak self] error in
            if let error = error {
                print("下载语言模型失败: \(error)")
            } else {
                print("语言模型下载成功: \(code)")
                self?.downloadedLanguages.insert(code)
                self?.saveDownloadedLanguages()
            }
        }
    }
    
    func isLanguageDownloaded(code: String) -> Bool {
        downloadedLanguages.contains(code)
    }
    
    private func saveDownloadedLanguages() {
        let array = Array(downloadedLanguages)
        UserDefaults.standard.set(array, forKey: "downloadedLanguages")
    }
    
    private func loadDownloadedLanguages() {
        if let languages = UserDefaults.standard.stringArray(forKey: "downloadedLanguages") {
            downloadedLanguages = Set(languages)
        }
    }
}

extension TranslateLanguage {
    static let chinese = TranslateLanguage(rawValue: "zh")
    static let english = TranslateLanguage(rawValue: "en")
}
