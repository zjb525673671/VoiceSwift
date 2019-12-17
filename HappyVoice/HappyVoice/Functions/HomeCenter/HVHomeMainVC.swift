//
//  HVHomeMainVC.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/22.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit
import Alamofire

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
        
        let mdstr = XNHelper.md5(strs: "1")?.lowercased()
        print("加密结果:"+mdstr!);
    }
    
    
    func xn_initSubViews() -> Void {
        let parameters:Dictionary = ["key":"93c921ea8b0348af8e8e7a6a273c41bd"]
        let manager = Alamofire.SessionManager.default
        manager.request("http://apis.haoservice.com/weather/city", method: .get, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).response { (result) in
            
        }
//        let parameters:Dictionary = ["key":"93c921ea8b0348af8e8e7a6a273c41bd"]
//        Alamofire.SessionManager.default.request(.GET, method: "http://apis.haoservice.com/weather/city", parameters: parameters)
//            .responseJSON { response in
//
//                print("result==\(response.result)")   // 返回结果，是否成功
//                if let jsonValue = response.result.value {
//                    /*
//                    error_code = 0
//                    reason = ""
//                    result = 数组套字典的城市列表
//                    */
//                    print("code: \(jsonValue["error_code"])")
//                }
//        }
    }
    //MARK: 🚪public
    //MARK: 🍐delegate
    //MARK: ☎️notification
    //MARK: 🎬event response
}
