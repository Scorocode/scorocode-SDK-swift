//
//  SCListViewController.swift
//  SC
//
//  Created by Aleksandr Konakov on 24/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import UIKit

class SCListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchField: UITextField!
    
    private var data = [[String: AnyObject]]()
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getObjects()
    }
    
    private func getObjects() {
        var query = SCQuery(collection: "testcoll")
        query.descending("createdAt")
        if let search = searchField.text where search != "" {
            query.equalTo("fieldString", SCString(search))
        }
        query.find() {
            success, error, result in
            self.data.removeAll()
            let keys = result!.keys
            let sortedKeys = keys.sort() {
                Double($1) > Double($0)
            }
            for key in sortedKeys {
                self.data.append(result![key] as! [String: AnyObject])
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction private func addPressed() {
        performSegueWithIdentifier("ToSingleObject", sender: "New")
    }
    
    @IBAction private func refreshPressed() {
        getObjects()
    }
    
    @IBAction private func logoutPressed() {
        SCUser.logout() {
            success, error in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToSingleObject" {
            let vc = segue.destinationViewController as! SCObjectViewController
            let mode = sender as! String
            vc.mode = mode
            if mode == "Edit" {
                vc.objectId = (data[selectedIndex]["_id"] as! String)
            }
        }
    }
}

extension SCListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegueWithIdentifier("ToSingleObject", sender: "Edit")
    }
}

extension SCListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ObjectCell", forIndexPath: indexPath)
        let object = data[indexPath.row]
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
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
}
