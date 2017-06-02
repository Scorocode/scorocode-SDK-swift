//
//  LoginVC.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 30/10/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import UIKit

class LoginVC : UIViewController {
    //Mark: outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var constraintLabelEmailTop: NSLayoutConstraint!
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if user.getCredentials() {
            textFieldPassword.text = user.password
            textFieldEmail.text = user.email
            login(email: user.email, password: user.password)
        }
    }
    
    //MARK: setupUI
    func setupUI() {
        textFieldEmail.text = ""
        textFieldPassword.text = ""
        //round buttons
        buttonLogin.layer.cornerRadius = 5.0;
        buttonLogin.layer.masksToBounds = true;
        buttonRegister.layer.cornerRadius = 5.0;
        buttonRegister.layer.masksToBounds = true;
    }
    
    func login(email: String, password: String) {
        let scUser = SCUser()
        scUser.login(email, password: password) {
            success, error, result in
            if success {
                self.user.saveCredentials(email: email, password: password)
                self.user.parseUser(userDictionary: result?["user"] as? [String: Any])
                self.user.saveTokenToServer()
                self.showAlert(title: "Вход выполнен", message: "Добро пожаловать \(self.user.name) !") {
                    let taskListVC = self.storyboard?.instantiateViewController(withIdentifier: "TaskListVC") as! TaskListVC
                    self.navigationController?.show(taskListVC, sender: self)
                }
            } else {
                self.showAlert(title: "Вход не выполнен!", message: "проверьте email и пароль.", completion: nil)
            }
        }
    }
    
    //MARK: button actions
    @IBAction func buttonLoginTapped(_ sender: AnyObject) {
        guard let email = textFieldEmail.text, email != "", let password = textFieldPassword.text, password != "" else {
            showAlert(title: "Вход не выполнен!", message: "проверьте email и пароль.", completion: nil)
            return
        }
        login(email: email, password: password)
    }
    @IBAction func buttonRegisterTapped(_ sender: Any) {
        let registerVC = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
}
