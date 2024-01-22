//
//  UserData.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let email: String
   
}

struct Photo: Codable {
    let albumId: Int
    let id: Int
    let title: String
    let url: String?
    let thumbnailUrl: String?
   

}

struct Comment: Codable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

struct PhotoWithComments: Codable {
    let photo: Photo
    let comments: [Comment]
}
