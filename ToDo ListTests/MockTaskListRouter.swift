//
//  MockTaskListRouter.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import Foundation
@testable import ToDo_List
import UIKit

class MockTaskListRouter: TaskListRouterProtocol {
    var didNavigateToAddTask = false
    var didNavigateToEditTask = false

    static func createTaskListModule() -> UIViewController {
        // Возвращаем пустой контроллер для целей тестирования
        return UIViewController()
    }

    func navigateToAddTask(from view: TaskListViewProtocol) {
        didNavigateToAddTask = true
    }

    func navigateToEditTask(from view: TaskListViewProtocol, task: Task) {
        didNavigateToEditTask = true
    }
}
