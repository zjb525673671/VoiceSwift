//
//  BaseUINavigationController.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/22.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit

class BaseUINavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }

}
