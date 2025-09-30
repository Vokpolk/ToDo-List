import XCTest
@testable import ToDo_List

final class ToDo_ListTests: XCTestCase {
    
    private let jsonString: String =
    """
    {
        "todos": [
            {
                "id" : 1,
                "todo": "Do smth",
                "completed": false,
                "userId": 152
            }
        ],
        "total": 254,
        "skip": 0,
        "limit": 30
    }
    """
    
    func testDecode() throws {
        let todo = try JSONDecoder().decode(Todos.self, from: jsonString.data(using: .utf8) ?? Data())
        XCTAssertEqual(todo.todos[0].id, 1)
        XCTAssertFalse(todo.todos[0].completed)
    }

}
