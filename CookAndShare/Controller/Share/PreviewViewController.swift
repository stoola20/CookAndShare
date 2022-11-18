//
//  PreviewViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/18.
//

import UIKit

class PreviewViewController: UIViewController {
    var imageURL = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFill
        imageView.loadImage(imageURL, placeHolder: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let widthScale = view.bounds.width / imageView.bounds.width

        scrollView.minimumZoomScale = widthScale
        scrollView.zoomScale = widthScale
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

    func updateContentInset() {
        let imageViewSize = imageView.frame.size
        let viewSize = view.bounds.size

        let verticalPadding = imageViewSize.height < viewSize.height
            ? (viewSize.height - imageViewSize.height) / 2
            : 0
        let horizontalPadding = imageViewSize.width < viewSize.width
            ? (viewSize.width - imageViewSize.width) / 2
            : 0

        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
    }
}

extension PreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
}
