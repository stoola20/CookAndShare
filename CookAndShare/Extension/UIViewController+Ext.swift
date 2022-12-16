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
}
