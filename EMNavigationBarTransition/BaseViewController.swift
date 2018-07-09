//
//  BaseViewController.swift
//  EMNavigationBarTransition
//
//  Created by jiafeng wu on 2018/7/6.
//  Copyright © 2018年 em. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let color = navBarTitleColor
        navBarTitleColor = color
    }
}
