//
//  TaskListRouterTests.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import XCTest
@testable import ToDo_List

class TaskListRouterTests: XCTestCase {
    var router: TaskListRouter!

    override func setUp() {
        super.setUp()
        router = TaskListRouter()
    }

    func testCreateTaskListModule() {
        let viewController = TaskListRouter.createTaskListModule()
        XCTAssertNotNil(viewController)
        XCTAssertTrue(viewController is TaskListViewController)
    }
}
