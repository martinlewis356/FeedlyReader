struct FeedlyArticle: Decodable, Identifiable {
    let id: String
    let title: String
    let content: Content?
    let origin: Origin?
    let published: Int?
    
    struct Content: Decodable {
        let content: String?
    }
    
    struct Origin: Decodable {
        let title: String?
    }
    
    // 计算属性获取纯文本内容
    var plainContent: String {
        content?.content?.strippingHTML ?? "无内容"
    }
    
    var originTitle: String {
        origin?.title ?? "未知来源"
    }
    
    var publishedDate: Date? {
        guard let published = published else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(published/1000))
    }
}
