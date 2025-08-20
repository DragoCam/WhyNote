import SwiftUI

@main
struct WhyNoteApp: App {
    @State private var subjects: [Subject] = [ ]

    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @AppStorage("appLanguage") private var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "pl"

    var colorScheme: ColorScheme? {
        switch appColorScheme {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(subjects: $subjects, colorScheme: .constant(colorScheme))
                .preferredColorScheme(colorScheme)
                .environment(\.locale, .init(identifier: appLanguage))
        }
    }
}
