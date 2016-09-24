//
//  SCSignupViewController.swift
//  SC
//
//  Created by Aleksandr Konakov on 24/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit

class SCSignupViewController: UIViewController {

    @IBOutlet fileprivate weak var usernameTextField: UITextField!
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction fileprivate func signupPressed() {
        guard let email = emailTextField.text , email != "",
            let password = passwordTextField.text , password != "",
        let username = usernameTextField.text , username != "" else {
                let alert = UIAlertController(title: "Регистрация невозможна", message: "Не указан email, пароль или имя пользователя", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) {
                    action in
                    return
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
                return
        }
        
        let user = SCUser()
        user.signup(username, email: email, password: password) {
            success, error, result in
            if success {
                let alert = UIAlertController(title: "Пользователь зарегистрирован", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) {
                    action in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                var message = ""
                switch error! {
                case .api(_, let apiMessage):
                    message = apiMessage
                default:
                    break
                }
                let alert = UIAlertController(title: "Ошибка при регистрации", message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) {
                    action in
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction fileprivate func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }

}
