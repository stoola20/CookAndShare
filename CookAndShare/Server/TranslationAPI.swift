//
//  TranslationAPI.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/8.
//

import Foundation

enum TranslationAPI {
    case detectLanguage
    case translate
    case supportedLanguages

    func getURL() -> String {
        var urlString = ""

        switch self {
        case .detectLanguage:
            urlString = "https://translation.googleapis.com/language/translate/v2/detect"
        case .translate:
            urlString = "https://translation.googleapis.com/language/translate/v2"
        case .supportedLanguages:
            urlString = "https://translation.googleapis.com/language/translate/v2/languages"
        }

        return urlString
    }

    func getHTTPMethod() -> String {
        if self == .supportedLanguages {
            return "GET"
        } else {
            return "POST"
        }
    }
}
