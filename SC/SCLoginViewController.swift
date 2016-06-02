//
//  SCLoginViewController.swift
//  SC
//
//  Created by Aleksandr Konakov on 24/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit

class SCLoginViewController: UIViewController {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func signupPressed() {
        performSegueWithIdentifier("ToSignup", sender: nil)
    }
    
    @IBAction private func loginPressed() {
        
        guard let email = emailTextField.text where email != "",
            let password = passwordTextField.text where password != "" else {
                let alert = UIAlertController(title: "Вход невозможен", message: "Не указан email или пароль", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default) {
                    action in
                    return
                }
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
                return
        }
        
        let user = SCUser()
        user.login(email, password: password) {
            success, error, result in
            if success {
                let alert = UIAlertController(title: "Вход выполнен", message: nil, preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default) {
                    action in
                    self.performSegueWithIdentifier("ToObjects", sender: nil)
                }
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }

}
