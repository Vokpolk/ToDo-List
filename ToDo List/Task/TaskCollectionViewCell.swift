import UIKit

protocol TaskCellDelegate: AnyObject {
    func completeTask(id: Int32, at indexPath: IndexPath)
    func uncompleteTask(id: Int32, at indexPath: IndexPath)
}

final class TaskCollectionViewCell: UICollectionViewCell {
    // MARK: - Public Properties
    weak var delegate: TaskCellDelegate?
    
    // MARK: - Private Properties
    private var isCompleted: Bool = false
    private(set) var taskId: Int32?
    private(set) var title: String?
    private(set) var text: String?
    private var indexPath: IndexPath?
    
    private lazy var completeIconButton: UIButton = {
        let button = UIButton()
        button.setImage(.notCompleted, for: .normal)
        
        button.addTarget(
            self,
            action: #selector(Self.didCompleteButtonTap),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(resource: .whiteToDo)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(resource: .whiteToDo)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(resource: .whiteToDo).withAlphaComponent(0.5)
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .grayToDo)
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUIObjects()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) error")
    }
    // MARK: - Public Methods
    func configure(task: Task, with indexPath: IndexPath) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        
        taskId = task.id
        titleLabel.text = task.title
        title = task.title
        descriptionLabel.text = task.text
        text = task.text
        dateLabel.text = formatter.string(from: task.date)
        isCompleted = task.completed
        
        self.indexPath = indexPath
        
        updateCompleteButtonImage()
    }
    
    // MARK: - Private Methods
    private func initUIObjects() {
        [
            completeIconButton,
            titleLabel,
            descriptionLabel,
            dateLabel,
            separatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            completeIconButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            completeIconButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 32),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20),
            dateLabel.heightAnchor.constraint(equalToConstant: 16),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -20),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    @objc private func didCompleteButtonTap() {
        isCompleted.toggle()
        
        guard let taskId, let indexPath else {
            return
        }
        
        if isCompleted {
            completeIconButton.setImage(.completed, for: .normal)
            titleLabel.textColor = .gray
            descriptionLabel.textColor = .gray
            
            titleLabel.attributedText = NSAttributedString(
                string: titleLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            
            delegate?.completeTask(id: taskId, at: indexPath)
        } else {
            completeIconButton.setImage(.notCompleted, for: .normal)
            titleLabel.textColor = UIColor(resource: .whiteToDo)
            descriptionLabel.textColor = UIColor(resource: .whiteToDo)
            
            titleLabel.attributedText = NSAttributedString(
                string: titleLabel.text ?? "",
                attributes: [.strikethroughStyle: 0]
            )
            
            delegate?.uncompleteTask(id: taskId, at: indexPath)
            
        }
    }
    
    private func updateCompleteButtonImage()
    {
        if isCompleted {
            completeIconButton.setImage(.completed, for: .normal)
            titleLabel.textColor = .gray
            descriptionLabel.textColor = .gray
            
            titleLabel.attributedText = NSAttributedString(
                string: titleLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            
        } else {
            completeIconButton.setImage(.notCompleted, for: .normal)
            titleLabel.textColor = UIColor(resource: .whiteToDo)
            descriptionLabel.textColor = UIColor(resource: .whiteToDo)
            
            
            titleLabel.attributedText = NSAttributedString(
                string: titleLabel.text ?? "",
                attributes: [.strikethroughStyle: 0]
            )
        }
    }
}
