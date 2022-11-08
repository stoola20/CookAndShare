//
//  FoodRecognitionViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/8.
//

import UIKit

class FoodRecognitionViewController: UIViewController {
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        foodImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseSourceType))
        foodImageView.addGestureRecognizer(tap)

        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        retakeButton.isHidden = true
        searchButton.isHidden = true
    }

    @objc func chooseSourceType() {
        let controller = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cameraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }

    @IBAction func searchRecipe(_ sender: UIButton) {
    }

    @IBAction func retakePhoto(_ sender: UIButton) {
    }
}

extension FoodRecognitionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        foodImageView.image = userPickedImage
        guard let ciimage = CIImage(image: userPickedImage) else {
            fatalError("Could not create ciimage")
        }
//        detect(image: ciimage)
        dismiss(animated: true)
    }
}
