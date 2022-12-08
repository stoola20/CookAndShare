//
//  TranslationAPITest.swift
//  TranslationTests
//
//  Created by Hsun Chen on 2022/12/9.
//

import XCTest
@testable import CookAndShare

class TranslationAPITest: XCTestCase {
    var sut: URLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = URLSession.shared
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testTranslationApiStatusCode200() throws {
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?

        let textToTranslate = "sushi"
        let translateApi = TranslationAPI.translate

        var urlParams: [String: String] = [:]
        urlParams["key"] = APIKey.apiKey
        urlParams["q"] = textToTranslate
        urlParams["target"] = TranslationManager.shared.targetLanguage
        urlParams["source"] = TranslationManager.shared.sourceLanguage
        urlParams["format"] = "text"

        guard var components = URLComponents(string: translateApi.getURL()) else { return }
        components.queryItems = [URLQueryItem]()

        for (key, value) in urlParams {
            components.queryItems?.append(URLQueryItem(name: key, value: value))
        }

        guard let url = components.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = translateApi.getHTTPMethod()

        let task = sut.dataTask(with: request) { _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        task.resume()
        wait(for: [promise], timeout: 5)

        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
}
