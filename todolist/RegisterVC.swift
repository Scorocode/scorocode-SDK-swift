//
//  RegisterVC.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 01.06.17.
//  Copyright © 2017 ProfIT. All rights reserved.
//

import UIKit

class RegisterVC : UIViewController {
    //Mark: outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldName: UITextField!

    //Mark: vars
    let user = User.sharedInstance
    
    //Mark: override VC functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // keyboard show-hide, resize window.
        setupViewResizerOnKeyboardShown()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: setupUI
    func setupUI() {
        //round login button
        buttonRegister.layer.cornerRadius = 5.0;
        buttonRegister.layer.masksToBounds = true;
    }
    
    func signup(email: String, password: String, name: String) {
        let scUser = SCUser()
        scUser.signup(name, email: email, password: password) { (success, error, result) in
            if success {
                self.user.saveCredentials(email: email, password: password)
                self.user.saveTokenToServer()
                self.user.parseUser(userDictionary: result?["user"] as? [String: Any])
                self.showAlert(title: "Успешно", message: "Вы успешно зарегистрировались") {
                    let taskListVC = self.storyboard?.instantiateViewController(withIdentifier: "TaskListVC") as! TaskListVC
                    self.navigationController?.pushViewController(taskListVC, animated: true)
                }
            } else {
                self.showAlert(title: "Регистрация не выполнена!", message: "Попробуйте еще раз.", completion: nil)
            }
        }
    }
    
    //MARK: button actions
    @IBAction func buttonRegisterTapped(_ sender: AnyObject) {
        guard textFieldPassword.text == textFieldConfirmPassword.text, textFieldConfirmPassword.text != "" else {
            showAlert(title: "Пароли должны совпадать", message: "Пароль и подтверждение пароля не совпадают!", completion: nil)
            return
        }
        guard let email = textFieldEmail.text, email != "", let password = textFieldPassword.text, password != "" else {
            showAlert(title: "Регистрация не выполнена!", message: "Email и пароль доолжны быть заполнены.", completion: nil)
            return
        }
        signup(email: textFieldEmail.text!, password: textFieldPassword.text!, name: textFieldName.text ?? "")
    }
    
}
