//
//  View.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 15.11.2024.
//

import UIKit

protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [Task])
}

class TaskListViewController: UIViewController, TaskListViewProtocol {
    var presenter: TaskListPresenterProtocol?

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
    }

    func showTasks(_ tasks: [Task]) {
        tableView.reloadData()
    }
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfTasks() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        if let task = presenter?.task(at: indexPath.row) {
            cell.textLabel?.text = task.title
        }
        return cell
    }
}

