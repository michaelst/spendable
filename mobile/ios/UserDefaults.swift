//
//  UserDefaults.swift
//  Spendable
//
//  Created by Michael St Clair on 12/29/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import WidgetKit

@objc(RNUserDefaults)
class RNUserDefaults: NSObject {
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc func setSpendable(_ value: NSString) {
    UserDefaults(suiteName: "group.fiftysevenmedia")!.set(value, forKey: "spendable")
    WidgetCenter.shared.reloadTimelines(ofKind: "fiftysevenmedia.Spendable.SpendableWidget")
  }
}
