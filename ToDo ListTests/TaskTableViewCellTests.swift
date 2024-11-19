//
//  TaskTableViewCellTests.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 20.11.2024.
//

import XCTest
@testable import ToDo_List

class TaskTableViewCellTests: XCTestCase {
    var cell: TaskTableViewCell!

    override func setUp() {
        super.setUp()
        cell = TaskTableViewCell()
    }

    func testConfigureCell() {
        let task = Task(id: 1, title: "Test Task", description: "Description", createdDate: Date(), isCompleted: false)
        cell.configure(with: task)
        XCTAssertEqual(cell.titleLabel.text, task.title)
        XCTAssertEqual(cell.descriptionLabel.text, task.description)
    }
}
