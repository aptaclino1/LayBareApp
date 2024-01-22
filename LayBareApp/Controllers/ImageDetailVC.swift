//
//  ImageDetailVC.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import UIKit

class ImageDetailVC: UIViewController {

    @IBOutlet weak var imageDetailTable: UITableView!
    @IBOutlet weak var colorImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var photoURL: URL?
    var photoTitle: String?
    var photoWithComments: PhotoWithComments?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
     
    }

    func fetchData() {
        guard photoURL != nil else {
            return
        }

        DataService.shared.fetchPhotosWithComments { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let photoWithCommentsArray):
                if let photoWithComments = photoWithCommentsArray.first {
                    self.photoWithComments = photoWithComments
                    DispatchQueue.main.async {
                        self.imageDetailTable.reloadData()
                        self.setupUI()
                    }
                }
            case .failure(let error):
                self.showAlert(title: "Error", message: "Failed to fetch data. \(error.localizedDescription)")
            }
        }
    }

    func setupUI() {
        titleLabel.text = photoTitle

        if let imageUrl = photoURL {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                if let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.colorImage.image = image
                    }
                }
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ImageDetailVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoWithComments?.comments.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageDetailCell", for: indexPath) as! ImageDetailCell

        if let comment = photoWithComments?.comments[indexPath.row] {
            cell.usernameLabel.text = comment.name
            cell.emailLabel.text = comment.email
            cell.commentLabel.text = comment.body
        } else {
            cell.usernameLabel.text = "Unknown User"
            cell.emailLabel.text = "Unknown Email"
            cell.commentLabel.text = "No Comment"
        }

        return cell
    }
}
