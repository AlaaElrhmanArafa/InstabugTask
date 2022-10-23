//
//  ViewController.swift
//  InstabugInterview
//
//  Created by Yousef Hamza on 1/13/21.
//

import UIKit
import InstabugNetworkClient

class HomeViewController: UIViewController {

    //MARK: - 
    var viewModel = HomeViewModel()
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
    }
    
    
    func initViewModel(){
        viewModel.showAlertClosure = { [weak self] (msg) in
            DispatchQueue.main.async {
                self?.alert(message: msg)
            }
        }
    }
    
    @IBAction func sendReuestsButtonPressed(_ sender: Any) {
        self.viewModel.sendRequest()
    }
    
    @IBAction func deleteAllRequests(_ sender: Any) {
        LoggerHandler.shared.clearLogs()
    }
    
    @IBAction func showCountPressed(_ sender: Any) {
        let count = LoggerHandler.shared.count
        self.alert(message: "\(count)")
    }
}
