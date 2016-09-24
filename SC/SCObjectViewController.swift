//
//  SCObjectViewController.swift
//  SC
//
//  Created by Aleksandr Konakov on 24/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit

class SCObjectViewController: UIViewController {
    
    var mode = ""
    var objectId: String?
    
    var data: [String: AnyObject]?
    
    @IBOutlet fileprivate weak var stringTextField: UITextField!
    @IBOutlet fileprivate weak var doubleTextField: UITextField!
    
    @IBOutlet fileprivate weak var trashButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    fileprivate func configureView() {
        switch mode {
        case "New":
            print("New")
            navigationItem.rightBarButtonItem?.title = "Insert"
            trashButton.isEnabled = false
        case "Edit":
            print("Edit for \(objectId!)")
            trashButton.isEnabled = true
            getObjectForEdit()
        default:
            break
        }
    }
    
    fileprivate func getObjectForEdit() {
        SCObject.getById(objectId!, collection: "testcoll") {
            success, error, result in
            self.data = result!["0"] as? [String: AnyObject]
            self.navigationItem.rightBarButtonItem?.title = "Update"
            if let string = self.data!["fieldString"] as? String {
                self.stringTextField.text = string
            }
            if let num = self.data!["fieldNumber"] as? Double {
                self.doubleTextField.text = String(num)
            }
        }
    }
    
    @IBAction fileprivate func savePressed() {
        switch mode {
        case "New":
            
            var updateDic = [String: SCValue]()
            
            let obj = SCObject(collection: "testcoll")
            if let string = stringTextField.text , string != "" {
                updateDic["fieldString"] = SCString(string)
            }
            if let num = doubleTextField.text , num != "" {
                updateDic["fieldNumber"] = SCDouble(Double(num)!)
            }
            updateDic["readACL"] = SCArray([SCString("*"), SCString("0123456789")])
            obj.set(updateDic)
            obj.save() {
                success, error, result in
                if success {
                    let alert = UIAlertController(title: "Успешно сохранено", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) {
                        action in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print(error)
                }
            }
            
        case "Edit":
            let obj = SCObject(collection: "testcoll", id: objectId)
            var updateDic = [String: SCValue]()
            
            if let string = stringTextField.text , string != "" {
                updateDic["fieldString"] = SCString(string)
            }
            if let num = doubleTextField.text , num != "" {
                updateDic["fieldNumber"] = SCDouble(Double(num)!)
            }
            obj.set(updateDic)
            obj.save() {
                success, error, result in
                if success {
                    let alert = UIAlertController(title: "Успешно сохранено", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) {
                        action in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }

            
        default:
            break
        }
    }
    
    @IBAction fileprivate func trashPressed() {
        let obj = SCObject(collection: "testcoll", id: objectId)
        obj.remove() {
            success, error, result in
            if success {
                if let removedDocs = result!["docs"] as? [String] {
                    if removedDocs.contains(self.objectId!) {
                        let alert = UIAlertController(title: "Успешно удалено", message: nil, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) {
                            action in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
}
