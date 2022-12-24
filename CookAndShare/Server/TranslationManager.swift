//
//  TranslationManager.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/8.
//

import Foundation
class TranslationManager: NSObject {
    static let shared = TranslationManager()
    var textToTranslate: String?
    let targetLanguage = "zh-TW"
    let sourceLanguage = "en"

    private override init() {
        super.init()
    }

    private func makeRequest(usingTranslationAPI api: TranslationAPI, urlParams: [String: String], completion: @escaping (_ results: [String: Any]?) -> Void) {
        if var components = URLComponents(string: api.getURL()) {
            components.queryItems = [URLQueryItem]()

            for (key, value) in urlParams {
                components.queryItems?.append(URLQueryItem(name: key, value: value))
            }

            if let url = components.url {
                var request = URLRequest(url: url)
                request.httpMethod = api.getHTTPMethod()

                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: request) { results, response, error in
                    if let error = error {
                        print(error)
                        completion(nil)
                    } else {
                        if let response = response as? HTTPURLResponse, let results = results {
                            if response.statusCode == 200 || response.statusCode == 201 {
                                do {
                                    if let resultsDict = try JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any] {
                                        print(resultsDict)
                                        completion(resultsDict)
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } else {
                            completion(nil)
                        }
                    }
                }
                task.resume()
            }
        }
    }

    func translate(completion: @escaping (_ translations: String?) -> Void) {
        guard let textToTranslate = textToTranslate else {
            completion(nil)
            return
        }

        var urlParams: [String: String] = [:]
        urlParams["key"] = APIKey.apiKey
        urlParams["q"] = textToTranslate
        urlParams["target"] = targetLanguage
        urlParams["source"] = sourceLanguage
        urlParams["format"] = "text"

        makeRequest(usingTranslationAPI: .translate, urlParams: urlParams) { [weak self] results in
            guard let self = self else { return }
            self.parseResult(result: results, completion: completion)
        }
    }

    func parseResult(result: [String: Any]?, completion: @escaping (_ translationText: String?) -> Void) {
        guard let result = result
        else {
            completion(nil)
            return
        }

        guard
            let data = result["data"] as? [String: Any],
            let translations = data["translations"] as? [[String: Any]]
        else {
            completion(nil)
            return
        }

        var allTranslations: [String] = []
        for translation in translations {
            guard let translatedText = translation["translatedText"] as? String else { return }
            allTranslations.append(translatedText)
        }

        if !allTranslations.isEmpty {
            completion(allTranslations[0])
        }
    }
}
