//
//  TaskDetailVC.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 03/11/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import UIKit

class TaskDetailVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //script id, sends push, if task status has changed
    let kTaskChangeStatusSendPushScriptID = "58415db542d52f1ba275fd9f"
    
    //MARK: outlets
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var constraintPickerViewUsersHeight: NSLayoutConstraint!
    @IBOutlet weak var pickerViewUsers: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var datePickerDate: UIDatePicker!
    @IBOutlet weak var textViewBossComment: UITextView!
    @IBOutlet weak var textViewComment: UITextView!
    @IBOutlet weak var switchIsClosed: UISwitch!
    @IBOutlet weak var switchIsDone: UISwitch!
    @IBOutlet weak var textViewDetailed: UITextView!
    @IBOutlet weak var textFieldTaskName: UITextField!
    @IBOutlet weak var tableViewHistory: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //MARK: Vars
    var task = Task()
    var isCreateMode : Bool = false
    let user = User.sharedInstance
    var userList = [IdAndName]()
    var historyList = [History]()
    
    //MARK: override VC functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewResizerOnKeyboardShown()
        hideKeyboardWhenTappedAround()
        getUserListForUserPicker()
        if isCreateMode == false{
            getHistory()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        buttonSave.isEnabled = true
        buttonSave.title = "Сохранить"
    }
    
    //MARK: setupUI
    func setupUI() {
        buttonDelete.clipsToBounds = true
        buttonDelete.layer.cornerRadius = 5.0
        buttonDelete.isHidden = !(user.isBoss && !isCreateMode)
        tableViewHistory.rowHeight = UITableViewAutomaticDimension
        tableViewHistory.estimatedRowHeight = 50
        datePickerDate.isUserInteractionEnabled = user.isBoss
        datePickerDate.minimumDate = Date()
        constraintPickerViewUsersHeight.constant = (isCreateMode || user.isBoss) ? 100.0 : 50.0
        textFieldTaskName.isEnabled = user.isBoss
        textViewDetailed.isEditable = user.isBoss
        switchIsClosed.isEnabled = (user.isBoss != isCreateMode)
        switchIsDone.isEnabled = !isCreateMode
        textViewComment.isEditable = !user.isBoss
        textViewBossComment.isEditable = user.isBoss
        //edit or create ?
        if isCreateMode == false {
            datePickerDate.date = task.closeDate
            textFieldTaskName.text = task.name
            textViewDetailed.text = task.detailed
            switchIsDone.isOn = task.isDone
            switchIsClosed.isOn = task.isClose
            textViewComment.text = task.comment
            textViewBossComment.text = task.bossComment
        }
        //if task is closed - no taps. History, delete button - can accept taps.
        if task.isClose {
            for view in contentView.subviews {
                view.isUserInteractionEnabled = false
            }
            tableViewHistory.isUserInteractionEnabled = true
            buttonDelete.isUserInteractionEnabled = true
            buttonSave.isEnabled = false
            buttonSave.title = ""
        }
    }

    //MARK: user work
    func getUserListForUserPicker() {
        userList.removeAll()
        // if we look details of task and we are not a boss
        if (!isCreateMode && !user.isBoss) || task.isClose {
            userList.append(IdAndName(id: task.user, name: task.username))
            pickerViewUsers.reloadAllComponents()
        } else {
            // if we create new task or boss opens task:
            var scQuery = SCQuery(collection: "users")
            scQuery.fields(["_id","username"])
            scQuery.notEqualTo("_id", SCString(user.id))
            scQuery.find() {
                success, error, result in
                if success && (result?.count)! > 0 {
                    for elem in (result!.values) {
                        if let id = (elem as? [String: Any])?["_id"] as? String,
                            let name = (elem as? [String: Any])?["username"] as? String {
                            self.userList.append(IdAndName(id: id, name: name))
                        }
                    }
                } else {
                    self.showAlert(title: "Ошибка!", message: "Не удалось получить список исполнителей", completion: nil)
                }
                self.userList.sort(by: {$0.name < $1.name})
                self.pickerViewUsers.reloadAllComponents()
                //select current user
                for (index, user) in self.userList.enumerated() {
                    if user.id == self.task.user {
                        self.pickerViewUsers.selectRow(index, inComponent: 0, animated: true)
                        break
                    }
                }
            }
        }
    }
    
    //MARK: History work
    func getHistory() {
        historyList.removeAll()
        var scQuery = SCQuery(collection: "history")
        scQuery.fields(["createdAt","value","field"])
        scQuery.equalTo("task", SCString(task.id))
        scQuery.find() {
            success, error, result in
            if success && (result?.count)! > 0 {
                for elem in (result?.values)! {
                    if let date = (elem as? [String: Any])?["createdAt"] as? Date,
                        let value = (elem as? [String: Any])?["value"] as? String,
                        let field = (elem as? [String: Any])?["field"] as? String {
                        self.historyList.append(History(date: date, value: value, field: field))
                    }
                }
            } else {
                self.showAlert(title: "Ошибка!", message: "Не удалось загрузить историю задачи", completion: nil)
            }
            self.historyList.sort(by: {$0.date.compare($1.date) == ComparisonResult.orderedAscending})
            self.tableViewHistory.reloadData()
        }
    }
    
    func saveHistory(_ newTask: Task) {
        var items = [SCObject]()
        var mode = ""
        /* mode values:
         var UserHasDoneTask
         var BossHasCloseTask
         var BossHasntDone
        */
        if isCreateMode {
            let scObject = SCObject(collection: "history")
            scObject.set(["task": SCString(newTask.id),
                "field": SCString("Задача:"),
                "value": SCString("Создана.")
                ])
            items.append(scObject)
        } else {
            if task.name != newTask.name {
                let item = SCObject(collection: "history")
                item.set(["task": SCString(newTask.id), "field": SCString("Название задачи изменено:"), "value": SCString(newTask.name)])
                items.append(item)
            }
            if task.comment != newTask.comment {
                let item = SCObject(collection: "history")
                item.set(["task": SCString(newTask.id), "field": SCString("Исполнитель изменил комментарий:"), "value": SCString(newTask.comment)])
                items.append(item)
            }
            if task.bossComment != newTask.bossComment {
                let item = SCObject(collection: "history")
                item.set(["task": SCString(newTask.id), "field": SCString("Босс изменил комментарий:"), "value": SCString(newTask.bossComment)])
                items.append(item)
            }
            if task.detailed != newTask.detailed {
                let item = SCObject(collection: "history")
                item.set(["task": SCString(newTask.id), "field": SCString("Описание изменено:"), "value": SCString(newTask.detailed)])
                items.append(item)
            }
            if task.closeDate != newTask.closeDate {
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.autoupdatingCurrent
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                let value = dateFormatter.string(from: newTask.closeDate)
                let item = SCObject(collection: "history")
                item.set(["task": SCString(newTask.id), "field": SCString("Изменен срок:"), "value": SCString(value)])
                items.append(item)
            }
            if task.username != newTask.username {
                let item = SCObject(collection: "history")
                item.set(["task": SCString(newTask.id), "field": SCString("Исполнитель изменен:"), "value": SCString(newTask.username)])
                items.append(item)
            }
            if task.isDone != newTask.isDone {
                let item = SCObject(collection: "history")
                let statusString = newTask.isDone ? "Выполнена." : "Не выполнена."
                item.set(["task": SCString(newTask.id), "field": SCString("Задача:"), "value": SCString(statusString)])
                items.append(item)
                if newTask.isDone && !user.isBoss {
                    mode = "UserHasDoneTask"
                } else if !newTask.isDone && user.isBoss {
                    mode = "BossHasntDone"
                }
            }
            if task.isClose != newTask.isClose {
                let item = SCObject(collection: "history")
                item.set(["task": SCString(newTask.id), "field": SCString("Задача:"), "value": SCString("Закрыта.")])
                items.append(item)
                if newTask.isClose {
                    mode = "BossHasCloseTask"
                }
            }
            alertUser(mode: mode, userId: newTask.user, userName: newTask.username, taskName: newTask.name)
        }
        //try to save
        for i in 0..<items.count {
            let scObject = items[i]
            activityIndicator.startAnimating()
            contentView.isUserInteractionEnabled = false
            scObject.save() {
            success, error, result in
                self.activityIndicator.stopAnimating()
                self.contentView.isUserInteractionEnabled = true
                if !success {
                    self.showAlert(title: "Ошибка!", message: "Не удалось сохранить элемент истории", completion: nil)
                }
                if i == items.count - 1 {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //send push to user/boss, if the task has changes done/close status
    func alertUser(mode: String, userId: String, userName: String, taskName: String) {
        guard mode != "" else {
            return
        }
        var rolesQuery = SCQuery(collection: "roles")
        var usersQuery = SCQuery(collection: "users")
        rolesQuery.equalTo("name", SCString("boss"))
        rolesQuery.fields(["_id"])
        rolesQuery.find { (success, error, result) in
            if success, let roleBossId = (result?.values.first as? [String: Any])?["_id"] as? String {
                usersQuery.equalTo("roles", SCArray(stringArray: [roleBossId]))
                usersQuery.find({ (success, error, result) in
                    if success, let bossId = (result?.values.first as? [String: Any])?["_id"] as? String{
                        let pool = ["mode":mode, "userId":userId, "userName":userName, "taskName":taskName, "bossId": bossId]
                        
                        let script = SCScript(id: self.kTaskChangeStatusSendPushScriptID)
                        script.run(pool: pool, debug: false) { (success, error) in
                            if success {
                                print("script \(self.kTaskChangeStatusSendPushScriptID) was executed.")
                            } else if error != nil {
                                print(error!)
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func buttonSaveTouchUpInside(_ sender: AnyObject) {
        //set task params
        let newTask = Task()
        newTask.user = userList[pickerViewUsers.selectedRow(inComponent: 0)].id
        newTask.username = userList[pickerViewUsers.selectedRow(inComponent: 0)].name
        newTask.bossComment = textViewBossComment.text
        newTask.closeDate = datePickerDate.date
        newTask.comment = textViewComment.text
        newTask.detailed = textViewDetailed.text
        if isCreateMode {
            newTask.isClose = false
            newTask.isDone = false
        } else {
            newTask.isClose = switchIsClosed.isOn
            newTask.isDone = switchIsDone.isOn
        }
        if let text = textFieldTaskName.text {
            newTask.name = text
        }
        newTask.id = task.id
        //creating new task document or update
        let scObject = isCreateMode ? SCObject(collection: "tasks") : SCObject(collection: "tasks", id: task.id)
        scObject.set(["name": SCString(newTask.name),
            "Done": SCBool(newTask.isDone),
            "Closed": SCBool(newTask.isClose),
            "comment": SCString(newTask.comment),
            "closeDate": SCDate(newTask.closeDate),
            "detailed": SCString(newTask.detailed),
            "bossComment": SCString(newTask.bossComment),
            "user": SCString(newTask.user),
        ])
        //try to create or update
        activityIndicator.startAnimating()
        contentView.isUserInteractionEnabled = false
        scObject.save() {
            success, error, result in
            self.activityIndicator.stopAnimating()
            self.contentView.isUserInteractionEnabled = true
            if success {
                // get task id
                if self.isCreateMode {
                    if let id = result?["_id"] as? String {
                        newTask.id = id
                    }
                }
                self.saveHistory(newTask)
            } else {
               self.showAlert(title: "Ошибка!", message: "Не удалось сохранить задачу. Попробуйте еще раз", completion: nil)
            }
        }
    }
    
    //MARK: picker view delegate
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userList[row].name
    }
    
    //MARK: Tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewHistory.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryCell
        let history = historyList[indexPath.row];
        cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(hex: 0xEFEFEF) : UIColor(hex: 0xFEFEFE)
        cell.setCell(history.date, field: history.field, value: history.value)
        return cell
    }
    @IBAction func buttonDeleteTap(_ sender: Any) {
        let scObject = SCObject(collection: "tasks", id: task.id)
        scObject.remove { (success, error, result) in
            if success {
                var scQuery = SCQuery(collection: "history")
                scQuery.equalTo("task", SCString(self.task.id))
                scQuery.remove({ (success, error, result) in
                    if success {
                        self.showAlert(title: "Успешно", message: "Задача и ее история удалена") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
    }

    
}
