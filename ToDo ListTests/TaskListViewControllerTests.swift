//
//  TaskListViewControllerTests.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import Foundation
@testable import ToDo_List

class MockTaskListPresenter: TaskListPresenterProtocol {
    var didCallViewDidLoad = false
    var didCallNavigateToAddTask = false

    func viewDidLoad() {
        didCallViewDidLoad = true
    }

    func numberOfTasks() -> Int {
        return 0
    }

    func task(at index: Int) -> Task {
        return Task(id: 1, title: "Test Task", description: "This is a test task.", createdDate: Date(), isCompleted: false)
    }

    func navigateToAddTask() {
        didCallNavigateToAddTask = true
    }

    func updateOrAddTask(_ task: Task) {}

    func deleteTask(at index: Int) {}

    func navigateToEditTask(at index: Int) {}

    func filterTasks(with query: String) {}

    func toggleTaskCompletion(at index: Int) {}
}
