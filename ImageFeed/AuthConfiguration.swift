//
//  AuthConfiguration.swift
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
    
    static var defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        // преобразуем строку в URL
        guard let defaultBaseURL = URL(string: Constants.defaultBaseURLString) else {
            fatalError("Failed to create URL from \(Constants.defaultBaseURLString)")
        }
        
        return AuthConfiguration(accessKey: Constants.accessKey,
                                secretKey: Constants.secretKey,
                                redirectURI: Constants.redirectURI,
                                accessScope: Constants.accessScope,
                                authURLString: Constants.unsplashAuthorizeURLString,
                                defaultBaseURL: defaultBaseURL)
    }
}
