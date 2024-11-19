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
        navigationItem.backButtonTitle = "Назад"
        navigationController?.navigationBar.tintColor = .yellow
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
        setupSearchBar()
        setupNavigationBar()

    }
    

    func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
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
        navigationItem.title = "Задачи"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.systemBackground

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
        
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
            ),
            style: .plain,
            target: self,
            action: #selector(addTask)
        )
        editButton.tintColor = .yellow
        
        taskCountLabel = UIBarButtonItem(
            title: "\(filteredTasks.count) Задач",
            style: .plain,
            target: nil,
            action: nil
        )
        taskCountLabel?.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.red,
        ], for: .normal)
        taskCountLabel?.isEnabled = false

        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexibleSpace1, taskCountLabel!, flexibleSpace2, editButton], animated: false)
    }


  
    func setupSearchBar() {
        let searchBarContainer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 56))
        searchBarContainer.backgroundColor = .clear
        

        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        
        searchBar.frame = CGRect(x: 10, y: 10, width: searchBarContainer.bounds.width - 20, height: 36)
        searchBarContainer.addSubview(searchBar)
        
        tableView.tableHeaderView = searchBarContainer
    }


    func showTasks(_ tasks: [Task]) {
        self.filteredTasks = tasks
        tableView.reloadData()
        
        taskCountLabel?.title = "\(filteredTasks.count) Задач"

    }
    


    
    @objc func addTask() {
        presenter?.navigateToAddTask()
    }
    
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }

        let task = filteredTasks[indexPath.row]

        cell.configure(with: task)

        cell.onStatusToggle = { [weak self] in
            self?.presenter?.toggleTaskCompletion(at: indexPath.row)
        }
        
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

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completionHandler in
            self?.presenter?.deleteTask(at: indexPath.row)
            completionHandler(true)
        }

        let completeAction = UIContextualAction(
            style: .normal,
            title: task.isCompleted ? "Незавершенный" : "Завершенный"
        ) { [weak self] _, _, completionHandler in
            self?.presenter?.toggleTaskCompletion(at: indexPath.row)
            completionHandler(true)
        }

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
