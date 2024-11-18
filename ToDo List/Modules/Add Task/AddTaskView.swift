//
//  AddTaskView.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import UIKit

protocol AddTaskViewProtocol: AnyObject {
    func dismissView()
}

protocol AddTaskDelegate: AnyObject {
    func didAddTask(_ task: Task)
}


class AddTaskViewController: UIViewController, AddTaskViewProtocol {
    var presenter: AddTaskPresenterProtocol?
    weak var delegate: AddTaskDelegate?
    var editingTask: Task?

    
    private let titleField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let descriptionField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter description"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Task", for: .normal)
        button.addTarget(self, action: #selector(saveTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let task = editingTask {
            titleField.text = task.title
            descriptionField.text = task.description
            saveButton.setTitle("Update Task", for: .normal)
        }
    }

    func setupUI() {
        view.backgroundColor = .white

        
        view.addSubview(titleField)
        view.addSubview(descriptionField)
        view.addSubview(saveButton)

        
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20),
            descriptionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            saveButton.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func saveTask() {
        guard let title = titleField.text, !title.isEmpty,
            let description = descriptionField.text, !description.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        if var task = editingTask {
            task.title = title
            task.description = description
            delegate?.didAddTask(task)
        } else {
            let newTask = Task(
                id: Int.random(in: 1...1000),
                title: title,
                description: description,
                createdDate: Date(),
                isCompleted: false
            )
            delegate?.didAddTask(newTask)
        }

        navigationController?.popViewController(animated: true)
    }


    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
