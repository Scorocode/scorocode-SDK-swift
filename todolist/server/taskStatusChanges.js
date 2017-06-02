var Scorocode = require('scorocode');
var bossId = "qRmX5rHsc6"
var UserHasDoneTask = " выполнил задачу: "
var BossHasCloseTask = "Босс закрыл задачу: "
var BossHasntDone = "Босс не одобрил выполнение задачи: "

Scorocode.Init({
    ApplicationID: "98bc4bacb5edea727cfb8fae25f71b59",
    JavaScriptKey: "24d0d42ab02cf546b88b9134cf1d1468",
    FileKey: "351cb3d71efef69e346ac5657dd16c1c",
    MessageKey: "35d5a173e0391ae83d60a6a756a44051"
});


userClosedTask();

function userClosedTask() {
    // user has closed the task
    var Devices = new Scorocode.Query("devices");
    var Broadcast = new Scorocode.Messenger();
    var userId = ""
    var userName = pool["userName"]
    var taskName = pool["taskName"]
    var text = ""
    var mode = pool["mode"]
    console.log(pool)
    switch (mode) {
    case 'BossHasCloseTask':
        userId = pool["userId"]
        text = BossHasCloseTask + taskName
        break;
    case 'BossHasntDone':
        userId = pool["userId"]
        text = BossHasntDone + taskName
        break;
    case 'UserHasDoneTask':
        userId = bossId
        text = userName + UserHasDoneTask + taskName
        break;
    default:
        return
    }
    //send push to boss
    Devices.equalTo("userId", userId)
        Broadcast.sendPush({
            where: Devices,
                data: {"text": text}//text}
            })
            .then((success)=>{
                console.log("success!");
                console.log(success);
            })
            .catch((error)=>{
                        console.log("error!");
                        console.log(error)
            });
    
}
