var Scorocode = require('scorocode');
var bossId = "qRmX5rHsc6"

Scorocode.Init({
    ApplicationID: "98bc4bacb5edea727cfb8fae25f71b59",
    JavaScriptKey: "24d0d42ab02cf546b88b9134cf1d1468",
    FileKey: "351cb3d71efef69e346ac5657dd16c1c",
    MessageKey: "35d5a173e0391ae83d60a6a756a44051"
});

alertBossAboutExpiredTasks();

function alertBossAboutExpiredTasks() {
    // Создадим новый экземпляр запроса к коллекции Tasks
var Tasks = new Scorocode.Query("tasks"); 
var TasksIsDone = new Scorocode.Query("tasks");
var TasksIsClosed = new Scorocode.Query("tasks");
var TasksIsOver = new Scorocode.Query("tasks");
// Установим условие выборки - запросить все объекты, с истекшим сроком
var now = new Date()
TasksIsOver.lessThan("closeDate", now.toISOString()) 
// Установим условие выборки - запросить все выполненные пользователем задачи
TasksIsDone.notEqualTo("Done", true)
// Установим условие выборки - запросить все закрытые боссом задачи
TasksIsClosed.notEqualTo("Closed", true)
    Tasks.and(TasksIsDone).and(TasksIsClosed).and(TasksIsOver)
        .find()
        .then((result) => {
            console.log(result.result)
            parseQueryResultAndSendPushToBoss(result.result)
        })
        .catch((error) => {
            console.log(error)
        });
}

function parseQueryResultAndSendPushToBoss(queryResult)  {
    var Broadcast = new Scorocode.Messenger();
    var Devices = new Scorocode.Query("devices");
    var expiredTasks = [];
    for (var index in queryResult) {
        var textMessage = "Просрочена задача: \"" + queryResult[index].name + "\""
        expiredTasks.push({"text":textMessage,"userid":queryResult[index].user})
    }
    //send to boss expired tasks
    for (var key in expiredTasks) {    
        var task = expiredTasks[key]
        var id = task["userid"]    
        var text = task["text"]
        console.log(id,text)
        Devices.equalTo("userId", bossId)
        Broadcast.sendPush({
            where: Devices,
                data: {"text": text}
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
}
