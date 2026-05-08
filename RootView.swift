import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                SearchContainerView()
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack {
                AboutView()
            }
            .tabItem { Label("PriceFoxy", systemImage: "tag.fill") }
        }
        .tint(PF.orange)
    }
}
