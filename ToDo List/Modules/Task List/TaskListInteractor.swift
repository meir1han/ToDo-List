//
//  TaskListInteractor.swift
//  ToDo List
//
//  Created by Meirkhan Nishonov on 18.11.2024.
//

import Foundation
import CoreData
import UIKit

protocol TaskListInteractorInputProtocol {
    func fetchTasks()
    func saveTaskToCoreData(task: Task)
    func loadTasksFromCoreData() -> [Task]
    func deleteTaskFromCoreData(task: Task)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [Task])
}

class TaskListInteractor: TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol?

    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // Загрузка задач из Core Data
    func fetchTasks() {
        DispatchQueue.global(qos: .background).async {
            let tasks = self.loadTasksFromCoreData()
            
            if tasks.isEmpty {
                // Если задач нет, загружаем из API
                self.fetchTasksFromAPI()
            } else {
                DispatchQueue.main.async {
                    self.presenter?.didFetchTasks(tasks)
                }
            }
        }
    }
    
    private func fetchTasksFromAPI() {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching tasks: \(error)")
                return
            }

            guard let data = data else { return }
            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                let tasks = decodedResponse.todos.map { todo in
                    Task(
                        id: todo.id,
                        title: todo.todo,
                        description: "Description not provided", // Заполняем пустым описанием
                        createdDate: Date(), // Используем текущую дату
                        isCompleted: todo.completed
                    )
                }

                // Сохраняем задачи в Core Data
                tasks.forEach { self.saveTaskToCoreData(task: $0) }

                // Передаём задачи в Presenter
                DispatchQueue.main.async {
                    self.presenter?.didFetchTasks(tasks)
                }

            } catch {
                print("Failed to decode tasks: \(error)")
            }
        }
        task.resume()
    }

    func loadTasksFromCoreData() -> [Task] {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let taskEntities = try context.fetch(fetchRequest)
            return taskEntities.map {
                Task(
                    id: Int($0.id),
                    title: $0.title ?? "",
                    description: $0.taskDescription ?? "",
                    createdDate: $0.createdDate ?? Date(),
                    isCompleted: $0.isCompleted
                )
            }
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }

    // Сохранение задачи в Core Data
    func saveTaskToCoreData(task: Task) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)

        do {
            if let existingTask = try context.fetch(fetchRequest).first {
                // Обновляем существующую задачу
                existingTask.title = task.title
                existingTask.taskDescription = task.description
                existingTask.createdDate = task.createdDate
                existingTask.isCompleted = task.isCompleted
            } else {
                // Создаём новую задачу
                let newTask = TaskEntity(context: context)
                newTask.id = Int64(task.id)
                newTask.title = task.title
                newTask.taskDescription = task.description
                newTask.createdDate = task.createdDate
                newTask.isCompleted = task.isCompleted
            }

            try context.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }


    // Удаление задачи из Core Data
    func deleteTaskFromCoreData(task: Task) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)

        do {
            if let taskEntity = try context.fetch(fetchRequest).first {
                context.delete(taskEntity)
                try context.save()
            }
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}

