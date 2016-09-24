//
//  SCListViewController.swift
//  SC
//
//  Created by Aleksandr Konakov on 24/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SCListViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var searchField: UITextField!
    
    fileprivate var data = [[String: AnyObject]]()
    fileprivate var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getObjects()
    }
    
    fileprivate func getObjects() {
        var query = SCQuery(collection: "testcoll")
        query.descending("createdAt")
        if let search = searchField.text , search != "" {
            query.equalTo("fieldString", SCString(search))
        }
        query.find() {
            success, error, result in
            self.data.removeAll()
            let keys = result!.keys
            let sortedKeys = keys.sorted() {
                Double($1) > Double($0)
            }
            for key in sortedKeys {
                self.data.append(result![key] as! [String: AnyObject])
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction fileprivate func addPressed() {
        performSegue(withIdentifier: "ToSingleObject", sender: "New")
    }
    
    @IBAction fileprivate func refreshPressed() {
        getObjects()
    }
    
    @IBAction fileprivate func logoutPressed() {
        SCUser.logout() {
            success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToSingleObject" {
            let vc = segue.destination as! SCObjectViewController
            let mode = sender as! String
            vc.mode = mode
            if mode == "Edit" {
                vc.objectId = (data[selectedIndex]["_id"] as! String)
            }
        }
    }
}

extension SCListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = (indexPath as NSIndexPath).row
        performSegue(withIdentifier: "ToSingleObject", sender: "Edit")
    }
}

extension SCListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath)
        let object = data[(indexPath as NSIndexPath).row]
        var text = ""
        if let fieldString = object["fieldString"] as? String {
            text += fieldString
        }
        if let fieldNumber = object["fieldNumber"] as? Double {
            if text.characters.count > 0 {
                text += ";"
            }
            text += String(fieldNumber)
        }
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
}
