//
//  ViewController.swift
//  ToDoShechka
//
//  Created by Vladimir Saprykin on 17.03.17.
//  Copyright © 2017 Vladimir Saprykin. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    let segIdentifier = "tasksSegue"
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        //GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
       userLabel.alpha = 0
        
        ref = FIRDatabase.database().reference(withPath: "users")
        
        FIRAuth.auth()?.addStateDidChangeListener({ [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segIdentifier)!, sender: nil)
            }
        })
    }
        func kbDidShow(notification: Notification) {
            guard let userInfo = notification.userInfo else { return }
            let keyBoardFrameSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + keyBoardFrameSize.height)
            (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardFrameSize.height, right: 0)
        }
        
        func kbDidHide() {
            (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    func displayWarningLabel(withText text: String) {
        userLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut,
                       animations: { [weak self] in  self?.userLabel.alpha = 1
        }) { [weak self] complete  in
            self?.userLabel.alpha = 1
        }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != ""
            else {
            displayWarningLabel(withText: "Info is incorrect")
                return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segIdentifier)!, sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
        })
    }
    @IBAction func registerButton(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != ""
            else {
                displayWarningLabel(withText: "Info is incorrect")
                return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { [weak self]  (user, error) in
            guard error == nil, user != nil else {
                print(error!.localizedDescription)
                return
            }
            let userRef = self?.ref.child((user?.uid)!)
            userRef?.setValue(["email": user?.email])
        })
        
    }
        
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            print("User logged in with Google")
        })
    }
    
    private func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        try! FIRAuth.auth()!.signOut()
    }

}
