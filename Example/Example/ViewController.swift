//
//  ViewController.swift
//  Example
//
//  Created by Evegeny Kalashnikov on 08.03.2023.
//

import UIKit
import ChidoriMenu

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        view.addGestureRecognizer(recognizer)
    }

    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: view)

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        let stack = UIStackView(arrangedSubviews: [picker])
        let menu = ChidoriMenu(stackView: stack, anchorPoint: point)
        menu.show()
    }
}

