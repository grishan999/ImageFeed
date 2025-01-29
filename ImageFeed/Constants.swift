//
//  Constants.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 15.01.2025.
//
import Foundation

enum Constants {
    static let accessKey: String = "ueFqHGYLUk-1vjmVtbsDWAvjX9kB2Q3eg6lkvlavODs"
    static let secretKey: String = "z1UfEJCr18Ev6q3gO-oJJLo1pIkQ0YCtHVQqM5IZOu8"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL: Unable to create URL from string")
        }
        return url
    }
}
