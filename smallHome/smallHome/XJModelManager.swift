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
    let memoName = "Memo"
    let reminderName = "Reminder"
    let UserName = "User"
    let groupName = "Group"
    let bmobManager = XJBmobManager.shared
    lazy var currentUser: User = {
        return getCurrentUser()
    }()
    
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
extension XJModelManager {
//    func getCurrentUser() -> User{
//        
//    }
}
//MARK: -数据库的增删查改

extension XJModelManager {
    //MARK: - 查
    ///查询一个Memo是否已经存在数据库中
    func findMemoExist(objectId: String) -> Bool {
        let predicate = NSPredicate(format: "objectId == %s", objectId)
        let answer = getInfo(str: memoName, predicate: predicate, sortDescriptors: nil)
        return answer.count > 0 ? true : false
    }
    ///获取当前User
    func getCurrentUser() -> User {
        return getUserByID(objectId: XJBmobManager.shared.currentUser!.objectId)!
    }
    ///通过一个id获取到user
    func getUserByID(objectId: String) -> User?{
        let predicate = NSPredicate(format: "%s == %s", objectIdString, objectId)
        let info = getInfo(str: UserName, predicate: nil, sortDescriptors: nil) as! [User]
        if info.count > 0 {
            return info[0] as? User
        }
        else {
            return nil
        }
    }
    ///返回本地备忘录信息
    func getMemoInfo() -> [Memo] {
        return getMemoInfo(predicate: nil, sortDescriptors: nil)
    }
    func getMemoInfo(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Memo] {
        return getInfo(str: memoName, predicate: predicate, sortDescriptors: sortDescriptors) as! [Memo]
    }
    //返回本地提醒信息
    func getReminderInfo() -> [Reminder] {
        return getReminderInfo(predicate: nil, sortDescriptors: nil)
    }
    func getReminderInfo(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Reminder] {
        return getInfo(str: reminderName, predicate: nil, sortDescriptors: nil) as! [Reminder]
    }
    //返回所有用户信息
    func getUserInfo() -> [User] {
        return getUserInfo(predicate: nil, sortDescriptors: nil)
    }
    func getUserInfo(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [User] {
        return getInfo(str: UserName, predicate: predicate, sortDescriptors: sortDescriptors) as! [User]
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
    func changeMemo(memo: Memo, headline: String?, content: String?){
        memo.headline = headline
        memo.content = content
        save()
    }
    //MARK: - 增
    /**
     * 添加一个备忘录
     */
    func addMemo(objectId: String, block: (Memo)->Swift.Void){
        let predicate = NSPredicate(format: "objectId == %s", objectId)
        if getMemoInfo(predicate: predicate, sortDescriptors: nil).count != 0 {
            delog("memo已经存在,现在去更新memo")
            //FIXME: 更新啊更新
            return
        }
        let memo = NSEntityDescription.insertNewObject(forEntityName: memoName, into: context) as! Memo
        block(memo)
        save()
    }
    /**
     * 添加一个用户
     */
    func addUser(objectId: String, block: (User)->Swift.Void){
        let predicate = NSPredicate(format: "objectId == %s", objectId)
        if getUserInfo(predicate: predicate, sortDescriptors: nil).count != 0 {
            delog("user已经存在,现在去更新user")
            //FIXME: 更新啊更新
            return
        }
        let user = NSEntityDescription.insertNewObject(forEntityName: UserName, into: context) as! User
        block(user)
        save()
    }
    /**
     * 添加一个Group
     */
    func addGroup(objectId: String, block: (Group)->Swift.Void){
        let predicate = NSPredicate(format: "objectId == %s", objectId)
        if getUserInfo(predicate: predicate, sortDescriptors: nil).count != 0 {
            delog("user已经存在")
        }
        let group = NSEntityDescription.insertNewObject(forEntityName: groupName, into: context) as! Group
        block(group)
        save()
    }
    //MARK: - 删
    ///删除一个备忘录,还没测试,不一定有用
    func deleteMemos(memo: Memo) {
        delete(obj: memo)
    }
    ///删除一个User,还没测试,不一定有用
    func deleteUser(User: User){
        delete(obj: User)
    }
    //删除函数
    func delete(obj: NSManagedObject){
        context.delete(obj)
        save()
    }
    //MARK: - 测试时候用的
    //删除所有备忘录信息
    func deleteAllMemos() {
        delete(str: memoName)
    }
    func deleteAllUsers(){
        delete(str: UserName)
    }
    //删除str对应的数据
    func delete(str: String) {
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
