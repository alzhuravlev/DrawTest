//
//  ViewController.swift
//  BlueprintTest
//
//  Created by Aleksei Zhuravlev on 12.10.2023.
//

import UIKit

class ViewController: UIViewController {
    private var editorView: AnnotationsEditorView?

    private func setupViews() {
        view.backgroundColor = UIColor.white

//        let data = NSDataAsset(name: "Image1")?.data
        let data = NSDataAsset(name: "Pdf2")?.data
        if let data {
            editorView = AnnotationsEditorView(data: data)
        }

        let content: UIView
        if let editorView {
            content = editorView
        } else {
            let textView = UITextView()
            textView.text = "Error loading file"
            content = textView
        }

        
        content.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
//        imageView.layer.setNeedsDisplay()
    }
}
