//
//  ProfileViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, CellTitled, UITextFieldDelegate {
    
    // MARK: - Properties
    var titleForCell = "LOGIN/REGISTER"
    var activeField: UITextField?
    var ref: FIRDatabaseReference!
    var propertyAnimator: UIViewPropertyAnimator?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        _ = [usernameContainerView, passwordContainerView, loginButton, registerButton].map { $0.isHidden = true }
        _ = [usernameContainerView, passwordContainerView, loginButton, registerButton].map { $0.alpha = 0.3 }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.propertyAnimator = UIViewPropertyAnimator(duration: 1.8, dampingRatio: 0.75, animations: nil)
        
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = [usernameContainerView, passwordContainerView, loginButton, registerButton].map { $0.isHidden = false }

        self.animateLogo()
        
        self.addPropertyAnimations()
        self.startAnimations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    // MARK: - Setup View Hierarchy & Constraints
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.backgroundColor = ColorPalette.darkPrimaryColor
        navigationController?.navigationBar.barTintColor = ColorPalette.darkPrimaryColor
        self.navigationItem.title = titleForCell
        self.view.backgroundColor = ColorPalette.primaryColor
        
        view.addSubview(UPicLogo)
        view.addSubview(usernameContainerView)
        view.addSubview(passwordContainerView)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        usernameContainerView.addSubview(usernameTextField)
        passwordContainerView.addSubview(passwordTextField)
        
        loginButton.addTarget(self, action: #selector(didTapLogin(sender:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister(sender:)), for: .touchUpInside)
    }
    
    func configureConstraints() {
        // Image View
        UPicLogo.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 175.0, height: 175.0))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40.0)
        }
        
        // Containers
        usernameContainerView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44.0)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.UPicLogo.snp.bottom).offset(24.0)
        }
        
        passwordContainerView.snp.makeConstraints { (make) in
            make.width.equalTo(self.usernameContainerView.snp.width)
            make.height.equalTo(self.usernameContainerView.snp.height)
            make.top.equalTo(self.usernameContainerView.snp.bottom).offset(16.0)
            make.trailing.equalTo(self.usernameContainerView.snp.trailing)
        }
        
        // Textfields
        usernameTextField.snp.makeConstraints { (make) in
            make.leading.top.equalTo(usernameContainerView).offset(4.0)
            make.trailing.bottom.equalTo(usernameContainerView).inset(4.0)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.leading.top.equalTo(passwordContainerView).offset(4.0)
            make.trailing.bottom.equalTo(passwordContainerView).inset(4.0)
        }
        
        // Buttons
        registerButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(60.0)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16.0)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(registerButton)
            make.bottom.equalToSuperview().inset(85.0)
        }
    }
    
    // MARK: - Property Animations
    internal func addPropertyAnimations() {
        
        propertyAnimator?.addAnimations ({
            self.usernameContainerView.alpha = 1.0
            self.passwordContainerView.alpha = 1.0
            self.loginButton.alpha = 1.0
            self.registerButton.alpha = 1.0
        }, delayFactor: 0.3)
        self.view.layoutIfNeeded()
    }
    
    internal func animateLogo() {
    
        UIView.animate(withDuration: 0.25, delay: 0.2, options: .autoreverse, animations: {
            
            let scale = CGAffineTransform(scaleX: 0.2, y: 0.2)
            let rotation = CGAffineTransform(rotationAngle: CGFloat.pi + CGFloat.pi/2)
            let combined = scale.concatenating(rotation)
            self.UPicLogo.transform = combined
            }, completion: { finished in
                self.UPicLogo.transform = CGAffineTransform.identity
            })
        
        UIView.animate(withDuration: 0.15, delay: 0.2, animations: {
            self.view.backgroundColor = .white
            }, completion: {
                finished in
                self.view.backgroundColor = ColorPalette.primaryColor
        })
        
        self.view.layoutIfNeeded()
    }
    
    internal func startAnimations() {
        self.view.layoutIfNeeded()
        propertyAnimator?.startAnimation()
        usernameTextField.styled(placeholder: "username")
        passwordTextField.styled(placeholder: "password")
        loginButton.styled(title: "login")
        registerButton.styled(title: "register")
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        activeField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    // MARK: - Actions
    func didTapLogin(sender: UIButton) {
        self.ref = FIRDatabase.database().reference()
        
        if let password = self.passwordTextField.text, let email = self.usernameTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                if user != nil {
                    self.navigationController?.pushViewController(LoggedInViewController(), animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                }
            })
        }
    }
    
    func didTapRegister(sender: UIButton) {
        self.present(RegisterViewController(), animated: true, completion: nil)
    }
    
    // MARK: - Lazy Instantiates
    // Logo Image View
    lazy var UPicLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = #imageLiteral(resourceName: "logo")
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    // Textfields
    internal lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        return textField
    }()
    
    // Containers
    internal lazy var usernameContainerView: UIView = {
        let view: UIView = UIView()
        return view
    }()
    
    internal lazy var passwordContainerView: UIView = {
        let view: UIView = UIView()
        return view
    }()
    
    // Buttons
    internal lazy var loginButton: UIButton = {
        let button: UIButton = UIButton()
        return button
    }()
    
    internal lazy var registerButton: UIButton = {
        let button: UIButton = UIButton()
        return button
    }()
}


