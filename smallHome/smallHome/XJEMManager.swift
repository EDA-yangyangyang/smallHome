//
//  XJEMManager.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/7/22.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit

class XJEMManager: NSObject {
    
    static var shared:XJEMManager = {
        let manager = XJEMManager()
        manager.initConfig()
        return manager
    }()
    
    var isLogin = false
    /**
     * 羊羊羊注释:
     * 聊天管理者
     */
    let chatManager = EMClient.shared().chatManager!
    
    /**
     * 羊羊羊注释:
     * 单一管理者
     */
    lazy var groupManager = EMClient.shared().groupManager!
    /**
     * 羊羊羊注释:
     * 单一会话  操作聊天消息 EMMessage 的容器
     */
    lazy var conversation: EMConversation = {
        return EMClient.shared().chatManager.getConversation(group!.groupId, type: EMConversationTypeGroupChat, createIfNotExist: true)
    }()
    /**
     * 羊羊羊注释:
     * 单一群组
     */
    lazy var group: EMGroup? = getMyGroup()
    /**
     * 羊羊羊注释:
     * 回调的通用操作
     */
    func deal<Type>(obj: Type?, error: EMError?, completion: @escaping(Type?,EMError?)->Swift.Void){
        deal(error: error)
        completion(obj,error)
    }
    func deal(error: EMError?){
        if error != nil {
            delog(error!.errorDescription)
        } else {
            delog("没有error")
        }
    }
    /**
     * 羊羊羊注释:
     * 初始化一些基本信息
     */
    func initConfig(){
        chatManager.add(self, delegateQueue: DispatchQueue.init(label: "charQueue"))
        delog("设置代理成功")
    }
    
}
//MARK: - 聊天相关 向自己的群组发送一条消息  获取消息
extension XJEMManager: EMChatManagerDelegate{
    /**
     * 羊羊羊注释:
     * 发送一条消息
     */
    func sendMessage(content: String,completion: @escaping (EMMessage?,EMError?) -> Void){
        if group == nil {
            delog("还没有找到群组")
            completion(nil,EMError(description: "还没有找到群组", code: EMErrorGeneral))
            return
        }
        let messageBody = EMTextMessageBody(text: content)
        let username = EMClient.shared().currentUsername
        let message = EMMessage(conversationID: conversation.conversationId, from: username, to: conversation.conversationId, body: messageBody, ext: nil)
        message?.chatType = EMChatTypeGroupChat
        
        chatManager.send(message, progress: nil) { (msg, error) in
            self.deal(obj: msg, error: error, completion: completion)
        }
    }
    /**
     * 羊羊羊注释:
     * 获取一堆messages
     */
    func getMessages(completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        getMessages(message: nil, count: 20, completion: completion)
    }
    /**
     * 羊羊羊注释:
     * @param message 根据这一个message获取到它之前的message
     */
    func getMessages(message: EMMessage, completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        getMessages(message: message, count: 20, completion: completion)
    }
    /**
     * 羊羊羊注释:
     * @param message 根据这一个message获取到它之前的message
     * @param count 限制数量,这个不填就是20个
     */
    func getMessages(message: EMMessage?, count: Int, completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        getMessages(message: message, count: count, direction: EMMessageSearchDirectionUp, completion: completion)
    }
    /**
     * 羊羊羊注释:
     * @param message 根据这一个message获取到它之前的message
     * @param count 限制数量,这个不填就是20个
     * @param direction 刷新的方向,默认是向上的
     */
    func getMessages(message: EMMessage?, count: Int, direction: EMMessageSearchDirection, completion: @escaping ([EMMessage]?,EMError?) -> Swift.Void){
        conversation.loadMessagesStart(fromId: message?.messageId, count: 20, searchDirection: direction) { (messages, error) in
            self.deal(obj: messages as? [EMMessage], error: error, completion: completion)
        }
    }
    /**
     * 羊羊羊注释:
     * 收到消息以后的代理
     */
    func messagesDidReceive(_ aMessages: [Any]!) {
        delog(aMessages)
    }
}
//MARK: - 群组相关,创建群组,寻找群组,加入群组,获取我的群组
extension XJEMManager{
    /**
     * 羊羊羊注释:
     * 创建一个群组
     */
    func createGroup(groupName: String,completion: @escaping (EMGroup?,EMError?) -> Swift.Void){
        let setting = EMGroupOptions()
        setting.maxUsersCount = 50
        setting.isInviteNeedConfirm = false
        setting.style = EMGroupStylePublicOpenJoin
        EMClient.shared().groupManager.createGroup(withSubject: groupName, description: "", invitees: [], message: "", setting: setting) { (group, error) in
            self.deal(obj: group, error: error, completion: completion)
        }
    }
    /**
     * 羊羊羊注释:
     * 查找相关群组
     */
    func findGroup(groupId:String,completion: @escaping (EMGroup?,EMError?) -> Swift.Void){
        EMClient.shared().groupManager.getGroupSpecificationFromServer(withId: groupId) { (group, error) in
            self.deal(obj: group, error: error, completion: completion)
        }
    }
    /**
     * 羊羊羊注释:
     * 得到我的群组
     */
    func getMyGroup() -> EMGroup?{
        let groups:[EMGroup] = groupManager.getJoinedGroups() as? [EMGroup] ?? [EMGroup]()
        
        if groups.count >= 2 {
            abort()
        }
        if groups.count == 0 {
            delog("本地没有找到群组,现在尝试从后台获取群组")
            groupManager.getJoinedGroupsFromServer(withPage: 0, pageSize: 5) { (array, error) in
                let array = array as? [EMGroup]
                if error == nil && array!.count > 1 {
                    abort()
                }
                self.deal(obj: array?[0], error: error, completion: { (group, error) in
                    if error == nil {
                        delog("从后台获取群组成功\(group!.subject)")
                        self.group = group
                        self.groupManager.getGroupSpecificationFromServer(withId: group?.groupId, completion: { (group, error) in
                            self.deal(obj: group, error: error, completion: { (_, _) in
                                
                            })
                        })
                    }
                })
            }
            return nil
        }
        if groups.count == 1 {
            delog("自动获取群组成功!!")
        }
        return groups[0]
    }
    /**
     * 羊羊羊注释:
     * 加入一个群组
     */
    func joinGroup(group:EMGroup,completion: @escaping (EMGroup?,EMError?) -> Swift.Void){
        joinGroup(groupId: group.groupId, completion: completion)
    }
    /**
     * 羊羊羊注释:
     * 加入一个群组
     */
    func joinGroup(groupId: String, completion: @escaping (EMGroup?,EMError?) -> Swift.Void){
        EMClient.shared().groupManager.joinPublicGroup(groupId) { (group, error) in
            self.deal(obj: group, error: error, completion: completion)
        }
    }
}
//MARK: - 注册和登录
extension XJEMManager{
    /**
     * 羊羊羊注释:
     * 注册用户信息  用户名和密码
     */
    func regist(username: String, password: String,completion: @escaping (String?,EMError?) -> Swift.Void){
        
        EMClient.shared().register(withUsername: username, password: password) { (username, error) in
            self.deal(obj: username, error: error, completion: completion)
        }
    }
    /**
     * 羊羊羊注释:
     * 登录 用户 密码
     */
    func login(username: String, password: String,completion: @escaping (String?,EMError?) -> Swift.Void){
        if EMClient.shared().options.isAutoLogin == false {
            EMClient.shared().login(withUsername: username, password: password) { (username, error) in
                self.deal(obj: username, error: error, completion: completion)
                if error == nil {
                    EMClient.shared().options.isAutoLogin = true
                }
            }
        } else {
            print("已经登录了")
        }
    }
}
