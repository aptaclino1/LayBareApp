//
//  SignUpVC.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var emailTextInput: UITextField!
    @IBOutlet weak var passwordTextInput: UITextField!
    @IBOutlet weak var confirmTextInput: UITextField!
    @IBOutlet weak var showConfirmPasswordButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextInput.becomeFirstResponder()
        updateShowHideButtonImage(for: passwordTextInput, button: showPasswordButton)
        updateShowHideButtonImage(for: confirmTextInput, button: showConfirmPasswordButton)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func showPassword(_ sender: UIButton) {
        toggleSecureTextEntry(for: passwordTextInput, button: showPasswordButton)
    }

    @IBAction func showConfirmPassword(_ sender: UIButton) {
        toggleSecureTextEntry(for: confirmTextInput, button: showConfirmPasswordButton)
    }

    @IBAction func nextButton(_ sender: UIButton) {
        guard let email = emailTextInput.text,
              let password = passwordTextInput.text,
              let confirmedPassword = confirmTextInput.text else {
            makeAlert(title: "Error!", message: "Username/Password/Email?")
            return
        }
        guard password == confirmedPassword else {
            makeAlert(title: "Error", message: "Passwords do not match.")
            return
        }
        do {
            try UserAccountManager.shared.createAccount(email: email, password: password, fullName: "", userImage: UIImage(named: "profileImage"))
            navigateToUploadScreen()
        } catch let error as UserAccountManagerError {
            makeAlert(title: "Error", message: error.localizedDescription)
        } catch {
            makeAlert(title: "Error", message: "Failed to create an account. \(error.localizedDescription)")
        }
    }
    
    @IBAction func signUpBttn(_ sender: UIButton) {
        guard let email = emailTextInput.text,
              let password = passwordTextInput.text,
              let confirmedPassword = confirmTextInput.text else {
            makeAlert(title: "Error!", message: "Username/Password/Email?")
            return
        }
        guard password == confirmedPassword else {
            makeAlert(title: "Error", message: "Passwords do not match.")
            return
        }
        do {
            try UserAccountManager.shared.createAccount(email: email, password: password, fullName: "", userImage: UIImage(named: "profileImage"))
            navigateToFeedScreen()
        } catch let error as UserAccountManagerError {
            makeAlert(title: "Error", message: error.localizedDescription)
        } catch {
            makeAlert(title: "Error", message: "Failed to create an account. \(error.localizedDescription)")
        }
    }

    private func toggleSecureTextEntry(for textField: UITextField, button: UIButton) {
        textField.isSecureTextEntry.toggle()
        updateShowHideButtonImage(for: textField, button: button)
    }

    private func updateShowHideButtonImage(for textField: UITextField, button: UIButton) {
        let imageName = textField.isSecureTextEntry ? "hide" : "see"
        button.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func navigateToUploadScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let uploadVC = storyboard.instantiateViewController(withIdentifier: "UploadVC") as? UploadVC {
            navigationController?.pushViewController(uploadVC, animated: true)
        }
    }
    private func navigateToFeedScreen() {
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        if let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedVC") as? FeedVC {
            navigationController?.pushViewController(feedVC, animated: true)
        }
    }

    private func makeAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}


  
