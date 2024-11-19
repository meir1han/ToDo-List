//
//  TaskTableViewCell.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let circleButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.gray.cgColor
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    
    var onStatusToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addContextMenu()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(circleButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            circleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circleButton.widthAnchor.constraint(equalToConstant: 30),
            circleButton.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: circleButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: circleButton.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: circleButton.trailingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        circleButton.addTarget(self, action: #selector(circleButtonTapped), for: .touchUpInside)
    }

    private func addContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    @objc private func circleButtonTapped() {
        onStatusToggle?()
    }

    func configure(with task: Task) {
        if task.isCompleted {
            let attributedString = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.gray
                ]
            )
            titleLabel.attributedText = attributedString
            
            circleButton.backgroundColor = .clear
            circleButton.layer.borderColor = UIColor.yellow.cgColor
            circleButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            circleButton.tintColor = .yellow
        } else {
            let attributedString = NSAttributedString(
                string: task.title,
                attributes: [
                    .foregroundColor: UIColor.label
                ]
            )
            titleLabel.attributedText = attributedString
            
            circleButton.backgroundColor = .clear
            circleButton.layer.borderColor = UIColor.gray.cgColor
            circleButton.setImage(nil, for: .normal)
            circleButton.tintColor = .clear
        }

        descriptionLabel.text = task.description
        descriptionLabel.textColor = task.isCompleted ? .gray : .label

        dateLabel.text = formattedDate(task.createdDate)
    }



    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}


extension TaskTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            let editAction = UIAction(
                title: "Edit",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.onEdit?()
            }

            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.onDelete?()
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
