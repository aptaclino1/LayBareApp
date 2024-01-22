//
//  SignInVC.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import UIKit

class SignInVC: UIViewController {

    @IBOutlet weak var emailTextInput: UITextField!
    @IBOutlet weak var passwordTextInput: UITextField!
    @IBOutlet weak var showHideBttn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextInput.becomeFirstResponder()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        updateShowHideButtonImage()
    }

    @IBAction func showPassword(_ sender: UIButton) {
        passwordTextInput?.isSecureTextEntry.toggle()
        updateShowHideButtonImage()
    }

    @IBAction func logInButton(_ sender: UIButton) {
        guard let email = emailTextInput.text, let password = passwordTextInput.text else {
            makeAlert(title: "Error", message: "Password/Email cannot be empty.")
            return
        }

        do {
            let loginSuccess = try UserAccountManager.shared.login(email: email, password: password)

                    if loginSuccess {
                        navigateToFeedScreen()
                    } else {
                        makeAlert(title: "Error", message: "Login failed for an unknown reason.")
                    }
                } catch UserAccountManagerError.invalidCredentials {
                    makeAlert(title: "Error", message: "Invalid email or password. Please try again.")
                } catch {
                    print("Login failed with unknown error: \(error)")
                    makeAlert(title: "Error", message: "An unknown error occurred during login.")
                }
    }
    private func navigateToFeedScreen() {
        print("Navigating to FeedVC")
        
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        if let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedVC") as? FeedVC {
            print("FeedVC instantiated successfully")
            
            feedVC.modalPresentationStyle = .fullScreen
            present(feedVC, animated: true, completion: nil)
        } else {
            print("Failed to instantiate FeedVC from storyboard")
        }
    }

    func updateShowHideButtonImage() {
        guard let passwordTextInput = passwordTextInput, let showHideBttn = showHideBttn else {
               return
           }
           let imageName = passwordTextInput.isSecureTextEntry ? "hide" : "see"
           showHideBttn.setImage(UIImage(named: imageName), for: .normal)
    }

    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


