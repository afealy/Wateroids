//
//  GameOverScene.swift
//  Asteroid
//
//  Created by Anthony W Fealy on 4/21/19.
//  Copyright © 2019 Anthony W Fealy. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    let BackgroundColor: UIColor = UIColor(red: 51.0/255.0, green: 86.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    
    var user: User!
    
    var titleLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var coinLabel: SKLabelNode!
    var totalCoinsLabel: SKLabelNode!
    var newGameButton: SKSpriteNode!
    var highScoresButton: SKSpriteNode!
    
    var score:Int = 0
    var coins:Int = 0
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = BackgroundColor
        
        var myCoins = user.coins!
        user.saveScore(score)
        
        // Set up game title label
        titleLabel = SKLabelNode(text: "Game Over!")
        titleLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height-100)
        titleLabel.fontName = "AmericanTypewriter-Bold"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        
        self.addChild(titleLabel)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height-200)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        
        self.addChild(scoreLabel)
        
        coins = Int(score/10)
        myCoins += coins
        user.coins = myCoins
        user.userDefaultSaves()
        
        coinLabel = SKLabelNode(text: "Coins Earned: \(coins)")
        coinLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height-250)
        coinLabel.fontName = "AmericanTypewriter-Bold"
        coinLabel.fontSize = 24
        coinLabel.fontColor = .white
        
        self.addChild(coinLabel)
        
        totalCoinsLabel = SKLabelNode(text: "Total Coins: \(myCoins)")
        totalCoinsLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height-300)
        totalCoinsLabel.fontName = "AmericanTypewriter-Bold"
        totalCoinsLabel.fontSize = 24
        totalCoinsLabel.fontColor = .white
        
        self.addChild(totalCoinsLabel)
        
        newGameButton = SKSpriteNode(imageNamed: "newGameButton_unclicked")
        newGameButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        
        self.addChild(newGameButton)
        
        highScoresButton = SKSpriteNode(imageNamed: "highScoresButton_unclicked")
        //        highScoresButton.setScale(0.8)
        highScoresButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - 75)
        
        self.addChild(highScoresButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.reversed().first {
            let tapLocation = touch.location(in: self)
            let nodesArray = self.nodes(at: tapLocation)
            
            if let firstNode = nodesArray.first {
                if firstNode == newGameButton {
                    newGameButton.texture = SKTexture(imageNamed: "newGameButton_clicked")
                } else if firstNode == highScoresButton {
                    highScoresButton.texture = SKTexture(imageNamed: "highScoresButton_clicked")
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        
        if let touch = touches.reversed().first {
            let tapLocation = touch.location(in: self)
            let nodesArray = self.nodes(at: tapLocation)
            
            if let firstNode = nodesArray.first {
                if firstNode == newGameButton {
                    newGameButton.texture = SKTexture(imageNamed: "newGameButton_unclicked")
                    if let gameScene = GameScene(fileNamed: "GameScene") {
                        gameScene.user = user
                        self.run(SKAction.wait(forDuration: 0.3)) {
                            self.view?.presentScene(gameScene, transition: transition)
                        }
                    }
                } else if firstNode == highScoresButton {
                    highScoresButton.texture = SKTexture(imageNamed: "highScoresButton_unclicked")
                    let highScoresScene = HighScoresScene(size: self.size)
                    highScoresScene.user = user
                    self.run(SKAction.wait(forDuration: 0.3)) {
                        self.view?.presentScene(highScoresScene, transition: transition)
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        
        if let touch = touches.reversed().first {
            let tapLocation = touch.location(in: self)
            let nodesArray = self.nodes(at: tapLocation)
            
            if let firstNode = nodesArray.first {
                if firstNode == newGameButton {
                    newGameButton.texture = SKTexture(imageNamed: "newGameButton_unclicked")
                    if let gameScene = GameScene(fileNamed: "GameScene") {
                        gameScene.user = user
                        self.run(SKAction.wait(forDuration: 0.3)) {
                            self.view?.presentScene(gameScene, transition: transition)
                        }
                    }
                } else if firstNode == highScoresButton {
                    highScoresButton.texture = SKTexture(imageNamed: "highScoresButton_unclicked")
                    let highScoresScene = HighScoresScene(size: self.size)
                    highScoresScene.user = user
                    self.run(SKAction.wait(forDuration: 0.3)) {
                        self.view?.presentScene(highScoresScene, transition: transition)
                    }
                }
            }
        }
    }

}
