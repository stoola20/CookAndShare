//
//  FoodRecognitionViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/8.
//

import UIKit
import Vision
import CoreML
import SPAlert
import Lottie

class FoodRecognitionViewController: UIViewController {
    let imagePicker = UIImagePickerController()
    var recognizedResult = ""

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var animationView: LottieAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()

        foodImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseSourceType))

        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        retakeButton.isHidden = true
        retakeButton.addTarget(self, action: #selector(chooseSourceType), for: .touchUpInside)
        searchButton.isHidden = true

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
        animationView.addGestureRecognizer(tap)
    }

    func setUpUI() {
        resultLabel.textColor = UIColor.darkBrown
        resultLabel.font = UIFont.boldSystemFont(ofSize: 20)

        retakeButton.layer.cornerRadius = retakeButton.bounds.height / 2
        retakeButton.backgroundColor = UIColor.lightOrange

        searchButton.layer.cornerRadius = searchButton.bounds.height / 2
        searchButton.backgroundColor = UIColor.lightOrange
    }

    @objc func chooseSourceType() {
        let controller = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "相機", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "相簿", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cameraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(cancelAction)

        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        present(controller, animated: true, completion: nil)
    }

    @IBAction func searchRecipe(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: Constant.recipe, bundle: nil)
        guard
            let resultVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: ResultViewController.self)
            )
                as? ResultViewController
        else { fatalError("Could not instantiate resultVC") }
        resultVC.searchString = recognizedResult
        resultVC.searchType = .camera
        navigationController?.pushViewController(resultVC, animated: true)
    }

    func detect(image: CIImage) {
        guard
            let modelURL = Bundle.main.url(forResource: "SeeFood", withExtension: "mlmodelc"),
            let model = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL))
        else { fatalError("Could not create model") }

        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            guard let self = self else { return }
            guard let results = request.results as? [VNClassificationObservation]
            else { fatalError("Model failed to process image") }
            if let firstResult = results.first {
                if firstResult.confidence > 0.5 {
                    let alertView = SPAlertView(message: "辨識成功")
                    alertView.duration = 1
                    alertView.present()
                    TranslationManager.shared.textToTranslate = firstResult.identifier
                    TranslationManager.shared.translate { translation in
                        guard let translation = translation else {
                            return
                        }
                        DispatchQueue.main.async { [unowned self] in
                            self.recognizedResult = translation
                            self.resultLabel.text = "辨識結果：\(translation)"
                        }
                    }
                    self.searchButton.isHidden = false
                } else {
                    SPAlert.present(message: "無法辨識", haptic: .error)
                    self.resultLabel.text = "照片無法被辨識，請嘗試重新拍攝"
                    self.searchButton.isHidden = true
                }
                self.retakeButton.isHidden = false
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

extension FoodRecognitionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        foodImageView.image = userPickedImage
        animationView.isHidden = true
        guard let ciimage = CIImage(image: userPickedImage) else {
            fatalError("Could not create ciimage")
        }
        detect(image: ciimage)
        dismiss(animated: true)
    }
}
