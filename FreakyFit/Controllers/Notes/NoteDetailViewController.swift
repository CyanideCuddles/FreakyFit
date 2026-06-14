import UIKit

class NoteDetailViewController: UIViewController {
    
    var note: Note?
    
    private let titleField = UITextField()
    private let categorySegment = UISegmentedControl(items: ["Workout", "Body"])
    private let contentTextView = UITextView()
    private let timestampLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeListener()
        applyThemeColors()
        setupKeyboardObservers()
        populateFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNote()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = note == nil ? "New Note" : "Edit Note"
        
        titleField.placeholder = "Title"
        titleField.font = UIFont.appTitle
        titleField.borderStyle = .roundedRect
        titleField.autocapitalizationType = .sentences
        view.addSubview(titleField)
        
        categorySegment.selectedSegmentIndex = 0
        view.addSubview(categorySegment)
        
        contentTextView.font = UIFont.appBody
        contentTextView.roundCorners(radius: 8)
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.appSeparator.cgColor
        view.addSubview(contentTextView)
        
        timestampLabel.font = UIFont.appCaption
        timestampLabel.textColor = UIColor.appTextSecondary
        timestampLabel.textAlignment = .center
        view.addSubview(timestampLabel)
        
        // Constraints
        titleField.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 44)
        )
        
        categorySegment.anchor(
            top: titleField.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 12, left: 16, bottom: 0, right: -16),
            size: CGSize(width: 0, height: 32)
        )
        
        contentTextView.anchor(
            top: categorySegment.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        )
        
        timestampLabel.anchor(
            top: contentTextView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 8, left: 16, bottom: -12, right: -16),
            size: CGSize(width: 0, height: 20)
        )
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
        titleField.backgroundColor = UIColor.appSurface
        titleField.textColor = UIColor.appTextPrimary
        categorySegment.tintColor = UIColor.appPrimary
        contentTextView.backgroundColor = UIColor.appSurface
        contentTextView.textColor = UIColor.appTextPrimary
        contentTextView.layer.borderColor = UIColor.appSeparator.cgColor
        timestampLabel.textColor = UIColor.appTextSecondary
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        // Shrink textView to avoid typing under keyboard
        UIView.animate(withDuration: 0.3) {
            self.contentTextView.setValue(self.view.safeAreaLayoutGuide.bottomAnchor, forKey: "bottomAnchor") // Reset constraint
            self.timestampLabel.isHidden = true
            
            // Re-apply bottom constraint of textView relative to keyboard
            self.contentTextView.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor,
                constant: -keyboardHeight - 16
            ).isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.timestampLabel.isHidden = false
            self.contentTextView.bottomAnchor.constraint(
                equalTo: self.timestampLabel.topAnchor,
                constant: -8
            ).isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    private func populateFields() {
        if let note = note {
            titleField.text = note.title
            contentTextView.text = note.content
            
            let cat = note.category?.lowercased() ?? "workout"
            categorySegment.selectedSegmentIndex = cat == "workout" ? 0 : 1
            
            if let date = note.updatedAt {
                timestampLabel.text = "Last updated: " + date.formatted(as: "MMM d, yyyy h:mm a")
            }
        } else {
            timestampLabel.text = "Drafting new note"
        }
    }
    
    private func saveNote() {
        let titleText = titleField.text ?? ""
        let contentText = contentTextView.text ?? ""
        let catStr = categorySegment.selectedSegmentIndex == 0 ? "workout" : "body"
        
        // Skip save if empty
        if titleText.trimmingCharacters(in: .whitespaces).isEmpty && contentText.trimmingCharacters(in: .whitespaces).isEmpty {
            if let existing = note {
                DataManager.shared.deleteNote(existing)
            }
            return
        }
        
        if let existing = note {
            DataManager.shared.updateNote(existing, title: titleText, content: contentText)
            existing.category = catStr
            DataManager.shared.save()
        } else {
            _ = DataManager.shared.createNote(title: titleText, content: contentText, category: catStr)
        }
    }
}
