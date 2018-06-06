//
//  XJHomeViewController.swift
//  smallHome
//
//  Created by 羊羊羊 on 2018/5/24.
//  Copyright © 2018年 杨杨杨. All rights reserved.
//

import UIKit

class XJHomeViewController: UIViewController {
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = g_barColor
        
        
        //瞎jb写的,先这样,以后再改
        self.view.backgroundColor = .white
        let btn1 = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
        
        self.view.addSubview(btn1)
        
        let btn2 = UIButton.init(frame: CGRect.init(x: 300, y: 100, width: 100, height: 100))
        btn2.setTitle("备忘录", for: UIControlState.normal)
        btn2.setTitleColor(.white, for: .normal)
        btn2.backgroundColor = .blue
        btn2.addTarget(self, action: #selector(goToMemorandum), for: .touchUpInside)
        self.view.addSubview(btn2)
        
        let btn3 = UIButton.init(frame: CGRect.init(x: 100, y: 300, width: 100, height: 100))
        btn3.setTitle("提醒", for: .normal)
        btn3.backgroundColor = .blue
        btn3.addTarget(self, action: #selector(goToRemind), for: .touchUpInside)

        self.view.addSubview(btn3)
        
        let btn4 = UIButton.init(frame: CGRect.init(x: 300, y: 300, width: 100, height: 100))
        self.view.addSubview(btn4)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        super.viewDidDisappear(animated)
    }
    //MARK: 点击进入备忘录界面
    @objc func goToMemorandum(){
        let vc = XJMemorandumViewController.init()
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    //MARK: 点击进入提醒界面
    @objc func goToRemind(){
        //进入你写的提醒Controller
        
        abort()
    }
}
