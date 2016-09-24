//
//  SCLoginViewController.swift
//  SC
//
//  Created by Aleksandr Konakov on 24/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit

class SCLoginViewController: UIViewController {

    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction fileprivate func signupPressed() {
        performSegue(withIdentifier: "ToSignup", sender: nil)
    }
    
    @IBAction fileprivate func loginPressed() {
        
        guard let email = emailTextField.text , email != "",
            let password = passwordTextField.text , password != "" else {
                let alert = UIAlertController(title: "Вход невозможен", message: "Не указан email или пароль", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) {
                    action in
                    return
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
                return
        }
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            if success {
                let alert = UIAlertController(title: "Вход выполнен", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) {
                    action in
                    self.performSegue(withIdentifier: "ToObjects", sender: nil)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

}
