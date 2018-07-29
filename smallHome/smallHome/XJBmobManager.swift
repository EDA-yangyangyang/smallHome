//
//  XJBmobManager.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/6/18.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit

class XJBmobManager: NSObject {
    /**
     * 重写init方法在里面注册Bmob
     */
    override init(){
        super.init()
        Bmob.register(withAppKey: "8143b508faab10b4cd8f1573464b644f")
    }
    
    /**
     * 单例
     */
    static let shared = XJBmobManager()
    /**
     * 获取当前用户
     */
    lazy var currentUser:BmobUser? = {
        return BmobUser.current()
    }()
}
//MARK: - 备忘录提醒增删查改
extension XJBmobManager {
    /**
     * 查询自己所在家庭所有备忘录
     */
    func getMemos(block: @escaping (Error?,Array<BmobObject>?) -> Swift.Void){
        let query = BmobQuery(className: memo_memoString)!
        let inQuery = BmobQuery(className: group_nameString)!
        let group = currentUser!.object(forKey: user_groupString) as! BmobObject
        inQuery.whereKey(objectIdString, equalTo: group.objectId!)
        query.whereKey(memo_groupString, matchesQuery: inQuery)
        query.limit = 100
        query.findObjectsInBackground { (array, error) in
            block(error,array as? Array<BmobObject>)
            if error != nil {
                delog(error)
            }
        }
    }
    /**
     * 删除一个备忘录
     */
    func deleteMemo(memo: BmobObject,block: @escaping (Error?) -> Swift.Void){
        memo.deleteInBackground { (bool, error) in
            block(error)
            if bool == false {
                delog(error)
            }
        }
    }
    /**
     * 更新一个备忘录
     */
    func updateMemo(memo: BmobObject,block: @escaping (Error?) -> Swift.Void){
        memo.updateInBackground { (bool, error) in
            block(error)
            if bool == false {
                delog(error)
            }
        }
    }
    /**
     * 发布一个备忘录
     */
    func addMemo(header: String,recivers: Array<BmobObject>?,content: String,block: @escaping (Error?,BmobObject?) -> Swift.Void) {
        let memo = BmobObject(className: memo_memoString)!
        memo.setObject(header, forKey: memo_headerString)
        memo.setObject(content, forKey: memo_contentString)
        memo.setObject(currentUser, forKey: memo_starterString)
        memo.setObject(currentUser!.object(forKey: user_groupString) , forKey: user_groupString)
        memo.setObject(false, forKey: memo_archivedString)
        //FIXME: 这里的recivers没有做任何处理呢还
        memo.saveInBackground { (bool, error) in
            block(error,memo)
            if(bool == false){
                if error != nil {
                    delog(error)
                }
                abort()
            }
        }
    }
}
//MARK: - 更新相关
extension XJBmobManager {
    /**
     * 更新用户
     */
}
//MARK: - 创建相关
extension XJBmobManager {
    /**
     * 登录
     * @param   username    用户账号
     * @param   password    密码
     * @param   block   创建成功后的回调
     */
    func loginUser(username: String, password: String,block: @escaping (Error?,BmobUser?) -> Swift.Void){
        BmobUser.loginInbackground(withAccount: username, andPassword: password) { (user, error) in
            if error != nil{
                delog(error)
            }else{
                self.currentUser = user
            }
            block(error,user)
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
        let user = BmobUser()
        user.username = username
        user.password = password
        user.setObject(name, forKey: user_nameString)
        user.signUpInBackground { (bool, error) in
            block(error,user)
            if bool==true {
                self.currentUser = user
            }else{
                if error != nil {
                    print(error! as Error)
                }
                abort()
            }
        }
    }
    /**
     * 当前用户创建一个Group
     * @param   groupName    group的名字
     * @param   block   创建成功后的回调
     */
    func creatGroup(groupName: String,block: @escaping (Error?,BmobObject?) -> Swift.Void){
        //如果当前用户为空一般是没办法调用这个方法的,除非是数据错误
        if(currentUser == nil){
            abort()
        }
        //如果用户已经属于一个群组,也是没办法调用的
        if(currentUser!.object(forKey: user_groupString) != nil){
            abort()
        }
        let group = BmobObject(className: group_groupString)!
        group.setObject(groupName, forKey: group_groupString)
        group.setObject(currentUser, forKey: group_createrString)
        group.saveInBackground { (bool, error) in
            block(error,group)
            if bool==true {
                //用户设置自己属于的group
                self.currentUser!.setObject(group, forKey: user_groupString)
                self.currentUser!.updateInBackground(resultBlock: { (bool, error) in
                    if bool==false {
                        if error != nil {
                            delog(error!)
                        }
                    }else{
                        delog("用户更新group成功")
                    }
                })
            }else{
                if error != nil {
                    delog(error!)
                }
                abort()
            }
        }
    }
    /**
     * 获取所有名字为name的Group
     * @param   group    group
     * @param   block   创建成功后的回调
     */
    func getGroups(groupName: String,block: @escaping (Error?,Array<BmobObject>?) -> Swift.Void){
        let query = BmobQuery(className: group_groupString)!
        query.whereKey(group_nameString, equalTo: groupName)
        query.findObjectsInBackground { (array, error) in
            if error != nil {
                delog(error)
            }
            block(error,array as? Array<BmobObject>)
        }
        
    }
    /**
     * 当前用户加入一个Group
     * @param   group    group
     * @param   block   创建成功后的回调
     */
    func joinGroup(group: BmobObject, block: @escaping (Error?,BmobObject?) -> Swift.Void){
        //如果当前用户为空一般是没办法调用这个方法的,除非是数据错误
        if currentUser == nil {
            abort()
        }
        //如果用户已经属于一个群组,也是没办法调用的
        if currentUser!.object(forKey: user_groupString) != nil {
            abort()
        }
        let relation = BmobRelation()
        relation.add(currentUser)
        group.add(relation, forKey: group_usersString)
        group.updateInBackground { (bool, error) in
            block(error,group)
            //如果失败了
            if bool == false {
                if error != nil {
                    delog(error)
                }
            }
            //如果成功了
            else{
                self.addGroupToUser(user: self.currentUser!, group: group)
                self.addUserToGroup(user: self.currentUser!, group: group)
            }
        }
    }
    /**
     * 将user填入group中
     */
    func addUserToGroup(user: BmobUser, group: BmobObject){
        //同时group赋值给user的group
        self.currentUser!.setObject(group, forKey: user_groupString)
        self.currentUser!.updateInBackground(resultBlock: { (bool, error) in
            if bool==false {
                if error != nil {
                    delog(error!)
                }
            }else{
                delog("用户更新group成功")
                //FIXME: 然后将这个同步更新到数据库
            }
        })
    }
    /**
     * 将group赋值给user的group
     */
    func addGroupToUser(user: BmobUser, group: BmobObject){
        //将这个用户添加到group中
        let relation = BmobRelation()
        relation.add(group)
        group.add(relation, forKey: group_usersString)
        group.updateInBackground(resultBlock: { (bool, error) in
            if bool == false {
                if error != nil {
                    delog(error)
                }
            }
            else {
                delog("添加成功")
                //FIXME: 然后将这个同步更新到数据库
            }
        })
    }
    /**
     * 当前用户上传头像
     */
    func uploadUserHeadImage(image: UIImage, block: @escaping (Error?,String?) -> Swift.Void){
        let data = UIImagePNGRepresentation(image)
        let fileName = String(format: "%s.png", currentUser!.username)
        let file = BmobFile(fileName: fileName, withFileData: data)!
        
        file.save { (bool, error) in
            delog(error)
            if error == nil {
                self.currentUser!.setObject(file, forKey: user_headerImageString)
                self.currentUser?.updateInBackground(resultBlock: { (bool, error) in
                    delog(file)
                    delog(self.currentUser)
                    block(error, file.url)
                    
                })
            }
        }
        
    }
    
}
