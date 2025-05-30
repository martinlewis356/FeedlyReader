import Foundation

struct Constants {
    // Feedly API 配置
    static let feedlyApiBaseUrl = "https://cloud.feedly.com/v3/"
    static let feedlyStreamEndpoint = "streams/contents"
    static let feedlyApiToken = "YOUR_FEEDLY_TOKEN_HERE" // 实际使用时替换为真实令牌
    
    // TTS 服务配置
    static let ttsApiUrl = "https://tts.xdcr.cloudns.ch/api/synthesis"
    static let ttsToken = "zongai"
    
    // 翻译服务配置
    static let googleTranslateApiKey = "YOUR_GOOGLE_TRANSLATE_KEY"
    static let openAIApiKey = "YOUR_OPENAI_KEY"
    
    // 其他常量
    static let maxCharacterCountForTranslation = 5000
    static let maxTTSTextLength = 1000
    static let animationDuration: Double = 0.25
    
    // 用户默认值键
    static let lastSelectedTranslationEngineKey = "lastSelectedTranslationEngine"
    static let lastSelectedVoiceKey = "lastSelectedVoice"
    
    // 本地化字符串
    struct Strings {
        static let translationInProgress = "翻译中..."
        static let ttsPlaying = "正在朗读"
        static let networkError = "网络连接错误"
        static let translationError = "翻译失败"
        static let bookmarkSaved = "文章已收藏"
        static let bookmarkRemoved = "移除收藏"
        static let noBookmarks = "没有收藏的文章"
    }
    
    // 颜色
    struct Colors {
        static let primary = "AccentColor"
        static let secondary = "SecondaryColor"
        static let background = "BackgroundColor"
    }
}
