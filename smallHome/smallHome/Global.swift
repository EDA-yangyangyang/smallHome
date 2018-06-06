//
//  Global.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/6/6.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit
//添加了全局变量文件Global,以后有需要用到的颜色什么的都写在这里然后用就行
//我觉得这里面的变量前面加一个g_ 前缀挺好的
//颜色函数
func colorWithRgb(_ red: CGFloat,_ green: CGFloat,_ blue: CGFloat) -> UIColor{
    return UIColor(displayP3Red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
}

//顶部bar的颜色
let g_barColor = colorWithRgb(42,37,35)

//背景色
let g_cellBackgroundColor = colorWithRgb(255,243,233)

//标题颜色
let g_titleColor = colorWithRgb(252,223,199)

