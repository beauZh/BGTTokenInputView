//
//  Token.swift
//  Closeout
//
//  Created by Bo Zhang on 2018-06-26.
//
//

import Foundation


@objc open class Token: NSObject {
    
    open var displayText: String!
    open var baseObject: AnyObject?
    
    public init(displayText theText: String, baseObject theObject: AnyObject?) {
        self.displayText = theText
        self.baseObject = theObject
    }
}

public func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.displayText == rhs.displayText
}
