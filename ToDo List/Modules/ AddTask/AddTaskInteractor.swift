//
//  Interactor.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import Foundation

protocol AddTaskInteractorInputProtocol {
    func saveTask(title: String, description: String)
}

protocol AddTaskInteractorOutputProtocol: AnyObject {
    func didSaveTask()
}

class AddTaskInteractor: AddTaskInteractorInputProtocol {
    weak var presenter: AddTaskInteractorOutputProtocol?

    func saveTask(title: String, description: String) {
        DispatchQueue.global(qos: .background).async {
            // Здесь логика сохранения задачи (например, через Core Data)
            let newTask = Task(
                id: Int.random(in: 1...1000),
                title: title,
                description: description,
                createdDate: Date(),
                isCompleted: false
            )
            // Симуляция сохранения
            DispatchQueue.main.async {
                self.presenter?.didSaveTask()
            }
        }
    }
}
