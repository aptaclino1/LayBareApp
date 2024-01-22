//
//  DataService.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import Foundation

extension Comment {
    func asDictionary() -> [String: Any] {
        return [
            "postId": postId,
            "id": id,
            "name": name,
            "email": email,
            "body": body
        ]
    }
}

enum DataServiceError: Error {
    case network(Error)
    case httpResponseError
    case invalidData
    case decoding
}

class DataService {
    static let shared = DataService()

    private let customSession: URLSession

    private init() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 30
        customSession = URLSession(configuration: sessionConfiguration)
    }

    func fetchUsers(completion: @escaping (Result<[User], DataServiceError>) -> Void) {
        fetch(url: URL(string: "https://jsonplaceholder.typicode.com/users")!, completion: completion)
    }

    func fetchUserDetails(userId: Int, completion: @escaping (Result<User, DataServiceError>) -> Void) {
        fetch(url: URL(string: "https://jsonplaceholder.typicode.com/users/\(userId)")!) { (result: Result<User, DataServiceError>) in
            switch result {
            case .success(let fetchedUser):
                completion(.success(fetchedUser))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchComments(maxCommentsPerPhoto: Int = 10, completion: @escaping (Result<[Comment], DataServiceError>) -> Void) {
        fetch(url: URL(string: "https://jsonplaceholder.typicode.com/comments")!) { (result: Result<[Comment], DataServiceError>) in
            switch result {
                case .success(let fetchedComments):
                    let processedComments = self.processCommentsForPhotos(comments: fetchedComments, maxCommentsPerPhoto: maxCommentsPerPhoto)
                    completion(.success(processedComments))
                case .failure(let error):
                    print("Error fetching comments: \(error)")
                    completion(.failure(error))
            }
        }
    }

    func fetchPhotos(completion: @escaping (Result<[Photo], DataServiceError>) -> Void) {
        fetch(url: URL(string: "https://jsonplaceholder.typicode.com/photos")!) { (result: Result<[Photo], DataServiceError>) in
            switch result {
            case .success(let fetchedPhotos):
                completion(.success(fetchedPhotos))
            case .failure(let error):
                print("Error fetching photos: \(error)")
                completion(.failure(error))
            }
        }
    }

    func fetchPhotosWithComments(completion: @escaping (Result<[PhotoWithComments], DataServiceError>) -> Void) {
        let group = DispatchGroup()

        var photos: [Photo]?
        var commentsData: [[String: Any]]?

        group.enter()
        fetchPhotos { (result: Result<[Photo], DataServiceError>) in
            switch result {
            case .success(let fetchedPhotos):
                photos = fetchedPhotos
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
            group.leave()
        }

        group.enter()
        fetchComments { (result: Result<[Comment], DataServiceError>) in
            switch result {
            case .success(let fetchedComments):
                commentsData = fetchedComments.map { $0.asDictionary() }
            case .failure(let error):
                print("Error fetching comments: \(error)")
            }
            group.leave()
        }

        group.notify(queue: .main) {
            guard let photos = photos, let commentsData = commentsData else {
                completion(.failure(.invalidData))
                return
            }

            var photoWithCommentsArray: [PhotoWithComments] = []

            for photo in photos {
                var dummyComments: [Comment] = []

                let photoCommentsData = commentsData.filter { $0["postId"] as? Int == photo.id }

                for commentData in photoCommentsData.prefix(10) {
                    if let name = commentData["name"] as? String,
                       let email = commentData["email"] as? String,
                       let body = commentData["body"] as? String {
                        let dummyComment = Comment(id: commentData["id"] as? Int ?? 0,
                                                   postId: photo.id,
                                                   name: name,
                                                   email: email,
                                                   body: body)
                        dummyComments.append(dummyComment)
                    }
                }

                let photoWithComments = PhotoWithComments(photo: photo, comments: dummyComments)
                photoWithCommentsArray.append(photoWithComments)
            }

            completion(.success(photoWithCommentsArray))
        }
    }


    private func fetchCommentsForPhoto(photoId: Int, completion: @escaping (Result<[Comment], DataServiceError>) -> Void) {
        fetch(url: URL(string: "https://jsonplaceholder.typicode.com/comments?postId=\(photoId)")!) { (result: Result<[Comment], DataServiceError>) in
            switch result {
            case .success(let fetchedComments):
                completion(.success(fetchedComments))
            case .failure(let error):
                print("Error fetching comments: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func processCommentsForPhotos(comments: [Comment], maxCommentsPerPhoto: Int) -> [Comment] {
        var commentsByPhotoId: [Int: [Comment]] = [:]
        for comment in comments {
            if var existingComments = commentsByPhotoId[comment.postId] {
                existingComments.append(comment)
                commentsByPhotoId[comment.postId] = existingComments
            } else {
                commentsByPhotoId[comment.postId] = [comment]
            }
        }
        var processedComments: [Comment] = []
        for (_, commentsForPhoto) in commentsByPhotoId.prefix(while: { _, comments in comments.count > 0 }) {
            processedComments += commentsForPhoto.prefix(maxCommentsPerPhoto)
        }
        return processedComments
    }

    private func fetch<T: Codable>(url: URL, completion: @escaping (Result<T, DataServiceError>) -> Void) {
        customSession.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.network(error ?? NSError(domain: "Unknown error", code: 0, userInfo: nil))))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decoding))
            }
        }.resume()
    }
}

