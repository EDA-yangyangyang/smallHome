//
//  XJPersonManager.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/5/24.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit
let personID = "personID"
class XJPersonManager: NSObject {
    
    static let sharedPerson: Person = {
        //先查看本地是否有对应的person id
        if let id = UserDefaults.standard.string(forKey: personID){
            //如果有
            let predicate = NSPredicate.init(format: "id==%s", id)
            let array = XJModelManager.shared.getPersonInfo(predicate: predicate, sortDescriptors: nil)
            if(array.count != 1){
                abort()
            }
            return array[0]
        }else{
            //如果没有emmmmmm需要一开始就让新用户输入名字然后获取到对应的id存储到本地所以一定会有的
            let person = XJModelManager.shared.addPerson(name: "localHost")
            return person
            //FIXME: 这里以后要改,直接abort吧...暂时就创建一个新的Person
            
        }
        
    }()
}
