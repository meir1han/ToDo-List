//
//  MockTaskListView.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import Foundation
@testable import ToDo_List

class MockTaskListView: TaskListViewProtocol {
    var didShowTasks = false
    var tasks: [Task] = []

    func showTasks(_ tasks: [Task]) {
        didShowTasks = true
        self.tasks = tasks
    }
}
