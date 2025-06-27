//
//  AFWrapper.swift
//  ScreenMirroring
//
//  Created by DREAMWORLD on 19/09/24.
//

import Foundation
import UIKit
//import Alamofire


//class AFWrapper: NSObject{
//    
//    class func PostMethod (url:String,params: [String : Any], completion: @escaping (Any) -> Void, failure:@escaping (Error) -> Void){
//        
//        guard let urlstr = URL(string: url) else{ return }
//
//        let manager = Alamofire.Session.default
//        manager.session.configuration.timeoutIntervalForRequest = 50000
//        manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
//        manager.session.configuration.urlCache = nil
//                
//        manager.request(urlstr, method: .post, parameters: params).responseJSON { response in
//            switch (response.result) {
//            case .success (let JSON):
//                let jsonResponse = JSON
//                completion(jsonResponse)
//            case .failure(let error):
//                failure(error)
//                break
//            }
//        }
//    }
//}
