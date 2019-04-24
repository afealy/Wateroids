//
//  GameViewController.swift
//  Asteroid
//
//  Created by Anthony W Fealy on 4/17/19.
//  Copyright © 2019 Anthony W Fealy. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "MainMenuScene") {
                
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

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
