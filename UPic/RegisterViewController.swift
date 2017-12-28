//
//  RegisterViewController.swift
//  UPic
//
//  Created by Marcel Chaucer on 2/7/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class RegisterViewController: UIViewController, CellTitled, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var titleForCell = "REGISTER"
    var ref: FIRDatabaseReference!
    var activeField: UITextField?
    var propertyAnimator: UIViewPropertyAnimator?
    var dynamicAnimator: UIDynamicAnimator?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureConstraints()
        self.propertyAnimator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.75, animations: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        usernameTextField.styled(placeholder: "username")
        emailTextField.styled(placeholder: "email")
        passwordTextField.styled(placeholder: "password")
        doneButton.styled(title: "done")
        cancelButton.styled(title: "cancel")
    }
    
    // MARK: - Setup View Hierarchy & Contraints
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
        
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        view.addSubview(emailTextField)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(profilePic)
        view.addSubview(validUsernameLabel)
        view.addSubview(validEmailLabel)
        view.addSubview(validPasswordLabel)
        
        doneButton.addTarget(self, action: #selector(didTapDone(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancel(sender:)), for: .touchUpInside)
        profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))
    }
    
    func configureConstraints() {
        // Image View
        profilePic.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 200.0, height: 200.0))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(75.0)
        }
        
        // Text Fields
        usernameTextField.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44.0)
            make.centerX.equalToSuperview()
            make.top.equalTo(profilePic.snp.bottom).offset(44.0)
        }
        
        emailTextField.snp.makeConstraints { (make) in
            make.width.equalTo(usernameTextField.snp.width)
            make.height.equalTo(usernameTextField.snp.height)
            make.centerX.equalToSuperview()
            make.top.equalTo(usernameTextField.snp.bottom).offset(20.0)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.width.equalTo(emailTextField.snp.width)
            make.height.equalTo(emailTextField.snp.height)
            make.centerX.equalToSuperview()
            make.top.equalTo(emailTextField.snp.bottom).offset(20.0)
        }
        
        // Buttons
        doneButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(cancelButton)
            make.height.equalTo(cancelButton)
            make.bottom.equalToSuperview().inset(85.0)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(60.0)
            make.bottom.equalTo(self.view.snp.bottom).inset(16.0)
        }
        
        // Labels
        validUsernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTextField.snp.bottom)
            make.leading.equalTo(usernameTextField)
            make.width.equalTo(usernameTextField)
            make.height.equalTo(0.0)
        }
        
        validEmailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom)
            make.leading.equalTo(emailTextField)
            make.width.equalTo(emailTextField)
            make.height.equalTo(0.0)
        }
        
        validPasswordLabel.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom)
            make.leading.equalTo(passwordTextField)
            make.width.equalTo(passwordTextField)
            make.height.equalTo(0.0)
        }
    }
    
    //MARK:- UITextFieldDelegate
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case usernameTextField:
            if (usernameTextField.text?.characters.count)! > 2 {
                
                propertyAnimator?.addAnimations {
                    self.validUsernameLabel.snp.remakeConstraints({ (make) in
                        make.top.equalTo(self.usernameTextField.snp.bottom)
                        make.leading.equalTo(self.usernameTextField)
                        make.width.equalTo(self.usernameTextField)
                        make.height.equalTo(0.0)
                    })
                    self.view.layoutIfNeeded()
                }
                
                propertyAnimator?.startAnimation()
            }
        case emailTextField:
            if isValidEmail(email: emailTextField.text!) {
                
                propertyAnimator?.addAnimations {
                    self.validEmailLabel.snp.remakeConstraints({ (make) in
                        make.top.equalTo(self.emailTextField.snp.bottom)
                        make.leading.equalTo(self.emailTextField)
                        make.width.equalTo(self.emailTextField)
                        make.height.equalTo(0.0)
                    })
                    self.view.layoutIfNeeded()
                }
                
                propertyAnimator?.startAnimation()
            }
        default:
            if (passwordTextField.text?.characters.count)! > 4 {
                
                propertyAnimator?.addAnimations {
                    self.validPasswordLabel.snp.remakeConstraints({ (make) in
                        make.top.equalTo(self.passwordTextField.snp.bottom)
                        make.leading.equalTo(self.passwordTextField)
                        make.width.equalTo(self.passwordTextField)
                        make.height.equalTo(0.0)
                    })
                    self.view.layoutIfNeeded()
                }
                
                propertyAnimator?.startAnimation()
            }
        }
        return true
    }
    
    // MARK: - Actions
    func didTapDone(sender: UIButton) {
        // Username
        if (usernameTextField.text?.characters.count)! < 3 {
            propertyAnimator?.addAnimations {
                self.validUsernameLabel.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self.usernameTextField.snp.bottom)
                    make.leading.equalTo(self.usernameTextField)
                    make.width.equalTo(self.usernameTextField)
                    make.height.equalTo(15.0)
                })
                self.view.layoutIfNeeded()
            }
            self.propertyAnimator?.startAnimation()
        }
        
        // Email
        if !isValidEmail(email: emailTextField.text!) {
            propertyAnimator?.addAnimations {
                self.validEmailLabel.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self.emailTextField.snp.bottom)
                    make.leading.equalTo(self.emailTextField)
                    make.width.equalTo(self.emailTextField)
                    make.height.equalTo(15.0)
                })
                self.view.layoutIfNeeded()
            }
            self.propertyAnimator?.startAnimation()
        }
        
        // Password
        if (passwordTextField.text?.characters.count)! < 6 {
            propertyAnimator?.addAnimations {
                self.validPasswordLabel.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self.passwordTextField.snp.bottom)
                    make.leading.equalTo(self.passwordTextField)
                    make.width.equalTo(self.passwordTextField)
                    make.height.equalTo(15.0)
                })
                self.view.layoutIfNeeded()
            }
            self.propertyAnimator?.startAnimation()
        }
        
        // Create User
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                
                if error != nil {
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .errorCodeEmailAlreadyInUse:
                            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        default:
                            print("Create User Error: \(error)")
                        }    
                    }
                }
                
                if user != nil {
                    // We Have A User
                    
                    self.ref = FIRDatabase.database().reference()
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
                    
                    if let uploadData = UIImagePNGRepresentation(self.profilePic.image!) {
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            
                            if error != nil {
                                print(error?.localizedDescription as Any)
                                return
                            }
                            
                            if let metadataURL = metadata?.downloadURL()?.absoluteString {
                                let values = [
                                    "password": self.passwordTextField.text!,
                                    "username": self.usernameTextField.text!,
                                    "email" : self.emailTextField.text!,
                                    "profileImageURL" : metadataURL
                                ]
                                
                                self.registerUser(uid: (user?.uid)! ,values: values as [String : Any])
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                }
            })
        }
    }
    
    func didTapCancel(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Helper Function To Register User
    func registerUser(uid: String, values: [String: Any]) {
        self.ref = FIRDatabase.database().reference()
        self.ref.child("users").child(uid).setValue(values)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // Handler Function for picking profile pic
    func pickProfileImage() {
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
        picker.delegate = self
    }
    
    // MARK: - Image Picker Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.profilePic.image = info["UIImagePickerControllerOriginalImage"] as! UIImage?
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lazy Instantiates
    // Image View
    lazy var profilePic: UIImageView = {
        let profilePic = UIImageView()
        profilePic.backgroundColor = .white
        profilePic.alpha = 0.7
        profilePic.image = #imageLiteral(resourceName: "user_icon")
        profilePic.contentMode = .scaleAspectFit
        profilePic.layer.cornerRadius = 100
        profilePic.layer.masksToBounds = true
        profilePic.isUserInteractionEnabled = true
        
        return profilePic
    }()
    
    // Buttons
    internal lazy var doneButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    internal lazy var cancelButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    // Text Fields
    internal lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    internal lazy var emailTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        return textField
    }()
    
    // Input Minimum Labels
    internal lazy var validUsernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.textIconColor
        label.text = "Username must be atleast 3 characters"
        return label
    }()
    
    internal lazy var validEmailLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.textIconColor
        label.text = "Must be valid email"
        return label
    }()
    
    internal lazy var validPasswordLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.textIconColor
        label.text = "Password must be atleast 6 characters"
        return label
    }()
}
