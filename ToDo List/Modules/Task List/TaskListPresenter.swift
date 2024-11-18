//
//  Presenter.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

protocol TaskListPresenterProtocol {
    func viewDidLoad()
    func numberOfTasks() -> Int
    func task(at index: Int) -> Task
}

class TaskListPresenter: TaskListPresenterProtocol, TaskListInteractorOutputProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol?
    var router: TaskListRouterProtocol?

    private var tasks: [Task] = []

    func viewDidLoad() {
        interactor?.fetchTasks()
    }

    func numberOfTasks() -> Int {
        return tasks.count
    }

    func task(at index: Int) -> Task {
        return tasks[index]
    }

    // Реализация метода протокола TaskListInteractorOutputProtocol
    func didFetchTasks(_ tasks: [Task]) {
        self.tasks = tasks
        view?.showTasks(tasks)
    }
}

