//
//  TranslationTests.swift
//  TranslationTests
//
//  Created by Hsun Chen on 2022/12/9.
//

import XCTest
@testable import CookAndShare

class TranslationTests: XCTestCase {
    var sut: TranslationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TranslationManager.shared
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testTextBeTranslated() {
        let result = [
            "data": [
                "translations": [
                    ["translatedText": "\u{4ee4}\u{5091}"],
                    ["translatedText": "\u{5b54}"],
                    ["translatedText": "\u{6c23}\u{6b7b}"]
                ]
            ]
        ]
        sut.parseResult(result: result) { translationText in
            XCTAssertEqual(translationText, "令傑")
        }
    }
}
