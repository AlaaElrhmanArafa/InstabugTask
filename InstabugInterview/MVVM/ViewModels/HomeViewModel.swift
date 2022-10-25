//
//  HomeViewModel.swift
//  InstabugInterview
//
//  Created by AlaaElrhman on 23/10/2022.
//

import Foundation
import InstabugNetworkClient

class HomeViewModel{
    
    private var urls = ["https://httpbin.org/anything",
                        "https://httpbin.org/bytes/650",
                        "https://httpbin.org/bytes/1578876543",
                        "https://httpbin.org/image"]
    
    var showAlertClosure: ((_ msg:String)->())?
    var showActivityIndiactor: ((_ loading:Bool) -> ())?
    
    func sendRequest(){
        let urlString = urls[Int.random(in: 0...3)]
        guard let url = URL(string: urlString) else { return }
        showActivityIndiactor?(true)
        DispatchQueue.global().async {
            NetworkClient.shared.get(url) { [weak self] data in
                self?.showActivityIndiactor?(false)
                self?.showAlertClosure?("Request sent")
            }
        }
    }
}
