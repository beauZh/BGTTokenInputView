//
//  BackspaceDetectingTextField.swift
//  Closeout
//
//  Created by Bo Zhang on 2018-06-26.
//
//

import UIKit

protocol BackspaceDetectingTextFieldDelegate: UITextFieldDelegate {
    func textFieldWillDeleteBackward(_ textField: UITextField)
}

class BackspaceDetectingTextField: UITextField {
    
    weak var extendedDelegate: BackspaceDetectingTextFieldDelegate? {
        get { return self.delegate as? BackspaceDetectingTextFieldDelegate }
        set { self.delegate = newValue}
    }
    
    override func deleteBackward() {
        if self.text?.isEmpty ?? false {
             self.extendedDelegate?.textFieldWillDeleteBackward(self)
        }
        super.deleteBackward()
    }
}
