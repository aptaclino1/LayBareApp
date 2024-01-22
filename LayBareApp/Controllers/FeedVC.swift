//
//  FeedVC.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import UIKit

class FeedVC: UIViewController {

    @IBOutlet weak var photoTable: UITableView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var users: [User] = []
    var photos: [Photo] = []
    var menuOut = false
  

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        navigationItem.title = "Image Tiles"
        self.sideMenuView.isHidden = true
        menuOut = true
}
    
    @IBAction func sideMenuTapped(_ sender: Any) {
        sideMenuView.isHidden = false
        containerView.isHidden = false
        if !menuOut {
          menuOut = true
            sideMenuView.frame = CGRect(x: 0, y: 88, width: 0, height: 716)
            containerView.frame = CGRect(x: 0, y: 0, width: 0, height: 716)
            UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveEaseIn) {
                self.sideMenuView.frame = CGRect(x: 0, y: 88, width: 280, height: 716)
                self.containerView.frame = CGRect(x: 0, y: 88, width: 280, height: 716)
                }
        } else {
            sideMenuView.isHidden = true
            containerView.isHidden = true
            menuOut = false
              sideMenuView.frame = CGRect(x: 0, y: 58, width: 0, height: 716)
              containerView.frame = CGRect(x: 0, y: 0, width: 0, height: 716)
            UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveEaseIn) {
            self.sideMenuView.frame = CGRect(x: 0, y: 58, width: 280, height: 716)
            self.containerView.frame = CGRect(x: 0, y: 58, width: 280, height: 716)
            }
        }
        }



    private func fetchData() {
        DataService.shared.fetchUsers { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let users):
                self.users = users
            case .failure(let error):
                print("Error fetching users: \(error)")
            }

            self.fetchOtherData()
        }
    }

    private func fetchOtherData() {
        DataService.shared.fetchPhotos { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let photoArray):
                self.photos = photoArray
                DispatchQueue.main.async {
                    self.photoTable.reloadData()
                }
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
        }
    }
}

extension FeedVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let photo = photos[indexPath.row]
        if let imageUrlString = photo.url, !imageUrlString.isEmpty {
            cell.colorImages.loadImage(fromURL: imageUrlString)
        } else {
            print("Invalid image URL")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPhoto = photos[indexPath.row]
        showDetailsViewController(for: selectedPhoto)
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }

    private func showDetailsViewController(for photo: Photo) {
        let detailsViewController = UIStoryboard(name: "Feed", bundle: nil).instantiateViewController(withIdentifier: "ImageDetailVC") as! ImageDetailVC
        detailsViewController.photoURL = URL(string: photo.url ?? "")
        detailsViewController.photoTitle = photo.title
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

extension UIImageView {
    func loadImage(fromURL urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error loading image: \(error)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to create image from data")
                return
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
