import SwiftUI
import CoreData

@main
struct FeedlyReaderApp: App {
    @StateObject var persistence = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(FeedlyService.shared)
                .environmentObject(TranslationService.shared)
                .environmentObject(TTSService.shared)
        }
    }
}
