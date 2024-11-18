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
    
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private var taskCountLabel: UIBarButtonItem?

    


    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Tasks"
        setupUI()
        presenter?.viewDidLoad()
        setupSearchBar()
        setupNavigationBar()

//        updateTaskCount()
    }
    

    func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        
        setupToolbar()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])


    }
    
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tasks"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 34),
            .foregroundColor: UIColor.label
        ]
        appearance.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.label
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupToolbar() {
        view.addSubview(toolbar)

        // Создаём кнопки
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addTask)
        )

        // Инициализируем глобальное свойство `taskCountLabel`
        taskCountLabel = UIBarButtonItem(
            title: "Tasks: \(filteredTasks.count)",
            style: .plain,
            target: nil,
            action: nil
        )
        taskCountLabel?.isEnabled = false // Делаем лейбл недоступным для нажатия

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Добавляем кнопки в toolbar
        toolbar.setItems([editButton, flexibleSpace, taskCountLabel!], animated: false)
    }

  
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search tasks"
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
    }

    func showTasks(_ tasks: [Task]) {
        self.filteredTasks = tasks
        tableView.reloadData()
        
        taskCountLabel?.title = "Tasks: \(filteredTasks.count)"

    }
    
//    @objc private func editTasks() {
//        // Включаем или выключаем режим редактирования таблицы
//        tableView.setEditing(!tableView.isEditing, animated: true)
//    }

    
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
        // Используем кастомную ячейку
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }

        let task = filteredTasks[indexPath.row]

        // Конфигурация ячейки
        cell.configure(with: task)

        // Добавляем обработчик для переключения статуса задачи
        cell.onStatusToggle = { [weak self] in
            self?.presenter?.toggleTaskCompletion(at: indexPath.row)
        }
        
        // Обработчики действий
        cell.onEdit = { [weak self] in
            self?.presenter?.navigateToEditTask(at: indexPath.row)
        }

        cell.onDelete = { [weak self] in
            self?.presenter?.deleteTask(at: indexPath.row)
        }

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
