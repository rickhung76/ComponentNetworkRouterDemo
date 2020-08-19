//
//  ViewController.swift
//  FriedTofuManager
//
//  Created by 黃柏叡 on 2019/11/15.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnPressed(_ sender: Any) {
        APIManager.shared.requestGithubSearchUser(text: "onevcat", page: 0) { (result) in
            switch result {
            case .success(let usersModel):
                print(usersModel?.items)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

