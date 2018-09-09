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
    static let privacyOffset: CGFloat = 5
    static let termsOffset: CGFloat = 100
    static let termsOfServiceURL: String = "https://www.familyassets.com/terms"
    static let privacyURL: String = "https://www.familyassets.com/privacy"
    static let baseURL: String = "https://www.familyassets.com/s/request/"
}

final class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UITextViewDelegate {
    
    private let logo = UIImageView()
    private let textField = TextField()
    private let submitButton = UIButton()
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let hud = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    private let privacyAttributedTextView = UITextView()
    private let termsAttributedTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.toolbarManageBehaviour = .byPosition
        
        setUpView()
        setUpDismissKeyboard()
    }
    
    private func setUpView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        
        let privacyPolicy = "Privacy Policy"
        if let url = URL(string: Layout.privacyURL) {
            let privacyAttributedString = NSMutableAttributedString(string: privacyPolicy, attributes:
                [NSAttributedStringKey.link: url,
                 NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)])
            
            privacyAttributedTextView.attributedText = privacyAttributedString
            privacyAttributedTextView.isScrollEnabled = false
            privacyAttributedTextView.textAlignment = .center
            privacyAttributedTextView.textColor = .black
            privacyAttributedTextView.delegate = self
            privacyAttributedTextView.isEditable = false
        }
        
        let termsOfService = "Terms of Service"
        if let url = URL(string: Layout.termsOfServiceURL) {
            let termsAttributedString = NSMutableAttributedString(string: termsOfService, attributes:
                [NSAttributedStringKey.link: url,
                 NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)])
            
            termsAttributedTextView.attributedText = termsAttributedString
            termsAttributedTextView.textAlignment = .center
            termsAttributedTextView.isScrollEnabled = false
            termsAttributedTextView.delegate = self
            termsAttributedTextView.isEditable = false
        }
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        view.addSubview(logo)
        view.addSubview(textField)
        view.addSubview(submitButton)
        view.addSubview(privacyAttributedTextView)
        view.addSubview(termsAttributedTextView)
        
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
        
        privacyAttributedTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(termsAttributedTextView.snp.top).offset(-Layout.privacyOffset)
        }
        
        termsAttributedTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Layout.termsOffset)
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
        
        let noTextAlert = UIAlertController(title: "Oops", message: "You must input a code.", preferredStyle: UIAlertControllerStyle.alert)
        
        guard let text = textField.text, text != "" else {
            noTextAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(noTextAlert, animated: true, completion: nil)
            return
        }
        
        UserDefaults.standard.set(text, forKey: "code")
        
        let fullURL = Layout.baseURL + text
        
        let webpageLoadAlert = UIAlertController(title: "Oops", message: "Something went wrong loading the page. Please verify the inputted code and try again.", preferredStyle: UIAlertControllerStyle.alert)
        guard let url = URL(string: fullURL) else {
            webpageLoadAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(webpageLoadAlert, animated: true, completion: nil)
            return
        }
                
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
        
        if let url = webView.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        
        return false
    }
    
}
