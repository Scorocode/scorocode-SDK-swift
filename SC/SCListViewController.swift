//
//  SCListViewController.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import UIKit


class SCListViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var searchField: UITextField!
    
    var data = [[String: String]]()
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
        var query = SCQuery(collection: "users")
        if let search = searchField.text, search != "" {
            query.equalTo("email", SCString(search))
        }
        query.find() {
            success, error, result in
            guard (result?.values.count)! > 0 else {
                return
            }
            self.data.removeAll()
            for elem in (result?.values)! {
                let e = elem as! [String:AnyObject]
                if let username = e["username"] as? String, let email = e["email"] as? String {
                    self.data.append(["username":username, "email":email])
                }
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
                //vc.objectId = (data[selectedIndex]["_id"] as! String)
            }
        }
    }
}

extension SCListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "ToSingleObject", sender: "Edit")
    }
}

extension SCListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
}
