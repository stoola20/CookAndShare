//
//  JWTClaims.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/23.
//

import SwiftJWT
import Foundation

struct JWTClaims: Claims {
    let iss: String
    let iat: Date
    let exp: Date
    let aud: String
    let sub: String
}
