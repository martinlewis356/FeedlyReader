import Foundation
import Combine

class FeedlyService: ObservableObject {
    static let shared = FeedlyService()
    
    private let DEVELOPER_TOKEN = "YOUR_FEEDLY_TOKEN"
    @Published var articles: [FeedlyArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    func fetchArticles(retryCount: Int = 0) {
        guard let url = URL(string: "https://cloud.feedly.com/v3/streams/contents?streamId=user/YOUR_USER_ID/category/global.all") else { return }
        
        isLoading = true
        errorMessage = nil
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(DEVELOPER_TOKEN)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: FeedlyResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    if retryCount < 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self?.fetchArticles(retryCount: retryCount + 1)
                        }
                    }
                }
            }, receiveValue: { [weak self] response in
                self?.articles = response.items
            })
            .store(in: &cancellables)
    }
    
    struct FeedlyResponse: Decodable {
        let items: [FeedlyArticle]
    }
    
    private var cancellables = Set<AnyCancellable>()
}
