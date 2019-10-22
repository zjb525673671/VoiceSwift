//
//  HVLoginMainVC.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/21.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit
import SnapKit

class HVLoginMainVC: BaseUIViewController {

    var count = NSInteger.init()
    var itemLabel = UILabel.init();
    
    let tableView = UITableView.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.count = 2;
        self.itemLabel.text = "";
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    private func xn_initSubViews() {
        let itemLabel = UILabel.init();
        let loginButton = UIButton.init(type: .custom);
        self.view.addSubview(itemLabel);
        self.view.addSubview(loginButton);
        itemLabel.textAlignment = .left;
        itemLabel.font = UIFont.systemFont(ofSize: 18);
        self.tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view);
        }
    }

}
