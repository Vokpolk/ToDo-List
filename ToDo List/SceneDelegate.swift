import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if !UserDefaults.standard.bool(forKey: "firstStart") {
            firstStart()
        }
        
        let mainVC = MainViewController()
        let navC = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navC
        window?.makeKeyAndVisible()
    }
    
    func firstStart() {
        UserDefaults.standard.set(true, forKey: "firstStart")
        let todos = readJSONFromFile()
        let taskStore: TaskStore = TaskStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        
        guard let todos else { return }
        for todo in todos.todos {
            let task = Task(
                id: Int32(todo.id),
                title: String(todo.userId),
                text: todo.todo,
                date: Date(),
                completed: todo.completed
            )
            do {
                try taskStore.addNewTask(task)
            } catch {
                print("Не сохранились данные из JSON в CoreData")
            }
        }
    }
}

