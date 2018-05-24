//
//  XJWebManager.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/5/24.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit
public protocol XJReminderDelegate: NSObjectProtocol {
    func recivedNewReminder(reminder : Reminder)
}
public protocol XJMemoDelegate: NSObjectProtocol {
    func recivedNewMemo(memo : Memorandum)
}
class XJWebManager: NSObject {
    
    weak open var reminderDelegate: XJReminderDelegate?{
        didSet{
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(foundNewReminder), userInfo: nil, repeats: true)
        }
    }
    weak open var memoDelegate: XJMemoDelegate?{
        didSet{
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(foundNewMemo), userInfo: nil, repeats: true)
        }
    }
    //单例
    static let shared = XJWebManager()
    @objc func foundNewReminder(){
        delog("找到了一个新的Reminder")
        reminderDelegate!.recivedNewReminder(reminder: Reminder())
    }
    @objc func foundNewMemo(){
        delog("找到了一个新的Memo")
        memoDelegate!.recivedNewMemo(memo: Memorandum())
    }
}
