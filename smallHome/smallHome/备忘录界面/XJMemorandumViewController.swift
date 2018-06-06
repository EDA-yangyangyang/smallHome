//
//  XJMemorandumViewController.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/5/24.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit

class XJMemorandumViewController: UITableViewController, XJMemoDelegate {
    
    //设置重用标识符
    let memoReuseIdentifier = "memoReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "Memo"
        self.title = "MMemo"
//        self.navigationController?.navigationBar.color
        
        self.navigationController?.navigationBar.tintColor = g_titleColor
        
        //设置web代理
        XJWebManager.shared.memoDelegate = self
        //设置高度
        tableView.rowHeight = 187;
        //注册单元格
        tableView.register(UINib(nibName: "XJMemoCell", bundle: nil), forCellReuseIdentifier: memoReuseIdentifier)
        //更新视图数据
        tableView.reloadData()
        //取消tableView的那条横线
        tableView.separatorStyle = .none
    }
    //头部视图及高度
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        headView.backgroundColor = g_barColor
        
        return headView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    //数据源
    lazy var dataArray: [Memorandum] = {
        let manager = XJModelManager.init()
        return manager.getMemorandumInfo()
    }()
    //收到新数据以后调用的代理方法
    func recivedNewMemo(memo: Memorandum?) {
        
    }
    // MARK: - tableView 数量选项以及cell具体设置
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: memoReuseIdentifier, for: indexPath) as! XJMemoCell
        cell.setModel(memo: dataArray[indexPath.row])
        return cell
    }
    
}
