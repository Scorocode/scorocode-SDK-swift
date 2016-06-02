# scorocode-sdk-swift
SDK предоставляет доступ к платформе Scorocode для построения приложений, основанных на swift
Подробности на нашем сайте: https://scorocode.ru

### Установка
Подключение библиотеки к проекту

Установить [Carthage](https://github.com/Carthage/Carthage)

Создать приложение

Создать в корне проекта файл с именем "Cartfile", записать в него строки:
```
github "Alamofire/Alamofire" ~> 3.3
github "SwiftyJSON/SwiftyJSON"
```
Запустить carthage update --platform iOS,Mac

Открыть заново проект в Xcode

В Target -> General -> Linked Frameworks and Libraries из <Каталог проекта> -> Carthage -> Build -> iOS перетащить 2 файла:
```
Alamofire.framework
SwiftyJSON.framework
```

В Target -> Build Phases добавить New Run Script Phase:

скрипт:
```
/usr/local/bin/carthage copy-frameworks
```
Два Input File:

```
$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
```
и
```
$(SRCROOT)/Carthage/Build/iOS/SwiftyJSON.framework
```

В случае отсутствия bridging header создать его с таким содержимым:

```
#import "BSONSerialization.h"
```

Создать в проекте новую группу (например, SCLib)

Добавить в нее 3 папки (BSON, API, Model) из папки SCLib проекта, полученного из репозитория

В AppDelegate.swift в метод didFinishLaunchingWithOptions указать значения параметров инициализации API:

```
let applicationId = ""
let clientId = ""
let accessKey = ""
let fileKey = ""
let messageKey = ""
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
