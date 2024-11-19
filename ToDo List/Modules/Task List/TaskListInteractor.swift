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
    func loadTasksFromCoreData(completion: @escaping ([Task]) -> Void)
    func deleteTaskFromCoreData(task: Task, completion: @escaping (Bool) -> Void)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [Task])
    func didFailWithError(_ error: Error)
}

class TaskListInteractor: TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol?

    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    func fetchTasks() {
        DispatchQueue.global(qos: .background).async {
            self.loadTasksFromCoreData { tasks in
                if tasks.isEmpty {
                    self.fetchTasksFromAPI()
                } else {
                    DispatchQueue.main.async {
                        self.presenter?.didFetchTasks(tasks)
                    }
                }
            }
        }
    }
    
    private func fetchTasksFromAPI() {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.presenter?.didFailWithError(error)
                }
                return
            }

            guard let data = data else { return }
            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                let tasks = decodedResponse.todos.map { todo in
                    Task(
                        id: todo.id,
                        title: todo.todo,
                        description: "Description not provided",
                        createdDate: Date(),
                        isCompleted: todo.completed
                    )
                }

                tasks.forEach { self.saveTaskToCoreData(task: $0) }

                DispatchQueue.main.async {
                    self.presenter?.didFetchTasks(tasks)
                }

            } catch {
                DispatchQueue.main.async {
                    self.presenter?.didFailWithError(error)
                }
            }
        }
        task.resume()
    }

    func loadTasksFromCoreData(completion: @escaping ([Task]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            do {
                let taskEntities = try self.context.fetch(fetchRequest)
                let tasks = taskEntities.map {
                    Task(
                        id: Int($0.id),
                        title: $0.title ?? "",
                        description: $0.taskDescription ?? "",
                        createdDate: $0.createdDate ?? Date(),
                        isCompleted: $0.isCompleted
                    )
                }
                completion(tasks)
            } catch {
                print("Failed to fetch tasks: \(error)")
                completion([])
            }
        }
    }

    func saveTaskToCoreData(task: Task) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)

            do {
                if let existingTask = try self.context.fetch(fetchRequest).first {
                    existingTask.title = task.title
                    existingTask.taskDescription = task.description
                    existingTask.createdDate = task.createdDate
                    existingTask.isCompleted = task.isCompleted
                } else {
                    let newTask = TaskEntity(context: self.context)
                    newTask.id = Int64(task.id)
                    newTask.title = task.title
                    newTask.taskDescription = task.description
                    newTask.createdDate = task.createdDate
                    newTask.isCompleted = task.isCompleted
                }
                try self.context.save()
            } catch {
                print("Failed to save task: \(error)")
            }
        }
    }

    func deleteTaskFromCoreData(task: Task, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)

            do {
                if let taskEntity = try self.context.fetch(fetchRequest).first {
                    self.context.delete(taskEntity)
                    try self.context.save()
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print("Failed to delete task: \(error)")
                completion(false)
            }
        }
    }
}
