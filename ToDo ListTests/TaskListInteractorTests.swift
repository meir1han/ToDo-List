//
//  TaskListInteractorTests.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import XCTest
@testable import ToDo_List

class TaskListInteractorTests: XCTestCase {
    var interactor: TaskListInteractor!

    override func setUp() {
        super.setUp()
        interactor = TaskListInteractor()
    }

    func testLoadTasksFromCoreData() {
        let expectation = self.expectation(description: "LoadTasks")
        interactor.loadTasksFromCoreData { tasks in
            XCTAssertNotNil(tasks)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
