import SwiftUI

struct ContentView: View {
    @Binding var subjects: [Subject]
    @Binding var colorScheme: ColorScheme?

    var body: some View {
        TabView {
            AverageCalculatorView(subjects: $subjects)
                .tabItem { Label("average_tab", systemImage: "sum") }

            GradeListView(subjects: $subjects)
                .tabItem { Label("list_tab", systemImage: "list.bullet") }

            SettingsView(subjects: $subjects)
                .tabItem { Label("settings_tab", systemImage: "gear") }
        }
    }
}
