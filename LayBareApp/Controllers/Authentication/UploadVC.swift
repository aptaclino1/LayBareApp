//
//  UploadVC.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//
import UIKit


class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var fullNameTextInput: UITextField!
    @IBOutlet weak var usernameTextInput: UITextField!

    private let fullNameKey = "fullName"
    private let usernameKey = "username"

    var email: String?
    var password: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        fullNameTextInput.becomeFirstResponder()
        fullNameTextInput.isUserInteractionEnabled = true
        usernameTextInput.text = nil
        fullNameTextInput.text = nil

        uploadImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showImagePicker))
        uploadImage.addGestureRecognizer(gestureRecognizer)
    }

    @IBAction func signInButton(_ sender: UIButton) {
        guard let fullName = fullNameTextInput.text, !fullName.isEmpty,
              let username = usernameTextInput.text, !username.isEmpty else {
            showAlert(title: "Error", message: "Please enter both full name and username.")
            return
        }
        saveUserInformation(fullName: fullName, username: username)
        navigateToNextScreen()
    }

    func saveUserInformation(fullName: String, username: String) {
        UserDefaults.standard.set(fullName, forKey: fullNameKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
    }

    func navigateToNextScreen() {
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        if let viewController = storyboard.instantiateInitialViewController() {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true, completion: nil)
        }
    }

    @objc func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            UserAccountManager.shared.setUserImage(selectedImage)
            uploadImage.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
