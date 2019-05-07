//
//  CreateUser.swift
//  Asteroid
//
//  Created by Anthony W Fealy on 4/27/19.
//  Copyright © 2019 Anthony W Fealy. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class CreateUser: SKScene, UITextFieldDelegate {
    
    let BackgroundColor: UIColor = UIColor(red: 51.0/255.0, green: 86.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    
    var userTextField: UITextField!
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = BackgroundColor
        
        userTextField = UITextField(frame: CGRect(x: self.frame.size.width/2-150, y: self.frame.size.height/2-20, width: 300, height: 40))
        userTextField.placeholder = "Enter Username"
        userTextField.font = UIFont.systemFont(ofSize: 15)
        userTextField.borderStyle = UITextField.BorderStyle.roundedRect
        userTextField.autocorrectionType = UITextAutocorrectionType.no
        userTextField.keyboardType = UIKeyboardType.default
        userTextField.returnKeyType = UIReturnKeyType.done
        userTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        userTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        userTextField.delegate = self
        
        self.view?.addSubview(userTextField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
        print("TextField should end editing method called")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text?.description ?? "Nothing")
        if let username = textField.text?.description {
            
            // Creates user
            let user = User(username: username)
            user.userDefaultSaves()
            
            textField.removeFromSuperview()
            if let view = self.view {
                // Load the SKScene from 'GameScene.sks'
                if let scene = MainMenuScene(fileNamed: "MainMenuScene") {
                    
                    // passes user to main menu scene
                    scene.user = user
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                    
                    /* Sprite Kit applies additional optimizations to improve rendering performance */
                    view.ignoresSiblingOrder = true
                    
                    // Remove all children before scene loads
                    scene.removeAllChildren()
                    
                    /* Set the scale mode to scale to fit the window */
                    scene.size = view.bounds.size
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene)
                }
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        print("TextField should return method called")
        textField.resignFirstResponder()
        return true
    }
}

//            self.docRef = Firestore.firestore().collection("Users").addDocument(data: [
//                "username": username,
//                "coins": 0,
//                "scores": []
//            ]) { err in
//                if let err = err {
//                    print("Error adding document: \(err)")
//                } else {
//                    print("Document added with ID: \(self.docRef.documentID)")
//                    var docID: String? = self.docRef.documentID
//                    print(docID!)
//                    while (docID ?? "").isEmpty { docID = self.docRef.documentID }
//                    UserDefaults.standard.set(docID!, forKey: "documentid")
//                    print(UserDefaults.standard.string(forKey: "documentid") ?? "not saved")
//                    textField.removeFromSuperview()
//                    if let view = self.view {
//                        // Load the SKScene from 'GameScene.sks'
//                        if let scene = GameScene(fileNamed: "MainMenuScene") {
//
//                            view.showsFPS = true
//                            view.showsNodeCount = true
//
//                            /* Sprite Kit applies additional optimizations to improve rendering performance */
//                            view.ignoresSiblingOrder = true
//
//                            // Remove all children before scene loads
//                            scene.removeAllChildren()
//
//                            /* Set the scale mode to scale to fit the window */
//                            scene.size = view.bounds.size
//                            scene.scaleMode = .aspectFill
//
//                            // Present the scene
//                            view.presentScene(scene)
//                        }
//                        view.ignoresSiblingOrder = true
//
//                        view.showsFPS = true
//                        view.showsNodeCount = true
//                    }
//                }
//            }
