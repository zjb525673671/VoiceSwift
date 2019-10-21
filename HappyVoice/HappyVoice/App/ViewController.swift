//
//  ViewController.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/21.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let myButton = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 200, height: 100))
        myButton.backgroundColor = UIColor.red;
        self.view.addSubview(myButton)
    }

}

