//
//  Router.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import UIKit


protocol TaskListRouterProtocol {
    static func createTaskListModule() -> UIViewController
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
}
