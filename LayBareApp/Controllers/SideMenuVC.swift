//
//  SideMenuVC.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import UIKit

class SideMenuVC: UIViewController {

    @IBOutlet weak var logoutBttn: UIButton!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenuUI()
        if let image = UserAccountManager.shared.getUserImage() {
            profileImage.image = image
        }
        if let fullName = UserAccountManager.shared.getFullName() {
            nameLabel.text = fullName
        }
        logoutBttn.isUserInteractionEnabled = true
    }
    
  
    
    
    private func setupSideMenuUI() {
        self.profileImage.layer.cornerRadius = 25
        self.profileImage.clipsToBounds = true
        mainView.layer.borderColor = CGColor(red: 0000, green: 0000, blue: 0000, alpha: 1)
        mainView.layer.borderWidth = 2
    }
    

    @IBAction func logOutButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "SignInVC") as? SignInVC {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true, completion: nil)
        }
        print("Logout!")
    }
}
