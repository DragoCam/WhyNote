import SwiftUI

struct AverageCalculatorView: View {
    @Binding var subjects: [Subject]
    @State private var selectedSubjectIndex = 0
    @State private var newGradeText = ""
    @State private var selectedWeight = 1
    let weights = [1,2,3,4,5]
    
    var average: Double {
        guard !subjects.isEmpty else { return 0.0 }
        let grades = subjects[selectedSubjectIndex].grades
        guard !grades.isEmpty else { return 0.0 }
        let total = grades.reduce(0.0) { $0 + $1.value * $1.weight }
        let sumWeights = grades.reduce(0.0) { $0 + $1.weight }
        return sumWeights == 0 ? 0.0 : total / sumWeights
    }
    
    func formatGradeValue(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        } else {
            let formatted = String(format: "%.1f", value)
            return formatted.replacingOccurrences(of: ",", with: ".")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // KALKULATOR ŚREDNIEJ
                Section(header: Text("small_average_calc_nav_title")) {
                    if subjects.isEmpty {
                        Text("first_message").foregroundColor(.gray)
                    } else {
                        Picker("subjects_section", selection: $selectedSubjectIndex) {
                            ForEach(subjects.indices, id: \.self) { index in
                                Text(subjects[index].name)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: subjects.count) { oldCount, newCount in
                            if selectedSubjectIndex >= newCount {
                                selectedSubjectIndex = max(0, newCount - 1)
                            }
                        }
                        
                        HStack {
                            TextField("enter_grade", text: $newGradeText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: newGradeText) { _, newValue in
                                    // Pozwól tylko na cyfry i jedną kropkę, max 5 znaków
                                    var filtered = newValue.filter { "0123456789.".contains($0) }
                                    if let _ = filtered.firstIndex(of: ".") {
                                        var result: [Character] = []
                                        var dotFound = false
                                        for c in filtered {
                                            if c == "." {
                                                if !dotFound {
                                                    dotFound = true
                                                    result.append(c)
                                                }
                                            } else {
                                                result.append(c)
                                            }
                                        }
                                        filtered = String(result)
                                    }
                                    newGradeText = String(filtered.prefix(5))
                                }
                            
                            Picker("weight", selection: $selectedWeight) {
                                ForEach(weights, id: \.self) { weight in
                                    Text("\(weight)").tag(weight)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack {
                            Button("add_button") {
                                if let gradeValue = Double(newGradeText), gradeValue <= 100 {
                                    let newGrade = WeightedGrade(
                                        value: gradeValue,
                                        weight: Double(selectedWeight)
                                    )
                                    subjects[selectedSubjectIndex].grades.append(newGrade)
                                    newGradeText = ""
                                    selectedWeight = 1
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newGradeText.isEmpty || Double(newGradeText) == nil)
                            
                            Spacer()
                            
                            Text("average") + Text(": \(average, specifier: "%.2f")")
                                .foregroundColor(.blue)
                        }
                    }
                }
                // LISTA OCEN - osobna sekcja
                Section(header: Text("grades_section")) {
                    if subjects.isEmpty {
                        Text("first_message").foregroundColor(.gray)
                    } else {
                        let subject = subjects[selectedSubjectIndex]
                        ForEach(subject.grades) { grade in
                            HStack(alignment: .center, spacing: 10) {
                                Text(formatGradeValue(grade.value))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                                
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
                        .onDelete { indices in
                            subjects[selectedSubjectIndex].grades.remove(atOffsets: indices)
                        }
                    }
                }
            }
            .navigationTitle(Text("average_calc_nav_title"))
        }
    }
}
