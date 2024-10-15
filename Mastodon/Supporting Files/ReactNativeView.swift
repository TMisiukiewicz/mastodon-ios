import UIKit
import React_RCTAppDelegate

class ReactNativeView: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let factory = (RCTSharedApplication()?.delegate as? RCTAppDelegate)?.rootViewFactory
    self.view = factory?.view(withModuleName: "ReactNativeScreen")
  }
}
