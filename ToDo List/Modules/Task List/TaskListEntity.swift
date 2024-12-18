//
//  TaskListEntity.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import Foundation

struct Task {
    let id: Int
    var title: String
    var description: String
    var createdDate: Date
    var isCompleted: Bool
}

struct TodoResponse: Codable {
    let todos: [Todo]
}

struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}

