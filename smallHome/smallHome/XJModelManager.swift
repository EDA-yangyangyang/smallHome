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
    //常量字符串属性
    let memoName = "Memorandum"
    let reminderName = "Reminder"
    let personName = "Person"
    //人物单例
    static let sharedPerson = XJPersonManager.sharedPerson
    //MARK: - 代理
    weak open var reminderDelegate: XJReminderDelegate?{
        didSet{
            XJWebManager.shared.reminderDelegate = reminderDelegate
        }
    }
    weak open var memoDelegate: XJMemoDelegate?{
        didSet{
            XJWebManager.shared.memoDelegate = memoDelegate
        }
    }
    //MARK: - 常用方法放在这里
    ///返回备忘录信息
    public func memorandumInfo() -> [Memorandum] {
        return XJModelManager.shared.getMemorandumInfo()
    }
    ///返回提醒信息
    public func reminderInfo() -> [Reminder] {
        return XJModelManager.shared.getReminderInfo()
    }
    //一个单例
    static let shared = XJModelManager()
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
}
//数据库的增删查改
extension XJModelManager {
    //MARK: - 返回一组信息 - 查
    ///返回本地备忘录信息
    func getMemorandumInfo() -> [Memorandum] {
        return getMemorandumInfo(predicate: nil, sortDescriptors: nil)
    }
    func getMemorandumInfo(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Memorandum] {
        return getInfo(str: memoName, predicate: predicate, sortDescriptors: sortDescriptors) as! [Memorandum]
    }
    //返回本地提醒信息
    func getReminderInfo() -> [Reminder] {
        return getReminderInfo(predicate: nil, sortDescriptors: nil)
    }
    func getReminderInfo(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Reminder] {
        return getInfo(str: reminderName, predicate: nil, sortDescriptors: nil) as! [Reminder]
    }
    //返回所有用户信息
    func getPersonInfo() -> [Person] {
        return getPersonInfo(predicate: nil, sortDescriptors: nil)
    }
    func getPersonInfo(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Person] {
        return getInfo(str: personName, predicate: predicate, sortDescriptors: sortDescriptors) as! [Person]
    }
    //获取对应信息组的封装
    func getInfo(str: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Any] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: str)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        do {
            let array = try context.fetch(request) 
            return array
        } catch{
            delog(error)
            abort()
        }
    }
    //MARK: - 改
    ///修改备忘录内容
    func changeMemorandum(memo: Memorandum, headline: String?, content: String?){
        memo.headline = headline
        memo.content = content
        
    }
    ///修改用户的名字,因为只有一个用户所以不需要加person参数了
//    func changePerson(name: String){
//        person.name = name
//        save()
//    }
    //MARK: - 添加信息 - 增
    //添加一个备忘录
    func addMemo(headline: String, content: String){
        let memo = NSEntityDescription.insertNewObject(forEntityName: memoName, into: context) as! Memorandum
        memo.headline = headline
        memo.content = content
        memo.date = Date()
        save()
    }
    //添加一个提醒
    func addReminder(content: String, date: Date, person:Person?) {
        let reminder = NSEntityDescription.insertNewObject(forEntityName: reminderName, into: context) as! Reminder
        reminder.content = content
        reminder.date = date
        save()
    }
    //添加一个person,id自动添加,测试用
    func addPerson(name: String) -> Person{
        let person = NSEntityDescription.insertNewObject(forEntityName: personName, into: context) as! Person
        person.name = name
        person.id = String(getPersonInfo().count+1)
        return person
    }
    //MARK: - 随机生成数据
    //随机生成备忘录信息,测试用
    func randomAddMemorandums() {
        let infoArray = ["测试数据1","测试数据2","测试数据3","测试数据4","测试数据5"]
        for i in 0..<5 {
            addMemo(headline: "标题"+String(i), content: infoArray[i])
        }
    }
    //随机生成提醒信息,测试用
    func randomAddReminders() {
        let infoArray = ["测试数据1","测试数据2","测试数据3","测试数据4","测试数据5"]
        for i in 0..<5 {
            addReminder(content: infoArray[i], date: Date.init(timeIntervalSinceReferenceDate: TimeInterval(i)), person: nil)
        }
    }
    //随机生成用户方法,测试用
    func randomAddPersons() {
        for i in 0..<5 {
            _ = addPerson(name: "测试用户"+String(i))
        }
    }
    //MARK: - 删除部分,尽量不要直接用remove方法,用前三个 - 删
    ///删除一个备忘录,还没测试,不一定有用
    func removeMemorandums(memo: Memorandum) {
        remove(obj: memo)
    }
    ///删除一个提醒,还没测试,不一定有用
    func removeReminder(reminder: Reminder) {
        remove(obj: reminder)
    }
    ///删除一个person,还没测试,不一定有用
    func removePerson(person: Person){
        remove(obj: person)
    }
    //删除函数
    func remove(obj: NSManagedObject){
        context.delete(obj)
        save()
    }
    //MARK: - 测试时候用的
    //删除所有备忘录信息
    func removeAllMemorandums() {
        remove(str: memoName)
    }
    //删除所有提示信息
    func removeAllRemenders() {
        remove(str: reminderName)
    }
    func removeAllPersons(){
        remove(str: personName)
    }
    //删除str对应的数据
    func remove(str: String) {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: str)
        do {
            let array = try context.fetch(request) as! [NSManagedObject]
            for item in array {
                context.delete(item)
            }
            save()
        } catch {
            delog(error as NSError)
            
            abort()
        }
    }
}
