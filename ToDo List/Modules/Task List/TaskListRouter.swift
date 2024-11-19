//
//  TaskListRouter.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import UIKit


protocol TaskListRouterProtocol {
    static func createTaskListModule() -> UIViewController
    func navigateToAddTask(from view: TaskListViewProtocol)
    func navigateToEditTask(from view: TaskListViewProtocol, task: Task)

}

class TaskListRouter: TaskListRouterProtocol {
    static func createTaskListModule() -> UIViewController {
        let view = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
    
    func navigateToAddTask(from view: TaskListViewProtocol) {
        guard let viewController = view as? TaskListViewController else { return }
        let addTaskModule = AddTaskRouter.createAddTaskModule()

        if let addTaskVC = addTaskModule as? AddTaskViewController {
            addTaskVC.delegate = viewController
        }

        viewController.navigationController?.pushViewController(addTaskModule, animated: true)
    }

    func navigateToEditTask(from view: TaskListViewProtocol, task: Task) {
        guard let viewController = view as? UIViewController else { return }
        let addTaskModule = AddTaskRouter.createAddTaskModule()

        if let addTaskVC = addTaskModule as? AddTaskViewController {
            addTaskVC.editingTask = task
            addTaskVC.delegate = viewController as? AddTaskDelegate
        }

        viewController.navigationController?.pushViewController(addTaskModule, animated: true)
    }




}
