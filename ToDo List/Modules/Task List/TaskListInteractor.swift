//
//  Interactor.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import Foundation

protocol TaskListInteractorInputProtocol {
    func fetchTasks()
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [Task])
}

class TaskListInteractor: TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol?

    func fetchTasks() {
        DispatchQueue.global(qos: .background).async {
            // Здесь можно загрузить данные из Core Data или API
            let dummyTasks = [
                Task(id: 1, title: "Do Homework", description: "Math and Physics", createdDate: Date(), isCompleted: false),
                Task(id: 2, title: "Grocery Shopping", description: "Buy vegetables and fruits", createdDate: Date(), isCompleted: true)
            ]
            DispatchQueue.main.async {
                self.presenter?.didFetchTasks(dummyTasks)
            }
        }
    }
}
