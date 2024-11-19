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

class AddTaskViewController: UIViewController, AddTaskViewProtocol, UITextViewDelegate {
    var presenter: AddTaskPresenterProtocol?
    weak var delegate: AddTaskDelegate?
    var editingTask: Task?
    private var isTaskSaved = false

    private let titleField: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 32)
        textView.textColor = .label
        textView.textAlignment = .left
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionField: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .label
        textView.textAlignment = .left
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()

        titleField.delegate = self
        descriptionField.delegate = self

        if let task = editingTask {
            titleField.text = task.title
            descriptionField.text = task.description
            dateLabel.text = "\(formattedDate(task.createdDate))"
        } else {
            dateLabel.text = "\(formattedDate(Date()))"
        }
    }

    private func setupUI() {
        view.addSubview(titleField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionField)

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descriptionField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            descriptionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionField.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    func textViewDidChange(_ textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        view.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }

    private func syncTaskData() {
        guard var task = editingTask else { return }
        task.title = titleField.text ?? ""
        task.description = descriptionField.text ?? ""
        editingTask = task
    }

    private func saveTaskData() {
        guard !isTaskSaved else { return }
        isTaskSaved = true

        guard let title = titleField.text, !title.isEmpty,
              let description = descriptionField.text, !description.isEmpty else {
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        syncTaskData()
        saveTaskData()
    }

    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
