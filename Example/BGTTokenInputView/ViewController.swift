//
//  ViewController.swift
//  BGTTokenInputView
//
//  Created by beauzhang@live.ca on 07/19/2018.
//  Copyright (c) 2018 beauzhang@live.ca. All rights reserved.
//

import UIKit
import BGTTokenInputView

class ViewController: UIViewController {
    
    @IBOutlet weak var tokenInputView: TokenInputView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup tokenInputView
        tokenInputView.fieldName = "Name:"
        tokenInputView.placeholderText = "Enter a Name:"
        tokenInputView.delegate = self
    }
}

extension ViewController: TokenInputViewDelegate {
    //TokenInputView's Delegate methods
    func tokenInputViewTokenForText(_ view: TokenInputView, text searchToken: String) -> Token? {
        return Token(displayText: searchToken, baseObject: searchToken as AnyObject)
    }
}
