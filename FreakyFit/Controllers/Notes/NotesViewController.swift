import UIKit

class NotesViewController: UIViewController {
    
    private let segmentedControl = UISegmentedControl(items: ["All", "Workout", "Body"])
    private let tableView = UITableView()
    private let emptyView = EmptyStateView(
        icon: "📝",
        title: "No Notes Yet",
        message: "Keep track of how you feel, workout notes, and body statistics here!"
    )
    
    private var allNotes: [Note] = []
    private var filteredNotes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
    }
    
    private func setupUI() {
        title = "Notes Log"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleAddNote)
        )
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.reuseIdentifier)
        view.addSubview(tableView)
        
        view.addSubview(emptyView)
        
        segmentedControl.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 32)
        )
        
        tableView.anchor(
            top: segmentedControl.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        )
        
        emptyView.centerInSuperview()
        emptyView.onButtonTap = { [weak self] in
            self?.handleAddNote()
        }
    }
    
    private func setupThemeListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func themeDidChange() {
        applyThemeColors()
    }
    
    private func applyThemeColors() {
        view.backgroundColor = UIColor.appBackground
        segmentedControl.tintColor = UIColor.appPrimary
        tableView.backgroundColor = UIColor.appBackground
    }
    
    private func loadNotes() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        
        let categoryFilter: String?
        if selectedIndex == 1 {
            categoryFilter = "workout"
        } else if selectedIndex == 2 {
            categoryFilter = "body"
        } else {
            categoryFilter = nil
        }
        
        allNotes = DataManager.shared.fetchNotes(category: categoryFilter)
        filteredNotes = allNotes
        
        tableView.reloadData()
        
        let hasData = !filteredNotes.isEmpty
        tableView.isHidden = !hasData
        emptyView.isHidden = hasData
    }
    
    @objc private func handleSegmentChange() {
        loadNotes()
    }
    
    @objc private func handleAddNote() {
        let detailVC = NoteDetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TableView Methods
extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.reuseIdentifier, for: indexPath) as? NoteCell else {
            return UITableViewCell()
        }
        
        let note = filteredNotes[indexPath.row]
        cell.configure(with: note)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = filteredNotes[indexPath.row]
        let detailVC = NoteDetailViewController()
        detailVC.note = note
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = filteredNotes[indexPath.row]
            
            let confirm = UIAlertController(
                title: "Delete Note?",
                message: "Are you sure you want to delete this note?",
                preferredStyle: .actionSheet
            )
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                DataManager.shared.deleteNote(note)
                self?.loadNotes()
            }
            
            confirm.addAction(delete)
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(confirm, animated: true)
        }
    }
}
