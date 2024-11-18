//
//  View.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import UIKit

protocol AddTaskViewProtocol: AnyObject {
    func dismissView()
}

class AddTaskViewController: UIViewController, AddTaskViewProtocol {
    var presenter: AddTaskPresenterProtocol?

    private let titleField = UITextField()
    private let descriptionField = UITextField()
    private let saveButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .white
        titleField.placeholder = "Enter title"
        descriptionField.placeholder = "Enter description"
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTask), for: .touchUpInside)

        // Layout fields and button
        // Add them as subviews and set constraints
    }

    @objc func saveTask() {
        guard let title = titleField.text, !title.isEmpty,
              let description = descriptionField.text, !description.isEmpty else {
            return
        }
        presenter?.addTask(title: title, description: description)
    }

    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
