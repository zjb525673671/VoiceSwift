//
//  BaseUIViewController.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/22.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit

class BaseUIViewController: UIViewController {

    //MARK: ☸property
    
    //MARK: ♻️life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.base_initSubViews()
        self.base_initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        print("\(self.classForCoder)销毁了")
    }
    //MARK: 🔒private
    private func base_initData() {

        if (self.navigationController?.children.count)! > 1 {
            let leftBarBtn = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(base_goBack))
            leftBarBtn.image = UIImage(named: "public_navigition_goBack")
            self.navigationItem.leftBarButtonItem = leftBarBtn
        }
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18)]
    }
    
    private func base_initSubViews() {
        
    }
    
    @objc func base_goBack(){
        self.navigationController!.popViewController(animated: true)
    }
    //MARK: 🚪public
    //MARK: 🍐delegate
    //MARK: ☎️notification
    //MARK: 🎬event response

}
