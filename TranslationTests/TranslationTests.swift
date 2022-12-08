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
        sut.textToTranslate = "sushi"
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testTextBeTranslated() {
        let promise = expectation(description: "Completion handler invoked")

        sut.translate { translations in
            XCTAssertEqual(translations, "壽司")
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
    }
}
