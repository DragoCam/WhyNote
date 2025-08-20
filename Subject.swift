//
//  Subject.swift
//  Why Note
//
//  Created by Klaudiusz Wojtyczka on 20/08/2025.
//

import Foundation

struct Subject: Identifiable, Codable {
    let id = UUID()
    var name: String
    var grades: [WeightedGrade] = []
}
