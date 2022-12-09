//
//  CookAndShareTests.swift
//  CookAndShareTests
//
//  Created by Hsun Chen on 2022/12/9.
//

import XCTest
@testable import CookAndShare

class CookAndShareTests: XCTestCase {
    var sut: NewShareViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let storyboard = UIStoryboard(name: Constant.newpost, bundle: nil)
        sut = storyboard.instantiateViewController(identifier: String(describing: NewShareViewController.self)) as? NewShareViewController
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testCanPost() throws {
        sut.share = Share()
        let canPost = sut.canPost()
        XCTAssertFalse(canPost, "Should be false if share content is empty")
    }
}
