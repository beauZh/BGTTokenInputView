//
//  TokenInputView.swift
//  Closeout
//
//  Created by Bo Zhang on 2018-06-26.
//
//

import UIKit

@objc public protocol TokenInputViewDelegate: class {
  
  /**
   *  Called when the text field begins editing
   */
  @objc optional func tokenInputViewDidEnditing(_ view: TokenInputView)
  
  /**
   *  Called when the text field ends editing
   */
  @objc optional func tokenInputViewDidBeginEditing(_ view: TokenInputView)
  
  /**
   * Called when the text field text has changed. You should update your autocompleting UI based on the text supplied.
   */
  @objc optional func tokenInputViewDidChangeText(_ view: TokenInputView, text theNewText: String)
  
  /**
   * Called when a token has been added. You should use this opportunity to update your local list of selected items.
   */
  @objc optional func tokenInputViewDidAddToken(_ view: TokenInputView, token theNewToken: Token)
  
  /**
   * Called when a token has been removed. You should use this opportunity to update your local list of selected items.
   */
  @objc optional func tokenInputViewDidRemoveToken(_ view: TokenInputView, token removedToken: Token)
  
  /**
   * Called when the user attempts to press the Return key with text partially typed.
   * @return A CLToken for a match (typically the first item in the matching results),
   * or nil if the text shouldn't be accepted.
   */
  @objc optional func tokenInputViewTokenForText(_ view: TokenInputView, text searchToken: String) -> Token?
  
  /**
   * Called when the view has updated its own height. If you are
   * not using Autolayout, you should use this method to update the
   * frames to make sure the token view still fits.
   */
  @objc optional func tokenInputViewDidChangeHeight(_ view: TokenInputView,  height newHeight:CGFloat)
  
  /**
   * Called when the view has received a double tap gesture. If you want to display a menu above
   * the `TokenView` return true.
   * In order to display the items, you should also implement `tokenInputViewMenuItems`
   *
   * @return true if you want to display a UIMenuController element
   */
  @objc optional func tokenInputViewShouldDisplayMenuItems(_ view: TokenInputView) -> Bool
  
  /**
   * Called if the `tokenInputViewShouldDisplayMenuItems` returned true.
   * Return the UIMenuItem you want to display above or below the `Token`
   *
   * @return the array of `UIMenuItem`
   */
  @objc optional func tokenInputViewMenuItems(_ view: TokenInputView, token: Token) -> [UIMenuItem]
}

//两种枚举的模式, 一种是view 一种是 edit
public enum TokenInputViewMode {
  case view
  case edit
}

open class TokenInputView: UIView {
  
  @IBOutlet weak open var delegate: TokenInputViewDelegate?
    
    //这是左右的两个按钮, 要分析下如何定制化这两个按钮
//  var _fieldView: UIView?
//  var _accessoryView: UIView?
    
  
  @IBInspectable var _fieldName: String?
    
  @IBInspectable var _placeholderText: String?
  @IBInspectable var _keyboardType: UIKeyboardType = .default
  @IBInspectable var _autocapitalizationType: UITextAutocapitalizationType = .none
  @IBInspectable var _autocorrectionType: UITextAutocorrectionType = .no
  @IBInspectable var _drawBottomBorder: Bool = false
  
  open var allTokens: [Token] {
    return self.tokens.map { $0 }
  }
  
  open var shouldForceRepositionning = false
  
  var text: String {
    return self.textField.text!
  }
  
  var editing: Bool {
    return self.textField.isEditing
  }
  
  var tokenizeOnEndEditing = true
  
  open var font: UIFont! {
    didSet {
      self.textField?.font = self.font
      for view in tokenViews {
        view.font = self.font
      }
    }
  }
  
  open var fieldNameFont: UIFont! {
    didSet {
      self.fieldLabel?.font = self.fieldNameFont
    }
  }
  
  open var fieldNameColor: UIColor! {
    didSet {
      self.fieldLabel?.textColor = self.fieldNameColor
    }
  }
    
    
    //所有的tokens
  fileprivate var tokens: [Token] = []
  fileprivate var tokenViews: [TokenView] = []
//  fileprivate var textField: BackspaceDetectingTextField!
    var textField: BackspaceDetectingTextField!
  fileprivate var fieldLabel: UILabel!
  fileprivate var intrinsicContentHeight: CGFloat!
//  fileprivate var displayMode: TokenInputViewMode!
    var displayMode: TokenInputViewMode!
  fileprivate var heightZeroConstraint: NSLayoutConstraint!
  
  fileprivate var textColor: UIColor!
  fileprivate var selectedTextColor: UIColor!
  fileprivate var selectedBackgroundColor: UIColor!
  fileprivate var separatorColor: UIColor!
  
  open var HSPACE: CGFloat = 0.0
  open var TEXT_FIELD_HSPACE: CGFloat = 4.0
  
  /// The space betwen each rows
  open var VERTICAL_SPACE_BETWEEN_ROWS: CGFloat = 4.0
  
  /// The minimum space the textfield should be. If the space cannot be allocated, then a new line will be created
  open var MINIMUM_TEXTFIELD_WIDTH: CGFloat = 10.0
  
  open var PADDING_TOP: CGFloat = 10.0
  open var PADDING_BOTTOM: CGFloat = 10.0
  open var PADDING_LEFT: CGFloat = 8.0
  open var PADDING_RIGHT: CGFloat = 16.0
  open var STANDARD_ROW_HEIGHT: CGFloat = 25.0
  open var FIELD_MARGIN_X: CGFloat = 4.0
  
  /// Minimum height size for the view if empty
  open var MINIMUM_VIEW_HEIGHT: CGFloat = 45.0
  
  public convenience init() {
    self.init(mode: .edit)
  }
  
  public init(mode: TokenInputViewMode) {
    super.init(frame: CGRect.zero)
    self.commonInit(mode)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  func commonInit(_ mode: TokenInputViewMode = .edit) {
    
    self.font = UIFont.systemFont(ofSize: 17.0)
    self.textField = BackspaceDetectingTextField(frame: self.bounds)
    self.textField.backgroundColor = UIColor.clear
    self.textField.keyboardType = self.keyboardType;
    self.textField.autocorrectionType = self.autocorrectionType;
    self.textField.autocapitalizationType = self.autocapitalizationType;
    self.textField.delegate = self
    self.textField.addTarget(self, action: #selector(TokenInputView.onTextFieldDidChange(_:)), for: .editingChanged)
    self.textField.addTarget(self, action: #selector(TokenInputView.onTextFieldDidEndEditing(_:)), for: .editingDidEnd)
    self.addSubview(self.textField)
    
    self.fieldLabel = UILabel(frame: CGRect.zero)
    self.fieldLabel.textColor = UIColor.lightGray
    self.addSubview(self.fieldLabel)
    self.fieldLabel.isHidden = true
    
    self.backgroundColor = UIColor.clear
    self.intrinsicContentHeight = self.STANDARD_ROW_HEIGHT
    
    self.clipsToBounds = true
    self.displayMode = mode
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TokenInputView.viewWasTapped)))
    self.heightZeroConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
    
    self.repositionViews()
    self.setDefaultColors()
  }
  
  override open var intrinsicContentSize : CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: max(self.MINIMUM_VIEW_HEIGHT, self.intrinsicContentHeight))
  }
  
  open func setColors(_ textColor: UIColor, selectedTextColor: UIColor, selectedBackgroundColor: UIColor) {
    
    self.textColor = textColor
    self.selectedTextColor = selectedTextColor
    self.selectedBackgroundColor = selectedBackgroundColor
    
    self.tokenViews.forEach { (tokenView) in
      tokenView.setColors(textColor, selectedTextColor: selectedTextColor, selectedBackgroundColor: selectedBackgroundColor)
    }
  }
  
  open func addToken(token theToken: Token) {
    if self.tokens.contains(theToken) {
      return
    }
    
    self.tokens.append(theToken)
    let tokenView = TokenView(token: theToken, displayMode: self.displayMode)
    tokenView.font = self.font
    tokenView.delegate = self;
    tokenView.setColors(self.textColor, selectedTextColor: self.selectedTextColor, selectedBackgroundColor: self.selectedBackgroundColor)
    let intrinsicSize = tokenView.intrinsicContentSize
    tokenView.frame = CGRect(x: 0, y: 0, width: intrinsicSize.width, height: intrinsicSize.height)
    self.tokenViews.append(tokenView)
    self.addSubview(tokenView)
    self.textField.text = ""
    self.delegate?.tokenInputViewDidAddToken?(self, token: theToken)
    
    // Clearing text programmatically doesn't call this automatically
    self.onTextFieldDidChange(self.textField)
    
    self.updatePlaceholderTextVisibility()
    self.repositionViews()
  }
  
  open func setHeightToZero() {
    self.addConstraint(self.heightZeroConstraint)
  }
  
  open func setHeightToAuto() {
    self.removeConstraint(self.heightZeroConstraint)
  }
  
  /**
   * This method removes all tokens of the `TokenInputView`.
   *
   * For each token removed, the delegate method `tokenInputViewDidRemoveToken` will be called if implemented.
   */
  open func removeAllTokens() {
    let tokens = self.tokens
    let tokenViews = self.tokenViews
    self.tokens = []
    self.tokenViews = []

    tokens.forEach {
      self.delegate?.tokenInputViewDidRemoveToken?(self, token: $0)
    }

    tokenViews.forEach {
      $0.removeFromSuperview()
    }
    
    self.repositionViews()
  }
  
  open func removeToken(token theToken: Token) {
    if let index = self.tokens.index(where: { (token) -> Bool in return token == theToken }) {
      self.removeTokenAtIndex(index)
    }
  }
  
  open func forceTokenizeCurrentText() {
    let _ = self.tokenizeTextFieldText()
  }
  
    //删除在index的Token
  fileprivate func removeTokenAtIndex(_ index: Int) {
    let tokenView = self.tokenViews[index]
    tokenView.removeFromSuperview()
    self.tokenViews.remove(at: index)
    
    let removedToken = self.tokens[index]
    self.tokens.remove(at: index)
    self.delegate?.tokenInputViewDidRemoveToken?(self, token: removedToken)
    
    self.updatePlaceholderTextVisibility()
    self.repositionViews()
  }
  
  /**
   * Returns the editable textfield view.
   */
  open func getTextFieldView() -> UITextField {
    return self.textField
  }
  
    fileprivate func tokenizeTextFieldText() -> Token? {
    
    let text = self.textField.text;

    if !text!.isEmpty {
      if let token = self.delegate?.tokenInputViewTokenForText?(self, text: text!) {
        self.addToken(token: token)
        self.onTextFieldDidChange(self.textField)
        return token
      }
    }
    
    return nil
  }
  
  fileprivate func setDefaultColors() {
    if let tint = self.tintColor {
      self.textColor = tint
      self.selectedBackgroundColor = tint
      self.selectedTextColor = UIColor.white
      return
    }
    
    self.textColor = UIColor.black
    self.selectedTextColor = UIColor.white
    self.selectedBackgroundColor = UIColor.black
  }
  
  fileprivate func textFieldDisplayOffset() -> CGFloat {
    // Essentially the textfield's y with PADDING_TOP
    return self.textField.frame.minY - self.PADDING_TOP
  }
  
    
    //repositionViews方法
    fileprivate func repositionViews() {
    let bounds = self.bounds
    
    if bounds.height == 0 && !shouldForceRepositionning {
      self.repositionViewZeroHeight()
      return
    }
    
    self.shouldForceRepositionning = false
    
    let rightBoundary = bounds.width - self.PADDING_RIGHT
//    var firstLineRightBoundary = rightBoundary
//    let firstLineRightBoundary = rightBoundary
    
    var curX = self.PADDING_LEFT
    var curY = self.PADDING_TOP
    var yPositionForLastToken: CGFloat = 0.0
    
    // Position field label (if field name is set)
    if !self.fieldLabel.isHidden {
      self.fieldLabel.sizeToFit()
      var fieldLabelRect = self.fieldLabel.frame
      fieldLabelRect.origin.x = curX + self.FIELD_MARGIN_X
      fieldLabelRect.origin.y = curY + ((self.STANDARD_ROW_HEIGHT-fieldLabelRect.height)/2.0)
      self.fieldLabel.frame = fieldLabelRect
      
      curX = fieldLabelRect.maxX + self.FIELD_MARGIN_X
    }
    
    // Position token views
    var tokenRect = CGRect.null
    var tokensByLine: [Int: Int] = [0:0]
    var currentLine = 0
    
    for view in self.tokenViews {
      view.sizeToFit()
      tokenRect = view.frame
      
      let tokenBoundary = rightBoundary
      let hasOtherToken = (tokensByLine[currentLine] ?? 0) != 0
      if (curX + tokenRect.width > tokenBoundary && hasOtherToken) {
        // Need a new line
        currentLine += 1
        tokensByLine[currentLine] = 0
        curX = self.PADDING_LEFT
        curY += self.STANDARD_ROW_HEIGHT+self.VERTICAL_SPACE_BETWEEN_ROWS
      }
      
      tokensByLine[currentLine] = tokensByLine[currentLine]! + 1
      
      tokenRect.origin.x = curX
      // Center our tokenView vertially within STANDARD_ROW_HEIGHT
      tokenRect.origin.y = curY + ((self.STANDARD_ROW_HEIGHT-tokenRect.height)/2.0)
      if tokenRect.width > self.getMaxLineWidth() {
        tokenRect.size.width = self.getMaxLineWidth()
      }
      view.frame = tokenRect
      
      curX = tokenRect.maxX + self.HSPACE
      yPositionForLastToken = tokenRect.origin.y
      view.setSeparatorVisibility(view != self.tokenViews.last || self.editing)
    }
    
    
    
    // Always indent textfield by a little bit
    curX += self.TEXT_FIELD_HSPACE
    let textBoundary = rightBoundary
    var availableWidthForTextField = textBoundary - curX
    if (availableWidthForTextField < self.MINIMUM_TEXTFIELD_WIDTH) {
      curX = self.PADDING_LEFT + self.TEXT_FIELD_HSPACE
      curY += self.STANDARD_ROW_HEIGHT+self.VERTICAL_SPACE_BETWEEN_ROWS
      // Adjust the width
      availableWidthForTextField = rightBoundary - curX
    }
    
    if (!self.editing && curY > yPositionForLastToken && !self.tokens.isEmpty) {
      // check if there is another token on the line and if not we should remove the line height
      curY -= self.STANDARD_ROW_HEIGHT+self.VERTICAL_SPACE_BETWEEN_ROWS
    }
    
    if self.editing {
      self.textField.frame = CGRect(x: curX, y: curY, width: availableWidthForTextField, height: self.STANDARD_ROW_HEIGHT)
    } else {
      self.textField.frame = CGRect.zero
    }
    
    if self.displayMode == .view {
      self.textField.frame = CGRect.zero
    }
    
    let oldContentHeight = self.intrinsicContentHeight
    self.intrinsicContentHeight = self.getIntrinsincContentHeightAfterReposition()
    self.invalidateIntrinsicContentSize()
    
    if (oldContentHeight != self.intrinsicContentHeight) {
      self.delegate?.tokenInputViewDidChangeHeight?(self, height: self.intrinsicContentSize.height)
    }
    self.setNeedsDisplay()
    
  }
    
    
  
  fileprivate func getMaxLineWidth() -> CGFloat {
    return self.frame.width - self.PADDING_RIGHT - self.PADDING_LEFT
  }
  
  fileprivate func getIntrinsincContentHeightAfterReposition() -> CGFloat {
    if self.editing {
      return self.textField.frame.maxY+self.PADDING_BOTTOM
    }
    
    guard let view = self.tokenViews.last else {
      return 0
    }
    
    return view.frame.maxY+self.PADDING_BOTTOM
  }
  
  fileprivate func repositionViewZeroHeight() {
    let flFrame = fieldLabel.frame
    fieldLabel.frame = CGRect(x: flFrame.origin.x, y: flFrame.origin.y, width: flFrame.width, height: 0)
    
    let tfFrame = textField.frame
    textField.frame = CGRect(x: tfFrame.origin.x, y: tfFrame.origin.y, width: tfFrame.width, height: 0)
    
    for view in self.tokenViews {
      let frame = view.frame
      view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 0)
    }
  }
  
  override open func layoutSubviews() {
    self.repositionViews()
    super.layoutSubviews()
  }
  
  fileprivate func updatePlaceholderTextVisibility() {
    if self.tokens.isEmpty {
      self.textField.placeholder = self.placeholderText
    } else {
      self.textField.placeholder = nil
    }
  }
  
  @objc func onTextFieldDidChange(_ textfield: UITextField) {
    self.delegate?.tokenInputViewDidChangeText?(self, text: textfield.text!)
  }
  
  @objc func onTextFieldDidEndEditing(_ textfield: UITextField) {
    self.repositionViews()
  }
  
  @objc func viewWasTapped() {
    self.unselectAllTokenViewsAnimated(true)
    if self.displayMode == .view {
      return
    }
    self.beginEditing()
  }
}

// MARK: - Token Selection
extension TokenInputView {
  func selectTokenView(tokenView theView: TokenView, animated: Bool) {
    theView.setSelected(selected: true, animated: animated)
    for view in self.tokenViews {
      if view != theView {
        view.setSelected(selected: false, animated: animated)
      }
    }
  }
  
  func unselectAllTokenViewsAnimated(_ animated: Bool) {
    for view in self.tokenViews {
      view.setSelected(selected: false, animated: animated)
    }
  }
}

// MARK: - Editing
extension TokenInputView {
  
  public func beginEditing() {
    
    if self.displayMode == .view {
      return
    }
    self.textField.becomeFirstResponder()
    self.unselectAllTokenViewsAnimated(false)
    self.repositionViews()
  }
  
  public func endEditing() {
    self.resignFirstResponder()
    self.repositionViews()
  }
}

// MARK: - UItextField delegate method
extension TokenInputView: UITextFieldDelegate  {
  
  public func textFieldDidBeginEditing(_ textField: UITextField) {
//    self.accessoryView?.isHidden = false
    self.delegate?.tokenInputViewDidBeginEditing?(self)
    self.unselectAllTokenViewsAnimated(true)
  }
  
  public func textFieldDidEndEditing(_ textField: UITextField) {
//    self.accessoryView?.isHidden = true
    self.delegate?.tokenInputViewDidEnditing?(self)
    if (self.tokenizeOnEndEditing) {
//      let _ = self.tokenizeTextFieldText()
    }
  }
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    let _ = self.tokenizeTextFieldText()
    return false
  }
  
}

// MARK: - TextField customazation
extension TokenInputView {
  var keyboardType: UIKeyboardType {
    get { return self._keyboardType }
    set {
      self._keyboardType = newValue
      self.textField.keyboardType = _keyboardType
    }
  }
  
  var autocapitalizationType: UITextAutocapitalizationType {
    get { return self._autocapitalizationType }
    set {
      self._autocapitalizationType = newValue
      self.textField.autocapitalizationType = _autocapitalizationType
    }
  }
  
  var autocorrectionType: UITextAutocorrectionType {
    get { return self._autocorrectionType }
    set {
      self._autocorrectionType = newValue
      self.textField.autocorrectionType = _autocorrectionType
    }
  }
}

// MARK: - Optional views
extension TokenInputView {
  //设置 FieldName
  public var fieldName: String? {
    get { return _fieldName }
    set {
      if _fieldName == newValue {
        return
      }
      let previous = _fieldName

      let showField = !(newValue?.isEmpty ?? true)
      self._fieldName = newValue
      self.fieldLabel.text = _fieldName
      self.fieldLabel.sizeToFit()
      self.fieldLabel.isHidden = !showField

      if showField && !(self.fieldLabel.superview != nil) {
        self.addSubview(self.fieldLabel)
      } else if !showField && (self.fieldLabel.superview != nil) {
        self.fieldLabel.removeFromSuperview()
      }

      if previous == nil || !(previous == _fieldName) {
        self.repositionViews()
      }
    }
  }
  //设置placeholderText
  public var placeholderText: String? {
    get { return _placeholderText }
    set {
      if _placeholderText == newValue {
        return
      }
      _placeholderText = newValue
      self.updatePlaceholderTextVisibility()
    }
  }
  
}

// Mark: Drawing
extension TokenInputView {
  public var drawBottomBorder: Bool {
    get { return _drawBottomBorder }
    set {
      if _drawBottomBorder == newValue {
        return
      }
      _drawBottomBorder = newValue
      self.setNeedsDisplay()
    }
  }
  
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    if self.drawBottomBorder {
      
      let context = UIGraphicsGetCurrentContext()
      let bounds = self.bounds
      context?.setStrokeColor(UIColor.lightGray.cgColor)
      context?.setLineWidth(0.5)
      
      context?.move(to: CGPoint(x: 0, y: bounds.size.height))
      context?.addLine(to: CGPoint(x: bounds.width, y: bounds.size.height))
      context?.strokePath()
    }
  }
}

//在这里实现TokenView中的四种代理方法的具体过程
// MARK: - TokenViewDelegate
extension TokenInputView: TokenViewDelegate {
    
  func tokenViewDidRequestDelete(_ tokenView: TokenView, replaceWithText theText: String?) {
    if self.displayMode == .view {
      return
    }
    // First, refocus the text field
    self.textField.becomeFirstResponder()
    if !(theText?.isEmpty ?? true) {
      self.textField.text = theText
    }
    // Then remove the view from our data
    if let index = self.tokenViews.index(of: tokenView) {
      self.removeTokenAtIndex(index)
    }
  }
  func tokenViewDidRequestSelection(_ tokenView: TokenView) {
    self.selectTokenView(tokenView: tokenView, animated: true)
  }
  
  func tokenViewShouldDisplayMenu(_ tokenView: TokenView) -> Bool {
    guard let should = self.delegate?.tokenInputViewShouldDisplayMenuItems?(self) else { return false }
    return should
  }
  
  func tokenViewMenuItems(_ tokenView: TokenView) -> [UIMenuItem] {
    guard let items = self.delegate?.tokenInputViewMenuItems?(self, token: tokenView.token) else { return [] }
    return items
  }
}

// MARK: BackspceDetectingTextfield delegate
extension TokenInputView: BackspaceDetectingTextFieldDelegate {
    
    func textFieldWillDeleteBackward(_ textField: UITextField) {
        DispatchQueue.main.async {
            if textField.text?.count == 0 {
                let tokenView: TokenView? = self.tokenViews.last
                if tokenView != nil {
                    self.selectTokenView(tokenView: tokenView!, animated: true)
                    self.textField.resignFirstResponder()
                }
            }
        }
    }
}
