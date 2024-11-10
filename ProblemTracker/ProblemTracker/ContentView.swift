import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
                .tag(0)

            AddProblemView()
                .tabItem {
                    Label("Добавить проблему", systemImage: "plus.circle.fill")
                }
                .tag(1)

            NewProblemsView()
                .tabItem {
                    Label("Новые проблемы", systemImage: "rectangle.fill")
                }
                .tag(2)

            MetadataView()
                .tabItem {
                    Label("Просмотр метаданных", systemImage: "doc.text.fill")
                }
                .tag(3)
        }
    }
}
