//
//  ReactNativeScreen.swift
//  Mastodon
//
//  Created by Tomasz Misiukiewicz on 27/07/2023.
//

import Foundation
import React

class ReactNativeViewController: UIViewController {
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialize ReactNativeScreen with init")
    }

    override func viewDidLoad() {
        if let bridge = ReactBridgeManager.shared.bridge {
            self.view = RCTRootView(
                bridge: bridge,
                moduleName: "ReactNativeScreen",
                initialProperties: nil
            )
        }
    }
}
