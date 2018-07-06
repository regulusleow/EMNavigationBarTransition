//
//  FirstViewController.swift
//  EMNavigationBarTransition
//
//  Created by jiafeng wu on 2018/7/6.
//  Copyright © 2018年 em. All rights reserved.
//

import UIKit

class FirstViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

extension FirstViewController {
    
    private func setupUI() {
        navBarBgColor = .cyan
        navBarTitleColor = .darkGray
    }
}
