//
//  TokenLabel.swift
//  Closeout
//
//  Created by Bo Zhang on 2018-06-26.
//
//

import UIKit

class TokenLabel: UILabel {
  
  override var canBecomeFirstResponder : Bool {
    return true
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return false
  }
}
