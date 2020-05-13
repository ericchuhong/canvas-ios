//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import Core

class CreateAccountViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var name: CreateAccountRow!
    @IBOutlet weak var email: CreateAccountRow!
    @IBOutlet weak var password: CreateAccountRow!
    @IBOutlet weak var createAccountButton: DynamicButton!
    @IBOutlet weak var termsAndConditionsLabel: DynamicLabel!
    @IBOutlet weak var alreadyHaveAccountLabel: DynamicLabel!
    var selectedTextField: UITextField?
    var baseURL: URL?
    var accountID: String = ""
    var pairingCode: String = ""

    static func create(baseURL: URL, accountID: String, pairingCode: String) -> CreateAccountViewController {
        let vc = loadFromStoryboard()
        vc.baseURL = baseURL
        vc.accountID = accountID
        vc.pairingCode = pairingCode
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        scrollView.keyboardDismissMode = .onDrag

        name.labelName.text = NSLocalizedString("Full name", comment: "")
        name.textField.placeholder = NSLocalizedString("Full name...", comment: "")
        name.errorLabel.text = nil
        name.textField.delegate = self
        name.textField.returnKeyType = .next

        email.textField.keyboardType = .emailAddress
        email.labelName.text = NSLocalizedString("Email address", comment: "")
        email.textField.placeholder = NSLocalizedString("Email...", comment: "")
        email.errorLabel.text = nil
        email.textField.delegate = self
        email.textField.returnKeyType = .next

        password.textField.isSecureTextEntry = true
        password.labelName.text = NSLocalizedString("Password", comment: "")
        password.textField.placeholder = NSLocalizedString("Password...", comment: "")
        password.textField.delegate = self
        password.errorLabel.text = nil
        password.textField.returnKeyType = .done

        createAccountButton.layer.cornerRadius = 4

        createAccountButton.setTitle(NSLocalizedString("Create Account", comment: ""), for: .normal)
        termsAndConditionsLabel.text = NSLocalizedString("By tapping ‘Create Account’, you agree to the Terms of Service and acknowledge the Privacy Policy.", comment: "")

        alreadyHaveAccountLabel.text = NSLocalizedString("Already have an account? Sign In", comment: "")

        stackView.setCustomSpacing(4, after: password)
        stackView.setCustomSpacing(16, after: termsAndConditionsLabel)
        stackView.setCustomSpacing(16, after: createAccountButton)

        setupKeyboardNofications()
    }

    func setupKeyboardNofications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let info = notification.userInfo as? [String: Any],
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
        scrollView.scrollToView(view: selectedTextField, keyboardRect: keyboardFrame)
    }

    @IBAction func actionSignIn(_ sender: Any) {
        AppEnvironment.shared.router.dismiss(self) {
            if let delegate = AppEnvironment.shared.loginDelegate { delegate.changeUser() }
        }
    }

    @IBAction func actionCreateAccount(_ sender: Any) {
        guard let baseURL = baseURL else { return }
        guard let fullname = name.textField.text, fullname.count > 2 else { rowInvalidShowError(row: name); return }
        guard let userEmail = email.textField.text, !userEmail.isEmpty else { rowInvalidShowError(row: email); return }
        guard let userPassword = password.textField.text, !userPassword.isEmpty else { rowInvalidShowError(row: password); return }

        resetRowErrors()

        let request = PostAccountUserRequest(
            baseURL: baseURL,
            accountID: accountID,
            pairingCode: pairingCode,
            name: fullname,
            email: userEmail,
            password: userPassword
        )
        AppEnvironment.shared.api.makeRequest(request) { [weak self] (_, _, error) in
            performUIUpdate {
                if let error = error {
                    self?.showError(error)
                    return
                }
                self?.dismissCreateAccount()
            }
        }
    }

    func rowInvalidShowError(row: CreateAccountRow) {
        resetRowErrors()
        row.textField.layer.borderColor = UIColor.named(.borderDanger).cgColor

        switch row {
        case name: return
            row.errorLabel.text = NSLocalizedString("Please enter full name", comment: "")
        case email: return
            row.errorLabel.text = NSLocalizedString("Please enter an email address", comment: "")
        case password: return
            row.errorLabel.text = NSLocalizedString("Password is required", comment: "")
        default: return
        }
    }

    func resetRowErrors() {
        let rows = [name, email, password]
        rows.forEach {
            $0?.textField.layer.borderWidth = 1
            $0?.textField.layer.cornerRadius = 4
            $0?.textField.layer.borderColor = UIColor.named(.borderMedium).cgColor
            $0?.errorLabel.text = nil
        }
    }

    func dismissCreateAccount() {
        AppEnvironment.shared.router.dismiss(self) {
            if let delegate = AppEnvironment.shared.loginDelegate { delegate.changeUser() }
        }
    }

    func keyboardDidChangeState(keyboardFrame: CGRect) {
        scrollView.scrollToView(view: selectedTextField, keyboardRect: keyboardFrame)
    }
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.contentOffset = CGPoint.zero
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let next: UITextField?

        switch textField {
        case name.textField: next = email.textField
        case email.textField: next = password.textField
        default: next = nil
        }

        if let next = next {
            next.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}

class CreateAccountRow: UIView {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: CustomLabel!
    @IBOutlet weak var labelName: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromXib()
    }

    class CustomLabel: UILabel {
        override var text: String? {
            didSet {
                isHidden = text?.isEmpty == true
            }
        }
    }
}