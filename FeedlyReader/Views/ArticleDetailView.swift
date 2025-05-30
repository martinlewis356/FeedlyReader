struct ArticleDetailView: View {
    let article: FeedlyArticle
    @State private var readingMode: ReadingMode = .original
    @State private var translatedText: String?
    @State private var isTranslating = false
    @State private var showTranslationOptions = false
    @State private var isBookmarked = false
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var translationService: TranslationService
    @EnvironmentObject var ttsService: TTSService
    
    enum ReadingMode: String, CaseIterable {
        case original = "原文"
        case translated = "译文"
        case bilingual = "双语"
        
        var icon: String {
            switch self {
            case .original: return "doc.text"
            case .translated: return "character.book.closed"
            case .bilingual: return "book"
            }
        }
    }
    
    var body: some View {
        VStack {
            // 顶部控制栏
            HStack {
                Button {
                    showTranslationOptions.toggle()
                } label: {
                    HStack {
                        Image(systemName: "character.book.closed")
                        Text(translationService.currentEngine.displayName)
                    }
                    .padding(8)
                    .background(.thickMaterial)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Picker("阅读模式", selection: $readingMode) {
                    ForEach(ReadingMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize(horizontal: true, vertical: false)
                
                Spacer()
                
                Button {
                    toggleBookmark()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .blue : .primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(article.title)
                        .font(.title)
                        .padding(.bottom, 8)
                    
                    if let origin = article.origin?.title {
                        Text("来源: \(origin)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let date = article.publishedDate {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    contentDisplay
                        .padding(.top, 8)
                }
                .padding()
            }
            
            // TTS控制栏
            TTSControls(textToRead: textToRead)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: checkBookmarkStatus)
        .task(loadTranslationIfNeeded)
        .sheet(isPresented: $showTranslationOptions) {
            TranslationOptionsView()
        }
    }
    
    // MARK: - 子视图
    private var contentDisplay: some View {
        Group {
            if isTranslating {
                ProgressView("翻译中...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                switch readingMode {
                case .original:
                    Text(article.plainContent)
                        .multilineTextAlignment(.leading)
                case .translated:
                    Text(translatedText ?? "")
                        .multilineTextAlignment(.leading)
                case .bilingual:
                    VStack(alignment: .leading, spacing: 16) {
                        Text("原文")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(article.plainContent)
                            .padding(.bottom, 12)
                        
                        Divider()
                        
                        Text("译文(\(translationService.currentEngine.displayName))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(translatedText ?? "")
                    }
                }
            }
        }
    }
    
    // MARK: - 计算属性
    private var textToRead: String {
        switch readingMode {
        case .original:
            return article.plainContent
        case .translated, .bilingual:
            return translatedText ?? article.plainContent
        }
    }
    
    // MARK: - 方法
    private func toggleBookmark() {
        isBookmarked ? removeBookmark() : saveBookmark()
        isBookmarked.toggle()
    }
    
    private func checkBookmarkStatus() {
        let request: NSFetchRequest<SavedArticle> = SavedArticle.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", article.id)
        
        do {
            let results = try context.fetch(request)
            isBookmarked = !results.isEmpty
        } catch {
            print("获取收藏状态失败: \(error)")
        }
    }
    
    private func saveBookmark() {
        let newBookmark = SavedArticle(context: context)
        newBookmark.id = article.id
        newBookmark.title = article.title
        newBookmark.content = article.plainContent
        newBookmark.translatedContent = translatedText
        newBookmark.translationEngine = translationService.currentEngine.rawValue
        newBookmark.origin = article.origin?.title
        newBookmark.timestamp = Date()
        
        do {
            try context.save()
        } catch {
            print("保存收藏失败: \(error)")
        }
    }
    
    private func removeBookmark() {
        let request: NSFetchRequest<SavedArticle> = SavedArticle.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", article.id)
        
        do {
            let results = try context.fetch(request)
            if let existing = results.first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("移除收藏失败: \(error)")
        }
    }
    
    @Sendable private func loadTranslationIfNeeded() async {
        guard translatedText == nil else { return }
        
        isTranslating = true
        translatedText = await translationService.translate(text: article.plainContent)
        isTranslating = false
    }
}
