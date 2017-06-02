//
//  TaskListVC.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 30/10/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import UIKit

class TaskListVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonLogout: UIBarButtonItem!
    @IBOutlet weak var buttonCreate: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //MARK: vars
    let user = User.sharedInstance
    var taskList = [Task]()
    
    //MARK: override VC functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        getTasks()
    }
    
    //MARK: setup UI
    func setupUI() {
        buttonCreate.isEnabled = user.isBoss
    }
    
    //MARK: tasks work
    func getTasks() {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        taskList.removeAll()
        self.tableView.reloadData()
        var scQuery = SCQuery(collection: "tasks")
        if !user.isBoss {
            scQuery.equalTo("user", SCString(user.id))
        }
        scQuery.find() {
            success, error, result in
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.stopAnimating()
            if success && (result?.count)! > 0 {
                for e in (result?.values)! {
                    guard let elem = e as? [String:Any] else {
                        break
                    }
                    let task = Task()
                    if let id = elem["_id"] as? String {
                        task.id = id
                    }
                    if let name = elem["name"] as? String {
                        task.name = name
                    }
                    if let isClose = elem["Closed"] as? Bool {
                        task.isClose = isClose
                    }
                    if let isDone = elem["Done"] as? Bool {
                        task.isDone = isDone
                    }
                    if let closeDate = elem["closeDate"] as? Date {
                        task.closeDate = closeDate
                    }
                    if let comment = elem["comment"] as? String {
                        task.comment = comment
                    }
                    if let bossComment = elem["bossComment"] as? String {
                        task.bossComment = bossComment
                    }
                    if let detailed = elem["detailed"] as? String {
                        task.detailed = detailed
                    }
                    if let user = elem["user"] as? String {
                        task.user = user
                    }
                    self.getUserNameAndAddTask(task)
                }
            } else {
                if success {
                    self.showAlert(title: "", message: "Список задач пока пуст.", completion: nil)
                }
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func getUserNameAndAddTask(_ task: Task) {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        var scQuery = SCQuery(collection: "users")
        scQuery.fields(["username"])
        scQuery.equalTo("_id", SCString(task.user))
        scQuery.find() {
            success, error, result  in
            if success && (result?.count)! > 0 {
                if let username = (result?.values.first as? [String: Any])?["username"] as? String {
                    task.username = username
                }
            } else {
                self.showAlert(title: "Ошибка!", message: "Не найдено имя пользователя для задачи \(task.name)", completion: nil)
            }
            self.taskList.append(task)
            //sort by fields: isClosed, closeDate
            self.taskList.sort(by: {t1, t2 in
                if t1.isClose == t2.isClose {
                    return t1.closeDate.compare(t2.closeDate) == ComparisonResult.orderedAscending
                }
                return !t1.isClose && t2.isClose })
            self.tableView.reloadData()
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskListCell
        let task = taskList[indexPath.row]
        cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(hex: 0xEFEFEF) : UIColor(hex: 0xFEFEFE)
        cell.setupCell(task.name, statusDone: task.isDone, statusClosed: task.isClose, closeDate: task.closeDate, username: task.username)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskDetailVC = storyboard?.instantiateViewController(withIdentifier: "TaskDetailVC") as! TaskDetailVC
        taskDetailVC.task = taskList[indexPath.row]
        taskDetailVC.isCreateMode = false
        navigationController?.pushViewController(taskDetailVC, animated: true)
    }
    
    //MARK: buttons actions
    @IBAction func buttonLogoutPressed(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Выйти из системы?", message: nil, preferredStyle: .alert)
        let logout = UIAlertAction(title: "Выйти", style: .destructive) {
            action in
            self.user.clear()
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(logout)
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonCreateTouchUpInside(_ sender: AnyObject) {
        let taskDetailVC = storyboard?.instantiateViewController(withIdentifier: "TaskDetailVC") as! TaskDetailVC
        taskDetailVC.isCreateMode = true
        navigationController?.pushViewController(taskDetailVC, animated: true)
    }
    
}
