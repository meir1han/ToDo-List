//
//  AddTaskPresenter.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

protocol AddTaskPresenterProtocol {
    func addTask(title: String, description: String)
}

class AddTaskPresenter: AddTaskPresenterProtocol, AddTaskInteractorOutputProtocol {
    weak var view: AddTaskViewProtocol?
    var interactor: AddTaskInteractorInputProtocol?
    var router: AddTaskRouterProtocol?

    func addTask(title: String, description: String) {
        interactor?.saveTask(title: title, description: description)
    }

    func didSaveTask() {
        view?.dismissView()
    }
}
