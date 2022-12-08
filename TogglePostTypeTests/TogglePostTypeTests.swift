//
//  TogglePostTypeTests.swift
//  TogglePostTypeTests
//
//  Created by Hsun Chen on 2022/12/9.
//

import XCTest
@testable import CookAndShare

class TogglePostTypeTests: XCTestCase {
    var sut: PublicProfileViewController!
    var headerView: PublicPostHeaderView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let storyboard = UIStoryboard(name: Constant.profile, bundle: nil)
        sut = storyboard.instantiateViewController(
            identifier: String(describing: PublicProfileViewController.self)
        )
        as? PublicProfileViewController
        headerView = PublicPostHeaderView()
        headerView.delegate = sut
    }

    override func tearDownWithError() throws {
        sut = nil
        headerView = nil
        try super.tearDownWithError()
    }

    func testPostTypeBeChanged() {
        let button = UIButton()
        XCTAssertEqual(
            sut.toRecipe,
            true,
            "ToRecipe should be true before sendActions")
        button.addTarget(headerView, action: #selector(PublicPostHeaderView.changeToShare(_:)), for: .touchUpInside)
        button.sendActions(for: .touchUpInside)
        XCTAssertEqual(
            sut.toRecipe,
            false,
            "ToRecipe should be false after change to share")
    }
}
