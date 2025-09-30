import UIKit

protocol CreateTaskDelegate: AnyObject {
    func createNew(task: Task)
    func edit(id: Int32, title: String, text: String)
}

struct EditableTask {
    let id: Int32
    let title: String
    let description: String
}

final class CreateTaskViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: CreateTaskDelegate?
    
    // MARK: - Private Properties
    private let currentDate = Date()
    private var editableTask: EditableTask?
    
    private lazy var enterTaskTitle: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Заголовок"
        textField.tintColor = UIColor(resource: .whiteToDo)
        textField.textColor = UIColor(resource: .whiteToDo)
        textField.font = .systemFont(ofSize: 32, weight: .bold)
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        label.text = formatter.string(from: currentDate)
        label.textColor = UIColor(resource: .whiteToDo).withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private lazy var enterDescriptionTitle: UITextView = {
        let textView = UITextView()
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.tintColor = UIColor(resource: .whiteToDo)
        textView.textColor = UIColor(resource: .whiteToDo)
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.backgroundColor = UIColor(resource: .blackToDo)
        return textView
    }()
    
    private lazy var createTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .yellowToDo)
        button.setTitleColor(.blackToDo, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(Self.createNewTask),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupBackButton()
        hideKeyboardEvent()
        initUIObjects()
    }
    
    private func initUIObjects() {
        if let editableTask {
            enterTaskTitle.text = editableTask.title
            enterDescriptionTitle.text = editableTask.description
            createTaskButton.setTitle("Обновить", for: .normal)
        }
        
        view.backgroundColor = UIColor(resource: .blackToDo)
        [
            enterTaskTitle,
            dateLabel,
            enterDescriptionTitle,
            createTaskButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            enterTaskTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            enterTaskTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterTaskTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            enterTaskTitle.heightAnchor.constraint(equalToConstant: 41),
            
            dateLabel.topAnchor.constraint(equalTo: enterTaskTitle.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            enterDescriptionTitle.topAnchor.constraint(equalTo: dateLabel.topAnchor, constant: 16),
            enterDescriptionTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterDescriptionTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            enterDescriptionTitle.heightAnchor.constraint(equalToConstant: 70),
            
            createTaskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createTaskButton.heightAnchor.constraint(equalToConstant: 60),
            createTaskButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createTaskButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: - Public Methods
    func configureEditableTask(id: Int32, title: String, description: String) {
        editableTask = EditableTask(id: id, title: title, description: description)
    }
    
    // MARK: - Private Methods
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle(" назад", for: .normal)
        backButton.tintColor = UIColor(resource: .yellowToDo)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func createNewTask() {
        print("Edit task")
        print("Create new task")
        
        guard
            let title = enterTaskTitle.text, !title.isEmpty,
            let description = enterDescriptionTitle.text, !description.isEmpty
        else {
            return
        }
        
        if let editableTask {
            delegate?.edit(id: editableTask.id, title: title, text: description)
            navigationController?.popViewController(animated: true)
            return
        }
        
        let task = Task(
            id: Int32(UserDefaults.standard.integer(forKey: "count") + 1),
            title: title,
            text: description,
            date: Date(),
            completed: false
        )
        delegate?.createNew(task: task)
        navigationController?.popViewController(animated: true)
    }
    
    private func hideKeyboardEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard() {
        enterTaskTitle.endEditing(true)
        enterDescriptionTitle.endEditing(true)
    }
}
