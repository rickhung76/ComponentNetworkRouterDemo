//
//  ViewController.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnPressed(_ sender: UIButton) {
        APIManager.shared.getVersion { (result) in
            switch result {
            case .success(let version):
                print(version)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

