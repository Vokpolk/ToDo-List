import CoreData

extension TaskCoreData {
    func toStruct() -> Task {
        Task(
            id: id,
            title: title ?? "",
            text: text ?? "",
            date: date ?? Date(),
            completed: completed
        )
    }
}

final class TaskStore: NSObject {
    let context: NSManagedObjectContext
    
    private var fetchedResultsController: NSFetchedResultsController<TaskCoreData>!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func addNewTask(_ task: Task) throws {
        let taskCoreData = TaskCoreData(context: context)
        taskCoreData.id = task.id
        taskCoreData.title = task.title
        taskCoreData.text = task.text
        taskCoreData.date = task.date
        taskCoreData.completed = task.completed
        
        if UserDefaults.standard.integer(forKey: "count") == 0 {
            UserDefaults.standard.set(1, forKey: "count")
        } else {
            let count = UserDefaults.standard.integer(forKey: "count")
            UserDefaults.standard.set(count + 1, forKey: "count")
        }
        saveContext()
    }
    
    func deleteTask(with id: Int32) {
        let fetchRequest = TaskCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let results = try context.fetch(fetchRequest)
            if let itemToDelete = results.first {
                context.delete(itemToDelete)
                saveContext()
            }
        } catch {
            print("Ошибка при удалении задачи!")
        }
    }
    
    func completeTask(with id: Int32, completed: Bool) {
        let fetchRequest = TaskCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let tasks = try context.fetch(fetchRequest)
            if let task = tasks.first {
                task.completed = completed
                saveContext()
            }
        } catch {
            print("Ошибка при выполнении задачи!")
        }
    }
    
    func editTask(with id: Int32, title: String, text: String) throws {
        let fetchRequest = TaskCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let tasks = try context.fetch(fetchRequest)
            if let task = tasks.first {
                task.title = title
                task.text = text
                saveContext()
            }
        } catch {
            print("Ошибка при выполнении задачи!")
        }
    }
    
    var tasks: [Task] {
        let fetchRequest = TaskCoreData.fetchRequest()
        do {
            let tasks = try context.fetch(fetchRequest)
            var result: [Task] = []
            tasks.forEach {
                result.append($0.toStruct())
            }
            return result
        } catch {
            print("Ошибка при получении задач!")
        }
        return []
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
}
