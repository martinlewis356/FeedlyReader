struct MainTabView: View {
    @EnvironmentObject var feedly: FeedlyService
    
    var body: some View {
        TabView {
            NavigationView {
                ArticleListView()
                    .navigationTitle("最新文章")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if feedly.isLoading {
                                ProgressView()
                            }
                        }
                    }
            }
            .tabItem {
                Label("阅读", systemImage: "newspaper")
            }
            
            NavigationView {
                BookmarkView()
                    .navigationTitle("收藏的文章")
            }
            .tabItem {
                Label("收藏", systemImage: "bookmark")
            }
            
            NavigationView {
                SettingsView()
                    .navigationTitle("设置")
            }
            .tabItem {
                Label("设置", systemImage: "gear")
            }
        }
        .onAppear {
            feedly.fetchArticles()
        }
        .accentColor(.blue)
    }
}
