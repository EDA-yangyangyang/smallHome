//
//  XJModelManager.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/5/24.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit
import CoreData
class XJModelManager: NSObject {
    //MARK: - 常用方法放在这里
    ///返回备忘录信息
    public func memorandumInfo() -> [Memorandum] {
        return shared.getMemorandumInfo()
    }
    ///返回提醒信息
    public func reminderInfo() -> [Reminder] {
        return shared.getReminderInfo()
    }
    //一个单例
    public lazy var shared: XJModelManager = {
        return XJModelManager()
    }()
    //MARK: - 和coreData相连的部分
    //context懒加载
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext;
        return context
    }()
    //调用appDelegate的save函数
    func save(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
    //MARK: - 备忘录
    let memoName = "Memorandum"
    ///返回本地备忘录信息
    func getMemorandumInfo() -> [Memorandum] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: memoName)
        
        do {
            let array = try context.fetch(request) as! [Memorandum]
            return array
        } catch{
            print(error)
            abort()
        }
    }
    //随机生成备忘录信息,测试用
    let infoArray = ["测试数据1","测试数据2","测试数据3","测试数据4","测试数据5"]
    func randomAddMemorandums() {
        for i in 0..<5 {
            let memo = NSEntityDescription.insertNewObject(forEntityName: memoName, into: context) as! Memorandum
            
            memo.content = infoArray[i]
            memo.time = Int64(i*10000)
        }
        save()
    }
    //MARK: - 提醒
    let reminderName = "Reminder"
    //返回本地提醒信息
    func getReminderInfo() -> [Reminder] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: reminderName)
        
        do {
            let array = try context.fetch(request) as! [Reminder]
            for reminder in array {
                print(reminder.content!)
            }
            return array
        } catch{
            print(error)
            abort()
        }
    }
    //随机生成提醒信息,测试用
    func randomAddReminders() {
        for i in 0..<5 {
            let memo = NSEntityDescription.insertNewObject(forEntityName: reminderName, into: context) as! Reminder
            memo.content = infoArray[i]
            memo.time = Date.init(timeIntervalSinceReferenceDate: TimeInterval(i))
        }
        save()
    }
}
