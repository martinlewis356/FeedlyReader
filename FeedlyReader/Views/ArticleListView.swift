struct ArticleListView: View {
    @EnvironmentObject var feedly: FeedlyService
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Group {
            if feedly.errorMessage != nil {
                ErrorView(error: feedly.errorMessage ?? "未知错误") {
                    feedly.fetchArticles()
                }
            } else if feedly.articles.isEmpty {
                ProgressView("正在加载最新文章...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(feedly.articles) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(article.title)
                                .font(.headline)
                                .lineLimit(2)
                            
                            HStack {
                                Text(article.originTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let date = article.publishedDate {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .refreshable {
                    feedly.fetchArticles()
                }
            }
        }
    }
}

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("加载失败")
                .font(.title)
            Text(error)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("重试", action: retryAction)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}
