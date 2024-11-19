//
//  TaskListPresenterTests.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import XCTest
@testable import ToDo_List

class TaskListPresenterTests: XCTestCase {
    var presenter: TaskListPresenter!
    var mockView: MockTaskListView!
    var mockInteractor: MockTaskListInteractor!
    var mockRouter: MockTaskListRouter!

    override func setUp() {
        super.setUp()
        presenter = TaskListPresenter()
        mockView = MockTaskListView()
        mockInteractor = MockTaskListInteractor()
        mockRouter = MockTaskListRouter()

        presenter.view = mockView
        presenter.interactor = mockInteractor
        presenter.router = mockRouter
    }

    func testNumberOfTasks() {
        let task = Task(id: 1, title: "Test Task", description: "", createdDate: Date(), isCompleted: false)
        presenter.didFetchTasks([task])
        XCTAssertEqual(presenter.numberOfTasks(), 1)
    }

    func testUpdateOrAddTask() {
        let task = Task(id: 1, title: "Test Task", description: "", createdDate: Date(), isCompleted: false)
        presenter.updateOrAddTask(task)
        XCTAssertEqual(presenter.numberOfTasks(), 1)
        XCTAssertEqual(mockInteractor.savedTask?.id, task.id)
    }

    func testDeleteTask() {
        let task = Task(id: 1, title: "Test Task", description: "", createdDate: Date(), isCompleted: false)
        presenter.didFetchTasks([task])
        presenter.deleteTask(at: 0)
        XCTAssertEqual(presenter.numberOfTasks(), 0)
        XCTAssertEqual(mockInteractor.deletedTask?.id, task.id)
    }

    func testNavigateToAddTask() {
        presenter.navigateToAddTask()
        XCTAssertTrue(mockRouter.didNavigateToAddTask)
    }
}
