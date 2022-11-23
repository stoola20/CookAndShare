//
//  Params.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/23.
//

import Foundation

struct RefreshTokenParam: Codable {
    let clientId: String
    let clientSecret: String
    let code: String
    let grantType: String

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
        case grantType = "grant_type"
    }
}

struct RefreshResponse: Codable {
    let accessToken, tokenType: String
    let expiresIn: Int
    let refreshToken, idToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
    }
}
