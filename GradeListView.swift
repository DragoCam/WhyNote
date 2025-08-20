import SwiftUI

struct GradeListView: View {
    @Binding var subjects: [Subject]
    
    @State private var selectedSubjectIndex = 0
    @State private var newGradeText = ""
    @State private var newGradeDescription = ""
    @State private var selectedWeight = 1
    @State private var expandedSubjects: Set<UUID> = []
    
    let weights = [1,2,3,4,5]
    
    private func validateGradeInput(_ input: String) -> String {
        let prefix = input.prefix(3)
        let filtered = prefix.filter { "0123456789.".contains($0) }
        return String(filtered)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Dodawanie oceny tylko jeśli jest choć jeden przedmiot
                if !subjects.isEmpty {
                    Section(header: Text("add_grade_section")) {
                        Picker("subjects_section", selection: $selectedSubjectIndex) {
                            ForEach(subjects.indices, id: \.self) { index in
                                Text(subjects[index].name)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        HStack {
                            TextField("enter_grade", text: Binding(
                                get: { newGradeText },
                                set: { newValue in newGradeText = validateGradeInput(newValue) }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            
                            Picker("weight", selection: $selectedWeight) {
                                ForEach(weights, id: \.self) { weight in
                                    Text("\(weight)").tag(weight)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        TextField("grade_description_placeholder", text: $newGradeDescription)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("add_grade_button") {
                            if let gradeValue = Double(newGradeText), gradeValue <= 100 {
                                let newGrade = WeightedGrade(
                                    value: gradeValue,
                                    weight: Double(selectedWeight),
                                    description: newGradeDescription
                                )
                                subjects[selectedSubjectIndex].grades.append(newGrade)
                                newGradeText = ""
                                newGradeDescription = ""
                                selectedWeight = 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newGradeText.isEmpty)
                    }
                } else {
                    Section(header: Text("add_grade_section")) {
                        Text("first_message")
                            .foregroundColor(.gray)
                    }
                }
                
                // Lista przedmiotów
                Section(header: Text("subjects_section")) {
                    if subjects.isEmpty {
                        Text("first_message")
                            .foregroundColor(.gray)
                    } else {
                        ForEach($subjects, id: \.id) { $subject in
                            SubjectRowView(
                                subject: $subject,
                                isExpanded: expandedSubjects.contains(subject.id),
                                toggleExpanded: {
                                    if subject.grades.count > 2 {
                                        withAnimation {
                                            if expandedSubjects.contains(subject.id) {
                                                expandedSubjects.remove(subject.id)
                                            } else {
                                                expandedSubjects.insert(subject.id)
                                            }
                                        }
                                    }
                                },
                                formatGradeValue: formatGradeValue(_:),
                                calculateAverage: calculateAverage(for:)
                            )
                        }
                        .onDelete { offsets in
                            subjects.remove(atOffsets: offsets)
                            // Przy usuwaniu przestaw focus na pierwszy dostępny
                            if !subjects.isEmpty {
                                selectedSubjectIndex = min(selectedSubjectIndex, subjects.count-1)
                            } else {
                                selectedSubjectIndex = 0
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("big_subjects_section"))
            .listStyle(.insetGrouped)
            .toolbar {
                EditButton()
            }
        }
    }
    
    func formatGradeValue(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        } else {
            let formatted = String(format: "%.1f", value)
            return formatted.replacingOccurrences(of: ",", with: ".")
        }
    }
    
    func calculateAverage(for subject: Subject) -> Double {
        guard !subject.grades.isEmpty else { return 0.0 }
        let total = subject.grades.reduce(0.0) { $0 + $1.value * $1.weight }
        let sumWeights = subject.grades.reduce(0.0) { $0 + $1.weight }
        return sumWeights == 0 ? 0.0 : total / sumWeights
    }
}

private struct SubjectRowView: View {
    @Binding var subject: Subject
    let isExpanded: Bool
    let toggleExpanded: () -> Void
    let formatGradeValue: (Double) -> String
    let calculateAverage: (Subject) -> Double
    
    var gradesCount: Int { subject.grades.count }
    var gradesToShow: [WeightedGrade] {
        gradesCount > 2 ? Array(subject.grades.suffix(2)) : subject.grades
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(subject.name)
                    .font(.headline)
                    .frame(width: 100, alignment: .leading)
                
                Spacer(minLength: 8)
                
                HStack(spacing: 4) {
                    ForEach(gradesToShow) { grade in
                        Text(formatGradeValue(grade.value))
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                    if gradesCount > 2 {
                        Text("more_grades_indicator")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
                .frame(minWidth: 55, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                
                Spacer(minLength: 8)
                
                let averageStr = String(format: "%.2f", calculateAverage(subject))
                Text("subject_average \(averageStr)")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 100, alignment: .trailing)
            }
            .padding(.vertical, 7)
            .contentShape(Rectangle())
            .onTapGesture { toggleExpanded() }
            
            if isExpanded && gradesCount > 2 {
                VStack(spacing: 6) {
                    ForEach(subject.grades) { grade in
                        HStack(alignment: .center, spacing: 10) {
                            Text(formatGradeValue(grade.value))
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(6)
                            
                            if !grade.description.isEmpty {
                                Text(grade.description)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            } else {
                                Spacer(minLength: 0)
                            }
                            
                            Spacer()
                            
                            Text("\(Int(grade.weight))")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.vertical, 4)
                .transition(.opacity)
            }
        }
    }
}
