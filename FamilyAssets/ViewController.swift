//
//  ViewController.swift
//  FamilyAssets
//
//  Created by Felicity Johnson on 9/8/18.
//  Copyright © 2018 FJ. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import WebKit

private struct Layout {
    static let logoSize: CGSize = CGSize(width: 100, height: 100)
    static let logoBottomOffset: CGFloat = 30
    static let textFieldWidthMultipler: CGFloat = 0.7
    static let textFieldHeight: CGFloat = 30
    static let textFieldBorderWidth: CGFloat = 1.5
    static let textFieldCornerRadius: CGFloat = 5
    static let submitButtonWidth: CGFloat = 100
}

final class ViewController: UIViewController, UINavigationControllerDelegate, WKUIDelegate, WKNavigationDelegate {
    
    private let logo = UIImageView()
    private let textField = TextField()
    private let submitButton = UIButton()
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let hud = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.toolbarManageBehaviour = .byPosition
        
        setUpView()
        setUpDismissKeyboard()
    }
    
    private func setUpView() {
        logo.image = UIImage(imageLiteralResourceName: "FamilyAssetsIcon")
        logo.contentMode = .scaleAspectFill
        
        if let code = UserDefaults.standard.string(forKey: "code") {
            textField.text = code
        } else {
            textField.placeholder = "Enter Code"
        }
        
        textField.keyboardType = .numberPad
        textField.textColor = .black
        textField.layer.cornerRadius = Layout.textFieldCornerRadius
        textField.layer.borderWidth = Layout.textFieldBorderWidth
        textField.layer.borderColor = UIColor.black.cgColor
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        submitButton.backgroundColor = .black
        submitButton.titleLabel?.textColor = .white
        
        webView.uiDelegate = self
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        view.addSubview(logo)
        view.addSubview(textField)
        view.addSubview(submitButton)
        
        logo.snp.makeConstraints { make in
            make.size.equalTo(Layout.logoSize)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(textField.snp.top).offset(-Layout.logoBottomOffset)
        }
        
        textField.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(Layout.textFieldHeight)
            make.width.equalToSuperview().multipliedBy(Layout.textFieldWidthMultipler)
        }
        
        submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.textFieldHeight)
            make.width.equalTo(Layout.submitButtonWidth)
            make.top.equalTo(textField.snp.bottom).offset(Layout.logoBottomOffset)
        }
    }
    
    private func setUpDismissKeyboard() {
        let gesture = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func dismissKeyboard() {
        if textField.isEditing {
            textField.resignFirstResponder()
        }
    }
    
    @objc private func submit() {
        let baseURL = "https://www.familyassets.com/s/request/"
        
        let noTextAlert = UIAlertController(title: "Oops", message: "You must input a code.", preferredStyle: UIAlertControllerStyle.alert)
        
        guard let text = textField.text, text != "" else {
            noTextAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(noTextAlert, animated: true, completion: nil)
            return
        }
        
        UserDefaults.standard.set(text, forKey: "code")
        
        let fullURL = baseURL + text
        
        let webpageLoadAlert = UIAlertController(title: "Oops", message: "Something went wrong loading the page. Please verify the inputted code and try again.", preferredStyle: UIAlertControllerStyle.alert)
        guard let url = URL(string: fullURL) else {
            webpageLoadAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(webpageLoadAlert, animated: true, completion: nil)
            return
        }
        
        print("URL: \(url)")
        
        hud.center = view.center
        hud.startAnimating()
        view.addSubview(hud)
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hud.stopAnimating()
        hud.removeFromSuperview()
        
        let vc = UIViewController()
        vc.view = webView
        vc.view.backgroundColor = .black
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
