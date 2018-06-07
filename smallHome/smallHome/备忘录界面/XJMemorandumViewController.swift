//
//  XJMemorandumViewController.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/5/24.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit
import SnapKit
class XJMemorandumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XJMemoDelegate{
    //tableView懒加载
    lazy var tableView: UITableView = {
//        let rect = CGRect(x: 0, y: 44, width: self.view.frame.width, height: self.view.frame.height-44)
        return UITableView(frame: self.view.frame, style: .grouped)
    }()
    //设置重用标识符
    let memoReuseIdentifier = "memoReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes
        
//        self.title = "MMemo"
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
        //设置tableView代理
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        
        self.view.backgroundColor = .red
    }
    //头部视图及高度
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        headView.backgroundColor = g_barColor
        
        return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    //数据源
    lazy var dataArray: [Memorandum] = {
        let manager = XJModelManager.init()
        return manager.getMemorandumInfo()
    }()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bringNewView(indexPath: indexPath)
        
    }
    func bringNewView(indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath) as! XJMemoCell
        
        let mainView = cell.mainView!
        let vc = XJMemoDetailController()
        vc.memo = cell._memo
        self.view.addSubview(vc.view)
        vc.view.backgroundColor = UIColor.clear
        vc.view.alpha = 1.0
        let cellRact = mainView.frame
        let rect = mainView.convert(mainView.bounds, to: self.view.window)
        vc.view.addSubview(mainView)
        mainView.frame = rect
        let transform = mainView.transform
        
        //第一次缩小
        UIView.animate(withDuration: 0.25, animations: {
            mainView.transform = transform.scaledBy(x: 0.7, y: 0.7)
        }) { (_) in
            vc.view.frame = mainView.frame
//            mainView.transform = transform
            vc.view.backgroundColor = .blue
            mainView.removeFromSuperview()
            //第二次放大
            UIView.animate(withDuration: 0.25, animations: {
                vc.view.frame = self.view.frame
                vc.view.alpha = 0.5
                
                
            }, completion: { (_) in
                self.navigationController!.pushViewController(vc, animated: false)
                mainView.transform = transform
                cell.recoverMainView(mainView: mainView)
                
            })
        }
    }
    
    //收到新数据以后调用的代理方法
    func recivedNewMemo(memo: Memorandum?) {
        
    }
    // MARK: - tableView 数量选项以及cell具体设置
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: memoReuseIdentifier, for: indexPath) as! XJMemoCell
        cell.recoverMainView(mainView: cell.mainView)
        cell.setModel(memo: dataArray[indexPath.row])
        return cell
    }
}
