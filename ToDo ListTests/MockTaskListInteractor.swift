//
//  MockTaskListInteractor.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import Foundation
@testable import ToDo_List

class MockTaskListInteractor: TaskListInteractorInputProtocol {
    var savedTask: Task?
    var deletedTask: Task?
    var didLoadTasks = false
    var didFetchTasks = false

    func loadTasksFromCoreData(completion: @escaping ([Task]) -> Void) {
        didLoadTasks = true
        completion([]) // Заглушка: возвращаем пустой массив задач.
    }

    func saveTaskToCoreData(task: Task) {
        savedTask = task
    }

    func deleteTaskFromCoreData(task: Task, completion: @escaping (Bool) -> Void) {
        deletedTask = task
        completion(true)
    }

    func fetchTasks() {
        didFetchTasks = true
    }
}
