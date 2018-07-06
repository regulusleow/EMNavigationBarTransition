//
//  SecondViewController.swift
//  EMNavigationBarTransition
//
//  Created by jiafeng wu on 2018/7/6.
//  Copyright © 2018年 em. All rights reserved.
//

import UIKit

class SecondViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

extension SecondViewController {
    
    private func setupUI() {
        navBarBgColor = .darkGray
        navBarTitleColor = .white
        navBarTintColor = .white
    }
}
