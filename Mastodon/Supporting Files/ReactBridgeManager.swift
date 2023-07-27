//
//  ReactBridgeManager.swift
//  Mastodon
//
//  Created by Tomasz Misiukiewicz on 27/07/2023.
//

import Foundation
import React

class ReactBridgeManager: NSObject {
    static let shared = ReactBridgeManager()
    
    var bridge: RCTBridge?
    
    public func loadReactNative(launchOptions: [AnyHashable: Any]?) {
        bridge = RCTBridge(delegate: self, launchOptions: launchOptions)
    }
}

extension ReactBridgeManager: RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        #if DEBUG
        return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
        #else
        return NSBundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif
    }
}
