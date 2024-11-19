//
//  TaskListPresenter.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import Foundation

protocol TaskListPresenterProtocol {
    func viewDidLoad()
    func numberOfTasks() -> Int
    func task(at index: Int) -> Task
    func navigateToAddTask()
    func updateOrAddTask(_ task: Task)
    func deleteTask(at index: Int)
    func navigateToEditTask(at index: Int)
    func filterTasks(with query: String)
    func toggleTaskCompletion(at index: Int)
}

class TaskListPresenter: TaskListPresenterProtocol, TaskListInteractorOutputProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol?
    var router: TaskListRouterProtocol?

    private var tasks: [Task] = []

    func viewDidLoad() {
        interactor?.loadTasksFromCoreData { [weak self] tasks in
            guard let self = self else { return }
            if tasks.isEmpty {
                self.interactor?.fetchTasks()
            } else {
                DispatchQueue.main.async {
                    self.didFetchTasks(tasks)
                }
            }
        }
    }

    func numberOfTasks() -> Int {
        return tasks.count
    }

    func task(at index: Int) -> Task {
        return tasks[index]
    }

    func didFetchTasks(_ tasks: [Task]) {
        self.tasks = tasks
        DispatchQueue.main.async {
            self.view?.showTasks(tasks)
        }
    }

    func didFailWithError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        // Optionally inform the view about the error.
    }

    func navigateToAddTask() {
        router?.navigateToAddTask(from: view!)
    }

    func updateOrAddTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
        interactor?.saveTaskToCoreData(task: task)
        view?.showTasks(tasks)
    }

    func deleteTask(at index: Int) {
        guard index < tasks.count else { return }
        let task = tasks[index]
        tasks.remove(at: index)
        interactor?.deleteTaskFromCoreData(task: task) { success in
            if success {
                DispatchQueue.main.async {
                    self.view?.showTasks(self.tasks)
                }
            } else {
                print("Failed to delete task from Core Data.")
            }
        }
    }

    func navigateToEditTask(at index: Int) {
        guard index < tasks.count else { return }
        let task = tasks[index]
        router?.navigateToEditTask(from: view!, task: task)
    }

    func filterTasks(with query: String) {
        if query.isEmpty {
            view?.showTasks(tasks)
        } else {
            let filteredTasks = tasks.filter {
                $0.title.lowercased().contains(query.lowercased()) ||
                $0.description.lowercased().contains(query.lowercased())
            }
            view?.showTasks(filteredTasks)
        }
    }

    func toggleTaskCompletion(at index: Int) {
        guard index < tasks.count else { return }
        tasks[index].isCompleted.toggle()
        interactor?.saveTaskToCoreData(task: tasks[index])
        view?.showTasks(tasks)
    }
}
