//
//  TaskListView.swift
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
    
    let searchBar = UISearchBar()
    private var filteredTasks: [Task] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
        setupSearchBar()

    }

    func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))

    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search tasks"
        navigationItem.titleView = searchBar
    }

    func showTasks(_ tasks: [Task]) {
        self.filteredTasks = tasks
        tableView.reloadData()
    }

    
    @objc func addTask() {
        presenter?.navigateToAddTask()
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TaskCell")

        let task = filteredTasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.isCompleted {
            let attributedString = NSAttributedString(
                string: task.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            cell.textLabel?.attributedText = attributedString
            cell.textLabel?.textColor = .gray
        } else {
            // Обычный текст, если задача не выполнена
            cell.textLabel?.text = task.title
            cell.textLabel?.textColor = .black
        }
//        cell.textLabel?.textColor = task.isCompleted ? .gray : .black

        let dateText = "\(formattedDate(task.createdDate))"
        let descriptionText = "\(task.description)"

        // Формируем подзаголовок с разным цветом для description и date
        let attributedString = NSMutableAttributedString()

        // Добавляем описание
        let descriptionAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: task.isCompleted ? UIColor.gray : UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        attributedString.append(NSAttributedString(string: descriptionText + "\n", attributes: descriptionAttributes))

        // Добавляем дату
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        attributedString.append(NSAttributedString(string: dateText, attributes: dateAttributes))

        cell.detailTextLabel?.attributedText = attributedString
        cell.detailTextLabel?.numberOfLines = 0 // Поддержка многострочного текста

        return cell
    }



}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter?.deleteTask(at: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.navigateToEditTask(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let task = presenter?.task(at: indexPath.row) else {
            return nil
        }

        // Действие "Delete"
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.presenter?.deleteTask(at: indexPath.row)
            completionHandler(true)
        }

        // Действие "Complete/Incomplete"
        let completeAction = UIContextualAction(
            style: .normal,
            title: task.isCompleted ? "Incomplete" : "Complete"
        ) { [weak self] _, _, completionHandler in
            self?.presenter?.toggleTaskCompletion(at: indexPath.row)
            completionHandler(true)
        }

        // Возвращаем оба действия
        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }

}

extension TaskListViewController: AddTaskDelegate {
    func didAddTask(_ task: Task) {
        presenter?.updateOrAddTask(task)
    }
}

extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.filterTasks(with: searchText)
    }
}
