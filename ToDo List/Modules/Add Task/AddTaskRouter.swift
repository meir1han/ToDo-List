//
//  AddTaskRouter.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import UIKit

protocol AddTaskRouterProtocol {
    static func createAddTaskModule() -> UIViewController
}

class AddTaskRouter: AddTaskRouterProtocol {
    static func createAddTaskModule() -> UIViewController {
        
        let view = AddTaskViewController()
        let router = AddTaskRouter()

        return view
    }
}

