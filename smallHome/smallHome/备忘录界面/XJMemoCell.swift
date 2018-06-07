//
//  XJMemoCell.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/5/24.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit

class XJMemoCell: UITableViewCell {
    //中间集合视图
    @IBOutlet weak var mainView: UIView!
    //左上角title
    @IBOutlet weak var title: UILabel!
    //右下角日期
    @IBOutlet weak var dateLabel: UILabel!
    //左下角头像
    @IBOutlet weak var info_head: UIImageView!
    //左下角名字
    @IBOutlet weak var info_name: UILabel!
    //中间视图view
    @IBOutlet weak var centerView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = g_cellBackgroundColor
        
        mainView.snp.makeConstraints { (make) in
            make.top.left.equalTo(20)
            make.width.equalTo(self.frame.width-40)
            make.bottom.equalTo(0)
        }
        title.snp.makeConstraints { (make) in
            make.left.equalTo(23)
            make.top.equalTo(16)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-13)
            make.right.equalTo(-24)
        }
        info_head.snp.makeConstraints { (make) in
            make.left.equalTo(24)
            make.bottom.equalTo(-13)
            make.height.width.equalTo(13)
        }
        info_name.snp.makeConstraints { (make) in
            make.left.equalTo(44)
            make.bottom.equalTo(-13)
            make.height.equalTo(13)
        }
        centerView.snp.makeConstraints { (make) in
            make.left.equalTo(23)
            make.right.equalTo(-25)
            make.top.equalTo(44)
            make.bottom.equalTo(-36)
        }
    }
    
    public func recoverMainView(mainView: UIView){
        self.addSubview(mainView)
        self.mainView = mainView
        mainView.snp.remakeConstraints { (make) in
            make.top.left.equalTo(20)
            make.width.equalTo(self.frame.width-40)
            make.bottom.equalTo(0)
        }
    }
    
    //视图更新写在这里
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setMainView(style: mainView)
        self.addSubview(mainView)
        self.centerView.isUserInteractionEnabled = false
    }
    func setMainView(style: UIView){
        //圆角
        style.layer.cornerRadius = 13
        //背景颜色
        style.layer.backgroundColor = UIColor(red: 255.0 / 255.0, green: 253.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0).cgColor
        //设置阴影
        style.layer.shadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.2).cgColor
        style.layer.shadowOpacity = 0.5
        style.layer.shadowOffset = CGSize(width: 0, height: 3)
        style.layer.shadowRadius = 5
        
        
    }
    
    
    var _memo:Memorandum?
    open func setModel(memo : Memorandum){
        _memo = memo
//        title.text = memo.headline ?? "memo_headline设置失误"
//        dateLabel.text = "test.test"
//        info_head.backgroundColor = .black
//        info_name.text = memo.startPerson?.name ?? "info_name"
    }
    
    
}
