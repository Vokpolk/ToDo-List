import UIKit

class MainViewController: UIViewController {
    // MARK: - Private Properties
    private var tasks: [Task] = []
    
    private lazy var tasksLable: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let whiteColorWithAlpha = UIColor(resource: .whiteToDo).withAlphaComponent(0.5)
        
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.backgroundColor = UIColor(resource: .grayToDo)
        searchBar.searchTextField.textColor = whiteColorWithAlpha
        searchBar.searchTextField.tintColor = whiteColorWithAlpha
        
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: whiteColorWithAlpha]
        )
        
        let searchImage = UIImage(systemName: "magnifyingglass")?
            .withTintColor(whiteColorWithAlpha, renderingMode: .alwaysOriginal)
        searchBar.setImage(searchImage, for: .search, state: .normal)
        
        searchBar.showsBookmarkButton = true
        let micImage = UIImage(systemName: "mic.fill")?
            .withTintColor(whiteColorWithAlpha, renderingMode: .alwaysOriginal)
        searchBar.setImage(micImage, for: .bookmark, state: .normal)
        
        searchBar.searchTextField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            TaskCollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        collectionView.backgroundColor = UIColor(resource: .blackToDo)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        return collectionView
    }()
    
    private lazy var footerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(resource: .grayToDo)
        
        return imageView
    }()
    
    private lazy var tasksCount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(resource: .whiteToDo)
        label.text = "0 задач"
        return label
    }()
    
    private lazy var createTaskButton: UIButton = {
        let button = UIButton()
        button.setImage(.createTask, for: .normal)
        
        button.addTarget(
            self,
            action: #selector(Self.didCreateTaskButtonTap),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private let taskStore: TaskStore = TaskStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCollectionView()
        
        hideKeyboardEvent()
        initUIObjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Private Methods
    private func updateCollectionView() {
        tasks = taskStore.tasks
        tasksCount.text = taskCountConvertLabel(for: tasks.count)
        collectionView.reloadData()
    }
    
    private func initUIObjects() {
        view.backgroundColor = UIColor(resource: .blackToDo)
        
        [
            tasksLable,
            searchBar,
            collectionView,
            footerImageView,
            tasksCount,
            createTaskButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tasksLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            tasksLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            searchBar.topAnchor.constraint(equalTo: tasksLable.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0),
            searchBar.searchTextField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 0),
            searchBar.searchTextField.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 0),
            searchBar.searchTextField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            footerImageView.heightAnchor.constraint(equalToConstant: 83),
            footerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            footerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            footerImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: footerImageView.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            tasksCount.topAnchor.constraint(equalTo: footerImageView.topAnchor, constant: 20.5),
            tasksCount.centerXAnchor.constraint(equalTo: footerImageView.centerXAnchor),
            
            createTaskButton.topAnchor.constraint(equalTo: footerImageView.topAnchor, constant: 18),
            createTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func taskCountConvertLabel(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder100 >= 11 && remainder100 <= 14 {
            return "\(count) задач"
        }
        
        switch remainder10 {
        case 1:
            return "\(count) задача"
        case 2, 3, 4:
            return "\(count) задачи"
        default:
            return "\(count) задач"
        }
    }
    
    @objc private func didCreateTaskButtonTap() {
        let vc = CreateTaskViewController()
        vc.delegate = self
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
//        present(vc, animated: true)
    }
    
    @objc private func textDidChange(_ searchField: UISearchTextField) {
        tasks = taskStore.tasks
        if let searchText = searchField.text, !searchText.isEmpty {
            tasks = tasks.filter{ task in
                task.title.lowercased().contains(searchText.lowercased())
            }
        } else {
        }
        collectionView.reloadData()
    }

    private func hideKeyboardEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard() {
        searchBar.searchTextField.endEditing(true)
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        tasks.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        ) as? TaskCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        let task = tasks[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        
        cell.configure(task: task, with: indexPath)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 106)
    }
    
    // MARK: - Вызов контекстного меню
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        guard
            let indexPath = indexPaths.first,
            let cell = collectionView.cellForItem(at: indexPath) as? TaskCollectionViewCell
        else {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            actionProvider: { actions in
            return UIMenu(children: [
                UIAction(
                    title: "Редактировать",
                    image: UIImage(resource: .edit)
                ) { [weak self] _ in
                    guard let self else { return }
                    let vc = CreateTaskViewController()
                    vc.delegate = self
                    vc.configureEditableTask(
                        id: cell.taskId!,
                        title: cell.title!,
                        description: cell.text!
                    )
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                },
                UIAction(
                    title: "Поделиться",
                    image: UIImage(resource: .export)
                ) { _ in },
                UIAction(
                    title: "Удалить",
                    image: UIImage(resource: .trash),
                    attributes: .destructive
                ) { [weak self] _ in
                    guard let self else { return }
                    self.taskStore.deleteTask(with: cell.taskId!)
                    self.updateCollectionView()
                }
            ])
        })
    }
    
    // MARK: - Настройка контекстного меню
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TaskCollectionViewCell else {
            return nil
        }
        
        let imageView = cell
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: 12)
        parameters.backgroundColor = UIColor(resource: .grayToDo)
        
        let preview = UITargetedPreview(view: imageView, parameters: parameters)
        
        return preview
    }
}

// MARK: - TaskCellDelegate

extension MainViewController: TaskCellDelegate {
    func completeTask(id: Int32, at indexPath: IndexPath) {
        taskStore.completeTask(with: id, completed: true)
        tasks[indexPath.row].completed = true
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleteTask(id: Int32, at indexPath: IndexPath) {
        
        taskStore.completeTask(with: id, completed: false)
        tasks[indexPath.row].completed = false
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
}


// MARK: - CreateTaskDelegate

extension MainViewController: CreateTaskDelegate {
    func edit(id: Int32, title: String, text: String) {
        do {
            try taskStore.editTask(with: id, title: title, text: text)
        } catch {
            print("Не удалось сохранить новую задачу")
            return
        }
        updateCollectionView()
    }
    
    func createNew(task: Task) {
        do {
            try taskStore.addNewTask(task)
        } catch {
            print("Не удалось сохранить новую задачу")
            return
        }
        updateCollectionView()
    }
}
