import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "pl"
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @Binding var subjects: [Subject]

    @State private var newSubjectName = ""
    @FocusState private var isSubjectNameFocused: Bool

    var body: some View {
        Form {
            Section(header: Text("language_section_header")) {
                Picker("choose_language", selection: $appLanguage) {
                    Text("polish").tag("pl")
                    Text("english").tag("en")
                }
                .pickerStyle(.menu)
            }
            Section(header: Text("appearance_section_header")) {
                Picker("appearance_mode", selection: $appColorScheme) {
                    Text("system_mode").tag("system")
                    Text("light_mode").tag("light")
                    Text("dark_mode").tag("dark")
                }
                .pickerStyle(.segmented)
            }
            // Dodawanie przedmiotów
            Section(header: Text("add_subject_section")) {
                HStack {
                    TextField("subject_name_placeholder", text: $newSubjectName)
                        .textFieldStyle(.roundedBorder)
                        .focused($isSubjectNameFocused)
                    Button(action: {
                        let trimmed = newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        subjects.append(Subject(name: trimmed))
                        newSubjectName = ""
                        isSubjectNameFocused = false
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel(Text("add_subject_button"))
                }
                ForEach(subjects) { subject in
                    Text(subject.name)
                }
                .onDelete { offsets in
                    subjects.remove(atOffsets: offsets)
                }
            }
        }
        .environment(\.locale, .init(identifier: appLanguage))
        .navigationTitle(Text("settings"))
        .toolbar {
            EditButton()
        }
    }
}
