//
//  Entity.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import Foundation

struct Task {
    let id: Int
    let title: String
    let description: String
    let createdDate: Date
    var isCompleted: Bool
}
