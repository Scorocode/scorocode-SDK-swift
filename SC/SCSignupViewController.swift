//
//  SCSignupViewController.swift
//  SC
//
//  Created by Aleksandr Konakov on 24/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit

class SCSignupViewController: UIViewController {

    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func signupPressed() {
        guard let email = emailTextField.text where email != "",
            let password = passwordTextField.text where password != "",
        let username = usernameTextField.text where username != "" else {
                let alert = UIAlertController(title: "Регистрация невозможна", message: "Не указан email, пароль или имя пользователя", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default) {
                    action in
                    return
                }
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
                return
        }
        
        let user = SCUser()
        user.signup(username, email: email, password: password) {
            success, error, result in
            if success {
                let alert = UIAlertController(title: "Пользователь зарегистрирован", message: nil, preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default) {
                    action in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                var message = ""
                switch error! {
                case .API(_, let apiMessage):
                    message = apiMessage
                default:
                    break
                }
                let alert = UIAlertController(title: "Ошибка при регистрации", message: message, preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default) {
                    action in
                }
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction private func cancelPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
