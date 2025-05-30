struct BookmarkView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var ttsService: TTSService
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedArticle.timestamp, ascending: false)],
        animation: .default)
    private var bookmarks: FetchedResults<SavedArticle>
    
    var body: some View {
        Group {
            if bookmarks.isEmpty {
                VStack {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 60))
                        .opacity(0.3)
                    Text("暂无收藏")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(bookmarks) { bookmark in
                        NavigationLink(destination: BookmarkDetailView(bookmark: bookmark)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bookmark.title ?? "无标题")
                                    .font(.headline)
                                    .lineLimit(2)
                                
                                if let origin = bookmark.origin {
                                    Text(origin)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let timestamp = bookmark.timestamp {
                                    Text(timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteBookmarks)
                }
            }
        }
        .navigationTitle("收藏文章(\(bookmarks.count))")
    }
    
    private func deleteBookmarks(offsets: IndexSet) {
        withAnimation {
            offsets.map { bookmarks[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("删除收藏失败: \(error)")
            }
        }
    }
}

struct BookmarkDetailView: View {
    let bookmark: SavedArticle
    @EnvironmentObject var ttsService: TTSService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(bookmark.title ?? "无标题")
                    .font(.title)
                    .padding(.bottom, 8)
                
                if let origin = bookmark.origin {
                    Text("来源: \(origin)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let timestamp = bookmark.timestamp {
                    Text(timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                Group {
                    Text("原文")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(bookmark.content ?? "")
                }
                .padding(.bottom, 12)
                
                Divider()
                
                Group {
                    Text("译文(\(TranslationService.Engine(rawValue: bookmark.translationEngine ?? "")?.displayName ?? "未知来源"))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(bookmark.translatedContent ?? "")
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                TTSControls(textToRead: fullTextToRead)
            }
        }
    }
    
    private var fullTextToRead: String {
        var text = bookmark.title ?? "无标题"
        if let content = bookmark.content {
            text += "\n\n\(content)"
        }
        return text
    }
}
