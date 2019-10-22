//
//  BaseUITabBarController.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/22.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit

class BaseUITabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewController(orginVC: HVHomeMainVC(), imageName: "tabBar_loan_normal", selectImage: "", title: "贷款", tag: 1)
        self.addChildViewController(orginVC: HVMyCenterVC(), imageName: "tabBar_quota_normal", selectImage: "", title: "提额", tag: 2)
    }
    
    private func addChildViewController(orginVC:UIViewController?, imageName: String?, selectImage: String?, title: String?, tag:NSInteger) {
        orginVC?.title = title;
        orginVC?.tabBarItem.image = UIImage.init(named: imageName!)?.withRenderingMode(.alwaysOriginal)
        orginVC?.tabBarItem.tag = tag
        orginVC?.tabBarItem.selectedImage = UIImage.init(named: selectImage!)?.withRenderingMode(.alwaysOriginal)
        orginVC?.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.red], for: .selected)
        orginVC?.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.blue], for: .normal)
        let nav = BaseUINavigationController.init(rootViewController: orginVC!)
        self.addChild(nav)
    }
    

}
