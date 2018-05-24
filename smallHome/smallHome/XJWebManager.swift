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
    //轮询时间
    let requestTime = 60
    weak open var reminderDelegate: XJReminderDelegate?{
        didSet{
            Timer.scheduledTimer(timeInterval: TimeInterval(requestTime), target: self, selector: #selector(foundNewReminder), userInfo: nil, repeats: true)
        }
    }
    weak open var memoDelegate: XJMemoDelegate?{
        didSet{
            Timer.scheduledTimer(timeInterval: TimeInterval(requestTime), target: self, selector: #selector(foundNewMemo), userInfo: nil, repeats: true)
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
    //一个人没有id的时候就要和服务器要一个id,暂时设置为自己的,以后要改
    //FIXME: 这里以后要改
    func requestNewId(name: String) -> String{
        return "123123"
    }
}
