//
//  XJManager.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/6/18.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit
import CoreData
//接收消息的代理
protocol XJMessageDelegate {
    func didReceiveMessage(Message: [EMMessage])
}

class XJManager: NSObject {
    ///单例变量
    static let shared = XJManager()
    ///代理
    var messageDelegate:XJMessageDelegate?
    let currentUser: User? = {
        let buser = bmobManager.currentUser

        if buser == nil {
            return nil
        }
        else {
            let predicate = NSPredicate(format: "\(objectIdString) == %@", buser!.objectId)
            let user = modelManager.getUserInfo(predicate: predicate, sortDescriptors: nil)
            if user.count == 0 {
                return nil
            } else {
                return user[0]
            }
        }
    }()
    
    /**
     * 羊羊羊注释:
     * 自动化登录的一些设置,目前还没有设置
     */
    func initalizeAuto(){
        
    }
    /**
     * 羊羊羊注释:
     * 重写init
     */
    override init() {
        super.init()
        initalizeAuto()
    }
    ///测试用的函数
    func test(){
        delog("func_test")
        
//        logout()
        
//        self.creatUser(username: "test3", password: "123456", name: "yyy3") { (error, user) in
//            if error == nil {
//                delog(user)
//            } else {
//                delog(error)
//            }
//        }
        
        self.loginUser(username: "test3", password: "123456") { (error, user) in
            if error == nil {
                delog(user)
            }
        }
        
//        self.creatGroup(groupName: "test_y") { (error, group) in
//            if error == nil {
//                delog(group)
//            }
//        }
        
        self.getGroups(groupName: "test_y") { (error, groups) in
            if error == nil {
                delog(groups)
                self.joinGroup(group: groups![0], block: { (error, group) in
                    if error == nil {
                        delog("加入成功")
                    }
                })
            }
        }
        
//        self.addMemo(header: "1", recivers: nil, content: "qwe") { (error, memo) in
//            if error == nil {
//                delog(memo)
//
//                self.getMemos { (error0, memos) in
//                    delog(memos[0])
//                }
//            }
//        }
        
//        self.sendMessage(content: "testhahaha") { (msg, error) in
//            if error == nil {
//                delog(msg)
//            }
//        }
        
        
    }
    /**
     * 羊羊羊注释:
     * 账户注销
     */
    func logout() {
        delog("账户注销")
        BmobUser.logout()
        EMClient.shared().logout(false)
    }
}

//MARK: - 发送接收消息相关
extension XJManager: EMChatManagerDelegate {
    func sendMessage(content: String, block: @escaping (EMMessage?, EMError?) -> Swift.Void) {
        EMManager.sendMessage(content: content, completion: block)
    }
    /**
     * 羊羊羊注释:
     * 获取一堆messages
     */
    func getMessages(completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        EMManager.getMessages(completion: completion)
    }
    /**
     * 羊羊羊注释:
     * @param message 根据这一个message获取到它之前的message
     */
    func getMessages(message: EMMessage, completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        EMManager.getMessages(message: message, completion: completion)
    }
    /**
     * 羊羊羊注释:
     * @param message 根据这一个message获取到它之前的message
     * @param count 限制数量,这个不填就是20个
     */
    func getMessages(message: EMMessage?, count: Int, completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        EMManager.getMessages(message: message, count: count, completion: completion)
    }
    /**
     * 羊羊羊注释:
     * @param message 根据这一个message获取到它之前的message
     * @param count 限制数量,这个不填就是20个
     * @param direction 刷新的方向,默认是向上的
     */
    func getMessages(message: EMMessage?, count: Int, direction: EMMessageSearchDirection, completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        EMManager.getMessages(message: message, count: count, direction: direction, completion: completion)
    }
    /**
     * 羊羊羊注释:
     * 收到了一条新消息以后
     */
    func messagesDidReceive(_ aMessages: [Any]!) {
        delog("收到了消息")
        messageDelegate?.didReceiveMessage(Message: aMessages as! [EMMessage])
    }
}
//MARK: - 备忘录提醒相关
extension XJManager {
    /**
     * 添加一个备忘录
     * @param   header    备忘录标题
     * @param   recivers    想让谁接收到这个memo,暂定设置为nil就好,这个功能先不做,但是接口留着
     * @param   content    备忘录内容
     * @param   block   回调
     */
    func addMemo(header: String,recivers: Array<User>?,content: String,block: @escaping (Error?,Memo?) -> Swift.Void) {
        //网络上传
        var array:Array<BmobObject>?
        //如果设定了recivers
        if recivers != nil && recivers!.count > 0 {
            array = [BmobObject]()
            for item in recivers! {
                array!.append(transUserToObject(user: item))
            }
        }
        bmobManager.addMemo(header: header, recivers: array, content: content) { (error, bmobObject) in
            var _memo:Memo?
            if error != nil {
                delog(error)
            }
            //上传成功之后本地保存
            else {
                modelManager.addMemo(objectId: bmobObject!.objectId, block: { (memo) in
                    self.transObjectToMemo(object: bmobObject!, memo: memo)
                    _memo = memo
                })
            }
            block(error,_memo)
        }
    }
    /**
     * 删除一个备忘录
     * @param   memo    哪个Memo
     * @param   block   回调
     */
    func deleleMemo(memo: Memo,block:@escaping (Error?) -> Swift.Void){
        bmobManager.deleteMemo(memo: transMemoToObject(memo: memo)) { (error) in
            if error != nil {
                delog(error)
            }
            else {
                modelManager.delete(obj: memo)
            }
            block(error)
        }
    }
    /**
     * 获取当前群组所有备忘录
     * @param   block   回调,用来返回新的memo数组,注意这个新的数组和之前的有重叠部分
     */
    func getMemos(block:@escaping (Error?,[Memo]?) -> Swift.Void) -> [Memo]{
        let array = modelManager.getMemoInfo()
        bmobManager.getMemos { (error, array) in
            if error != nil {
                delog(error)
            }else{
                for item in array! {
                    modelManager.addMemo(objectId: item.objectId, block: { (memo) in
                        self.transObjectToMemo(object: item, memo: memo)
                    })
                }
            }
            block(error,modelManager.getMemoInfo())
        }
        return array
    }
    /**
     * 修改一个备忘录
     * 这里的修改有问题,如果修改的时候没有网络那么网络上的是没办法上传的,然后本地的改变了,等有网了的时候会从后台更新一次所有数据然后把自己改了的再改回去
     * @param   memo    哪个Memo
     * @param   block   回调
     */
    func changeMemo(memo: Memo, headline: String?, content: String?,block:@escaping (Error?) -> Swift.Void){
        modelManager.changeMemo(memo: memo, headline: headline, content: content)
        let obj = transMemoToObject(memo: memo)
        bmobManager.updateMemo(memo: obj) { (error) in
            block(error)
        }
    }
}
//MARK: - 用户群组相关
extension XJManager {
    /**
     * 登录
     * @param   username    用户账号
     * @param   password    密码
     * @param   block   创建成功后的回调
     * 这里的user会返回nil,正常现象emmm
     */
    func loginUser(username: String, password: String,block: @escaping (Error?,User?) -> Swift.Void){
        delog("登录EM")
        EMManager.login(username: username, password: password) { (username, error) in
            if error != nil {
                delog(error?.errorDescription)
                block(NSError(domain: error!.errorDescription, code: 0, userInfo: nil) ,nil)
            }
            else {
                delog("登录bmob")
                //EM登录成功了以后
                bmobManager.loginUser(username: username!, password: password) { (error, buser) in
                    var user0:User? = nil
                    if error != nil {
                        delog(error)
                    }else{
                        delog("登录成功")
                        //如果非空则把新的user加到数据库里面
                        modelManager.addUser(objectId: buser!.objectId,block: { (user) in
                            self.transObjectToUser(object: buser!, user: user)
                            user0 = user
                        })
                    }
                    block(error,user0)
                }
            }
        }
        
    }
    /**
     * 创建一个用户
     * @param   username    用户账号
     * @param   password    密码
     * @param   name    名字
     * @param   block   创建成功后的回调
     */
    func creatUser(username: String, password: String, name: String,block: @escaping (Error?,User?) -> Swift.Void){
        EMManager.regist(username: username, password: password) { (EMUser, error) in
            if error == nil {
                bmobManager.creatUser(username: username, password: password, name: name) { (error, buser) in
                    var user0:User!
                    if error != nil {
                        delog(error)
                    }else{
                        //如果非空则把新的user加到数据库里面
                        modelManager.addUser(objectId: buser!.objectId, block: { (user) in
                            self.transObjectToUser(object: buser!, user: user)
                            user0 = user
                        })
                    }
                    block(error,user0)
                }
            }
        }
        
    }
    /**
     * 当前用户创建一个Group
     * @param   groupName    group的名字
     * @param   block   创建成功后的回调
     */
    func creatGroup(groupName: String,block: @escaping (Error?,Group?) -> Swift.Void){
        EMManager.createGroup(groupName: groupName) { (group, error) in
            if error == nil {
                bmobManager.creatGroup(groupName: groupName, EMID: group!.groupId) { (error, object) in
                    var g:Group?
                    if error != nil {
                        delog(error)
                    }
                    else {
                        modelManager.addGroup(objectId: object!.objectId, block: { (group) in
                            self.transObjectToGroup(object: object!, group: group)
                            g = group
                        })
                    }
                    block(error,g)
                }
            }
        }
        
    }
    /**
     * 获取所有名字为name的Group
     * @param   group    group
     * @param   block   创建成功后的回调
     */
    func getGroups(groupName: String,block: @escaping (Error?,Array<Group>?) -> Swift.Void){
        bmobManager.getGroups(groupName: groupName) { (error, barray) in
            var array = [Group]()
            if error != nil {
                delog(error)
            }else{
                for item in barray! {
                    modelManager.addGroup(objectId: item.objectId!, block: { (group) in
                        self.transObjectToGroup(object: item, group: group)
                        array.append(group)
                    })
                }
            }
            block(error,array)
        }
    }
    /**
     * 当前用户加入一个Group
     * @param   group    group
     * @param   block   创建成功后的回调
     */
    func joinGroup(group: Group, block: @escaping (Error?,Group?) -> Swift.Void){
        EMManager.joinGroup(groupId: group.emID!) { (_, error) in
            if error == nil {
                let bgroup = self.transGroupToObject(group: group)
                bmobManager.joinGroup(group: bgroup) { (error, object) in
                    if error != nil {
                        delog(error)
                    }
                    else {
                        
                    }
                    block(error,group)
                }
            }
        }
        
    }
    /**
     * 上传/修改用户头像
     * @param   image    图片
     * @param   password    密码
     * @param   block   创建成功后的回调
     */
    func uploadUserHeaderImage(image: UIImage, block: @escaping (Error?,String?) -> Swift.Void){
        bmobManager.uploadUserHeadImage(image: image) { (error, str) in
            if error != nil {
                delog(error)
            }
            else {
                modelManager.currentUser.headImageUrl = str
                modelManager.save()
            }
            block(error,str)
        }
    }
}
//MARK: - 转换相关
extension XJManager {
    func transObjectToMemo(object: BmobObject, memo: Memo){
        if object.className != memo_memoString {
            abort()
        }
        memo.objectId = object.objectId
        memo.content = object.object(forKey: memo_contentString) as? String
        memo.updatedAt = object.updatedAt
        //FIXME: 这个数组需要再获取一遍
        //        memo.endPersons = object.object(forKey: memo_toPersons) as? NSSet
        memo.startPerson = object.object(forKey: memo_starterString) as? User
    }
    func transObjectToUser(object: BmobUser, user: User){
        if object.className != user_userString {
            abort()
        }
        user.updatedAt = object.updatedAt
        user.objectId = object.objectId
        user.username = object.username
        user.emID = object.object(forKey: user_emIDString) as? String
        user.name = object.object(forKey: user_nameString) as? String
        user.belongGroup = object.object(forKey: user_groupString) as? Group
        let file = object.object(forKey: user_headerImageString) as? BmobFile
        user.headImageUrl = file?.url
    }
    func transObjectToGroup(object: BmobObject, group: Group){
        if object.className != group_groupString {
            abort()
        }
        group.updatedAt = object.updatedAt
        group.objectId = object.objectId
        group.emID = object.object(forKey:group_emIDString) as? String
        group.name = object.object(forKey:group_nameString) as? String
        
        let file = object.object(forKey: user_headerImageString) as? BmobFile
        group.headImageUrl = file?.url
        //FIXME: 这里通过id获取到这个user
        //        let userId = (object.object(forKey: group_createrString) as? BmobUser)?.objectId
    }
    func transMemoToObject(memo: Memo) -> BmobObject{
        let obj = BmobObject(className: memo_memoString)!
        obj.objectId = memo.objectId
        obj.setObject(memo.group, forKey: memo_groupString)
        obj.setObject(memo.headline, forKey: memo_headerString)
        obj.setObject(memo.content, forKey: memo_contentString)
        return obj
    }
    func transGroupToObject(group: Group) -> BmobObject{
        let obj = BmobObject(className: group_groupString)!
        obj.objectId = group.objectId
        obj.setObject(group.emID, forKey: group_emIDString)
        obj.setObject(group.name, forKey: group_nameString)
        obj.setObject(group.creater, forKey: group_createrString)
        return obj
    }
    func transUserToObject(user: User) -> BmobObject{
        let obj = BmobUser()
        obj.objectId = user.objectId
        obj.username = user.username
        obj.setObject(user.emID, forKey: user_emIDString)
        obj.setObject(user.name, forKey: user_nameString)
        obj.setObject(user.belongGroup, forKey: user_groupString)
        return obj
    }
}
