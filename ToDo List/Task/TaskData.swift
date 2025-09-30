import Foundation

struct Task {
    let id: Int32
    let title: String
    let text: String
    let date: Date
    var completed: Bool
}

struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct Todos: Codable {
    let todos: [Todo]
    let total: Int
    let skip: Int
    let limit: Int
}

func readJSONFromFile() -> Todos? {
    guard let url = Bundle.main.url(forResource: "todos", withExtension: "json") else {
        print("JSON фалй не найден")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        let todos = try JSONDecoder().decode(Todos.self, from: data)
        
        print(todos)
        
        return todos
    } catch {
        print("JSON файл не прочитан")
        return nil
    }
}
