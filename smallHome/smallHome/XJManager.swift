//
//  XJManager.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/6/18.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit
import CoreData
class XJManager: NSObject {

    static let shared = XJManager()
    let currentUser: User? = {
        let buser = bmobManager.currentUser
        if buser == nil {
            return nil
        }
        else {
            let predicate = NSPredicate(format: "%s == %s", objectIdString, buser!.objectId)
            let user = modelManager.getUserInfo(predicate: predicate, sortDescriptors: nil)
            return user[0]
        }
    }()
    func test(){
        
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
     */
    func loginUser(username: String, password: String,block: @escaping (Error?,BmobUser?) -> Swift.Void){
        EMManager.login(username: username, password: password) { (username, error) in
            if error != nil {
                delog(error?.errorDescription)
            }
            else {
                //EM创建成功了以后
                bmobManager.loginUser(username: username!, password: password) { (error, buser) in
                    if error != nil {
                        delog(error)
                    }else{
                        //如果非空则把新的user加到数据库里面
                        modelManager.addUser(objectId: buser!.objectId,block: { (user) in
                            self.transObjectToUser(object: buser!, user: user)
                        })
                    }
                    block(error,buser)
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
    func creatUser(username: String, password: String, name: String,block: @escaping (Error?,BmobUser?) -> Swift.Void){
        EMManager.regist(username: username, password: password) { (_, error) in
            if error == nil {
                bmobManager.creatUser(username: username, password: password, name: name) { (error, buser) in
                    if error != nil {
                        delog(error)
                    }else{
                        //如果非空则把新的user加到数据库里面
                        modelManager.addUser(objectId: buser!.objectId, block: { (user) in
                            self.transObjectToUser(object: buser!, user: user)
                        })
                    }
                    block(error,buser)
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
            if error != nil {
                bmobManager.creatGroup(groupName: groupName) { (error, object) in
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
        group.emID = object.object(forKey:group_nameString) as? String
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
