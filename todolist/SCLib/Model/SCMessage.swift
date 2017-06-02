//
//  SCMessage.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public struct SCMessage {
    //Отправка пуша со своей data.
    public static func sendPush(_ query: SCQuery, data: Dictionary<String, Any>, debug: Bool, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        SCAPI.sharedInstance.sendPush(query, data: data, debug: debug, callback: callback)
    }
    
    //Упрощенная отправка пуша, с заголовком и текстом, словарь data генерируется автоматически
    public static func sendPush(_ query: SCQuery, title: String, text: String, debug: Bool, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        SCAPI.sharedInstance.sendPush(query, title: title, text: text, debug: debug, callback: callback)
    }
    
    public static func sendSms(_ query: SCQuery, text: String, callback: @escaping (Bool, SCError?, Int?) -> Void) {
        SCAPI.sharedInstance.sendSms(query, text: text, callback: callback)
    }
}
