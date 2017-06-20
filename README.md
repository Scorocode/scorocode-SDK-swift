# scorocode-SDK-swift
SDK предоставляет доступ к платформе Scorocode для построения приложений, основанных на swift.
Подробности на нашем сайте: https://scorocode.ru

### Установка:
1) Скопировать с репозитория папку [SCLib](https://github.com/Scorocode/scorocode-SDK-swift/tree/master/todolist/SCLib)
Добавить папку в свой проект.

2) В AppDelegate.swift в методе didFinishLaunchingWithOptions указать значения параметров инициализации API из личного кабинета. Пример:
```
//scorocode init
let applicationId = "98bc4bacb5edeb727cfb8fae25f71b59"
let clientId = "39169707deb69fc06145c995aa4cdefe"
let accessKey = "61ad813bd71bd4f45aea53a3c996d53a"
let fileKey = "351cb3d71efef69e3d6ac5657dd16c1c"
let messageKey = "35d5a173e0391a283d60a6a756a44051" 

SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
```

### Установка с помощью cocoapods:

Подключение библиотеки к проекту:

1) Установить [CocoaPods](https://cocoapods.org)

```
sudo gem install cocoapods
```

2) Создать новый проект в xcode, например "MyProject" (Имя проекта не должно совпадать со строкой "Scorocode")

3) Создать в корне проекта файл с именем "Podfile" с текстом:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'MyProject' do
  pod 'Scorocode'
end
```

4) Закрыть проект в xcode, запустить в консоли:

```
pod install
```

5) В папке с проектом появится файл `MyProject.xcworkspace`, открыть его в xcode.

6) В `AppDelegate.swift` в методе `didFinishLaunchingWithOptions` указать значения параметров инициализации API из личного кабинета. Пример:

```SWIFT
//scorocode init
let applicationId = "98bc4bacb5edeb727cfb8fae25f71b59"
let clientId = "39169707deb69fc06145c995aa4cdefe"
let accessKey = "61ad813bd71bd4f45aea53a3c996d53a"
let fileKey = "351cb3d71efef69e3d6ac5657dd16c1c"
let messageKey = "35d5a173e0391a283d60a6a756a44051" 

SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
```
