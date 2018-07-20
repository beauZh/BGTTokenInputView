//
//  TokenView.swift
//  Closeout
//
//  Created by Bo Zhang on 2018-06-26.
//
//

import UIKit

//
protocol TokenViewDelegate: class {
  func tokenViewDidRequestDelete(_ tokenView: TokenView, replaceWithText theText: String?)
  func tokenViewDidRequestSelection(_ tokenView: TokenView)
  func tokenViewShouldDisplayMenu(_ tokenView: TokenView) -> Bool
  func tokenViewMenuItems(_ tokenView: TokenView) -> [UIMenuItem]
}

class TokenView: UIView {
  
  var token: Token!
  var displayText: String
  var autocorrectionType: UITextAutocorrectionType = .no
  var displayMode: TokenInputViewMode = .view
  
  weak var delegate: TokenViewDelegate?
  fileprivate(set) var selected = false
  
  fileprivate static let PADDING_X: CGFloat = 4.0
  fileprivate static let PADDING_Y: CGFloat = 2.0
  fileprivate var label: TokenLabel!
  fileprivate var selectedBackgroundView: UIView!
  fileprivate var selectedLabel: UILabel!
  
  fileprivate var textColor: UIColor!
  fileprivate var selectedTextColor: UIColor!
  fileprivate var selectedBackgroundColor: UIColor!
  fileprivate var separatorColor: UIColor!
  
  var font: UIFont! {
    didSet {
      self.label.font = self.font
      self.selectedLabel.font = self.font
    }
  }
  
  init(token theToken: Token, displayMode: TokenInputViewMode = .edit) {
    self.displayText = theToken.displayText
    
    super.init(frame: CGRect.zero)
    
    self.displayMode = displayMode
    self.separatorColor = UIColor.lightGray
    self.selectedTextColor = UIColor.white
    
    self.token = theToken
    var tintColor = UIColor(red: 0.0823, green: 0.4941, blue: 0.9843, alpha: 1.0)
    if let tint = self.tintColor {
      tintColor = tint
    }
    self.label = TokenLabel(frame: CGRect(x: TokenView.PADDING_X, y: TokenView.PADDING_Y, width: 0, height: 0))
    self.label.textColor = tintColor
    self.label.backgroundColor = UIColor.clear
    self.addSubview(label)
    
    self.selectedBackgroundView = UIView(frame: CGRect.zero)
    self.selectedBackgroundView.backgroundColor = tintColor
    self.selectedBackgroundView.layer.cornerRadius = 3.0
    self.selectedBackgroundView.isHidden = true
    self.addSubview(self.selectedBackgroundView)
    
    self.selectedLabel = UILabel(frame: CGRect(x: TokenView.PADDING_X, y: TokenView.PADDING_Y, width: 0, height: 0))
    self.selectedLabel.textColor = UIColor.white
    self.selectedLabel.backgroundColor = UIColor.clear
    self.selectedLabel.isHidden = true
    self.addSubview(self.selectedLabel)
    
   
    
    // Configure for the token, unselected shows "[displayText]," and selected is "[displayText]"
    let labelString = "\(self.displayText),"
    
    let attrString = NSMutableAttributedString(string: labelString, attributes: [
        NSFontAttributeName : self.label.font,
        NSForegroundColorAttributeName : UIColor.lightGray
        ])
    
    
    let tintRange = (labelString as NSString).range(of: self.displayText)
    
    // Make the name part the system tint color
    attrString.setAttributes([NSForegroundColorAttributeName : tintColor], range: tintRange)
    
    self.label.attributedText = attrString
    self.selectedLabel.text = self.displayText
    
    // Listen for taps
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TokenView.handleTapGestureRecognizer(_:)))
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(TokenView.handleLongPressGestureRecognizer(_:)))
    longPressGesture.minimumPressDuration = 0.5
    self.addGestureRecognizer(tapGesture)
    self.addGestureRecognizer(longPressGesture)
    self.setNeedsLayout()
    
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var intrinsicContentSize : CGSize {
    let size = self.selectedLabel.intrinsicContentSize
    return CGSize(width: size.width+(2.0*TokenView.PADDING_X), height: size.height+(2.0*TokenView.PADDING_Y))
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let fittingSize = CGSize(width: size.width-(2.0*TokenView.PADDING_X), height: size.height-(2.0*TokenView.PADDING_Y))
    let labelSize = self.selectedLabel.sizeThatFits(fittingSize)
    return CGSize(width: labelSize.width+(2.0*TokenView.PADDING_X), height: labelSize.height+(2.0*TokenView.PADDING_Y))
  }
  
  func setSelected(selected selectedValue: Bool, animated: Bool) {
    if (self.selected == selectedValue) {
      return
    }
    
    selected = selectedValue;
    
    if (selected && self.displayMode == .edit) {
      self.becomeFirstResponder()
    }
    
    let selectedAlpha: CGFloat = self.selected ? 1.0 : 0.0
    if (animated) {
      if (self.selected) {
        self.selectedBackgroundView.alpha = 0.0
        self.selectedBackgroundView.isHidden = false
        self.selectedLabel.alpha = 0.0
        self.selectedLabel.isHidden = false
      }
      UIView.animate(withDuration: 0.25, animations: {
        self.selectedBackgroundView.alpha = selectedAlpha
        self.selectedLabel.alpha = selectedAlpha
        }, completion: { (_) in
          if !self.selected {
            self.selectedBackgroundView.isHidden = true
            self.selectedLabel.isHidden = true
          }
      })
      
    } else {
      self.selectedBackgroundView.isHidden = !self.selected;
      self.selectedLabel.isHidden = !self.selected;
    }
  }
  
  func setSeparatorVisibility(_ visible: Bool) {
    self.displayText = self.token.displayText
    let labelString = "\(self.displayText),"
    
    let attrString = NSMutableAttributedString(string: labelString, attributes: [
        NSFontAttributeName : self.label.font,
        NSForegroundColorAttributeName : visible ? UIColor.lightGray : UIColor.clear
        ])
    
    let tintRange = (labelString as NSString).range(of: self.displayText)
    
    // Make the name part the system tint color
    attrString.setAttributes([NSForegroundColorAttributeName : self.textColor], range: tintRange)
    self.label.attributedText = attrString
  }
  
  
  func setColors(_ textColor: UIColor, selectedTextColor: UIColor, selectedBackgroundColor: UIColor) {
    self.textColor = textColor
    self.selectedTextColor = selectedTextColor
    self.selectedBackgroundColor = selectedBackgroundColor
    self.updateColors()
  }
  
  func updateColors() {
    
    self.label.textColor = self.textColor
    self.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor
    self.selectedLabel.textColor = self.selectedTextColor
    
    let attrString: AnyObject = self.label.attributedText!.mutableCopy() as AnyObject
    let tintRange = NSMakeRange(0, self.displayText.count)
    // Make the overall text color gray
    attrString.setAttributes([NSForegroundColorAttributeName: self.separatorColor], range:NSMakeRange(attrString.length - 1, 1))
    // Make the name part the system tint color
    attrString.setAttributes([NSForegroundColorAttributeName : self.textColor], range:tintRange)
    if let attrString = attrString as? NSAttributedString {
      self.label.attributedText = attrString
    }
  }
  
  @objc func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
    self.delegate?.tokenViewDidRequestSelection(self)
  }
  
  @objc func handleLongPressGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
    
    guard let delegate = self.delegate else { return }
    if recognizer.state != .began {
      return
    }
    
    if !delegate.tokenViewShouldDisplayMenu(self) {
      return
    }
    
    let items = delegate.tokenViewMenuItems(self)
    if items.isEmpty {
      return
    }
    self.label.becomeFirstResponder()
    delegate.tokenViewDidRequestSelection(self)
    let menu = UIMenuController.shared
    menu.menuItems = items
    menu.setTargetRect(self.bounds, in: self)
    menu.setMenuVisible(true, animated: true)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let bounds = self.bounds
    
    //self.backgroundView.frame = bounds
    self.selectedBackgroundView.frame = bounds
    
    var labelFrame = bounds.insetBy(dx: TokenView.PADDING_X, dy: TokenView.PADDING_Y)
    self.selectedLabel.frame = labelFrame;
    labelFrame.size.width += TokenView.PADDING_X*2.0;
    self.label.frame = labelFrame;
    
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return false
  }
  
  override var canBecomeFirstResponder : Bool {
    return true
  }
  
}

extension TokenView: UIKeyInput {
  var hasText : Bool {
    return true
  }
  
  func insertText(_ text: String) {
    self.delegate?.tokenViewDidRequestDelete(self, replaceWithText: text)
  }
  
  func deleteBackward() {
    self.delegate?.tokenViewDidRequestDelete(self, replaceWithText: nil)
  }
  
  
}
