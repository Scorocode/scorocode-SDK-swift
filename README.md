# scorocode-SDK-swift
SDK предоставляет доступ к платформе Scorocode для построения приложений, основанных на swift.
Подробности на нашем сайте: https://scorocode.ru

### Установка
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
5) В папке с проектом появится файл MyProject.xcworkspace, открыть его в xcode.
В AppDelegate.swift в метод didFinishLaunchingWithOptions указать значения параметров инициализации API из личного кабинета:
```
//scorocode init
let applicationId = "98bc4bacb5edea727cfb8fae25f71b59"
let clientId = "39169707deb69fc061c5c995aa4cdefe"
let accessKey = "61ad813bd71bd4f05aea53a3c996d53a"
let fileKey = "351cb3d71efef69e346ac5657dd16c1c"
let messageKey = "35d5a173e0391ae83d60a6a756a44051"       
SC.initWith(applicationId: applicationId, clientId: clientId, accessKey: accessKey, fileKey: fileKey, messageKey: messageKey)
```

### License
```
MIT License

Copyright (c) 2016 ProfIT-Ventures LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
