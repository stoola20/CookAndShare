//
//  UIViewController+Ext.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/12/16.
//

import UIKit

typealias AlertActionHandler = (UIAlertAction) -> Void

extension UIViewController {
    func presentAlertWith(alertTitle: String, alertMessage: String?, confirmTitle: String, cancelTitle: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .actionSheet
        )
        let confirmAction = UIAlertAction(title: confirmTitle, style: .destructive, handler: handler)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    func presentImagePickerAlert(camaraHandler: ((UIAlertAction) -> Void)?, photoLibraryHandler: ((UIAlertAction) -> Void)?) {
        let controller = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "相機", style: .default, handler: camaraHandler)
        let photoLibraryAction = UIAlertAction(title: "相簿", style: .default, handler: photoLibraryHandler)
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

    func presentSettingAlert(alertTitle: String, alertMessage: String, settingsAppURL: URL) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )
        let allowAction = UIAlertAction(
            title: "前往設定頁面",
            style: .cancel) { _ in
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }
        alert.addAction(UIAlertAction(title: "不用了，謝謝", style: .default))
        alert.addAction(allowAction)

        present(alert, animated: true)
    }
}
