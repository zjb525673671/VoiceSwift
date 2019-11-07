//
//  HVHomeMainVC.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/22.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit

class HVHomeMainVC: BaseUIViewController {

    //MARK: ☸property
    
    //MARK: ♻️life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.xn_initData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: 🔒private
    func xn_initData() -> Void {
        /**{
            bizType = 2;
            deviceNo = 82BD48569A6E4B6CA3271B8B3714622C;
            loginCustomerId = 0;
            pageSize = 10;
         ["roomId":"1073","typeId":"1","liveType":"1009"]
         http://test02qygateway.qingyinlive.com/gateway/commt/cmtArticle/dynamicsHomePage
        }**/
        XNNetWorkManager.sharedInstance.requestTotalMethod(baseUrl: "gateway/commt/cmtArticle/dynamicsHomePage", method: .post, parameters: ["bizType":"2","deviceNo":"82BD48569A6E4B6CA3271B8B3714622C","loginCustomerId":"0","pageSize":"10"], successBack: { (json) in
            print("成功!")
        }) { (error) in
            print("失败了!")
        }
    }
    
    func xn_initSubViews() -> Void {
        
    }
    //MARK: 🚪public
    //MARK: 🍐delegate
    //MARK: ☎️notification
    //MARK: 🎬event response
}
