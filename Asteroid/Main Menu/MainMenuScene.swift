//
//  MainMenuScene.swift
//  Asteroid
//
//  Created by Anthony W Fealy on 4/20/19.
//  Copyright © 2019 Anthony W Fealy. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    let BackgroundColor: UIColor = UIColor(red: 51.0/255.0, green: 86.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    
    var user: User!
    
    var titleLabel: SKLabelNode!
    var usernameLabel: SKLabelNode!
    var coinsLabel: SKLabelNode!
    var newGameButton: SKSpriteNode!
    var highScoresButton: SKSpriteNode!
    
    var selectedPlayer = 0
    var playerPicker: [SKSpriteNode]!
    var selectionBorder: SKSpriteNode!
    var buyButton: SKSpriteNode!
    var priceLabel: SKLabelNode!
    
//    var docRef: DocumentReference!
//    var username: String?
//    var coins: Int?
    
    override func didMove(to view: SKView) {
        
        print(user.playerSkins)
        self.backgroundColor = BackgroundColor
        
        // Set up game title label
        titleLabel = SKLabelNode(text: "Wateroids")
        titleLabel.position = CGPoint(x: 0, y: 160)
        titleLabel.fontName = "AmericanTypewriter-Bold"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white

        self.addChild(titleLabel)
        
        usernameLabel = SKLabelNode(text: "Hello, " + user.username)
        usernameLabel.position = CGPoint(x: 0, y: 200)
        usernameLabel.fontName = "AmericanTypewriter-Bold"
        usernameLabel.fontSize = 28
        usernameLabel.fontColor = .white
        
        self.addChild(usernameLabel)
        
        coinsLabel = SKLabelNode(text: "Coins: " + String(user.coins))
        coinsLabel.position = CGPoint(x: 0, y: 80)
        coinsLabel.fontName = "AmericanTypewriter-Bold"
        coinsLabel.fontSize = 28
        coinsLabel.fontColor = .white
        
        self.addChild(coinsLabel)
        
        newGameButton = SKSpriteNode(imageNamed: "newGameButton_unclicked")
        newGameButton.position = CGPoint(x: 0, y: 0)
        
        self.addChild(newGameButton)
        
        highScoresButton = SKSpriteNode(imageNamed: "highScoresButton_unclicked")
//        highScoresButton.setScale(0.8)
        highScoresButton.position = CGPoint(x: 0, y: 0-(newGameButton.frame.height+20))
        
        self.addChild(highScoresButton)
        
        playerPicker = [SKSpriteNode(imageNamed: "laserShark1"), SKSpriteNode(imageNamed: "blackLaserShark1"), SKSpriteNode(imageNamed: "goldLaserShark1")]
        playerPicker[0].position = CGPoint(x: 0-(playerPicker[0].frame.width+40), y: 0-(highScoresButton.frame.height+120))
        playerPicker[0].name = "laserShark"
        playerPicker[1].position = CGPoint(x: 0, y: 0-(highScoresButton.frame.height+120))
        playerPicker[1].name = "blackLaserShark"
        playerPicker[2].position = CGPoint(x: playerPicker[0].frame.width+40, y: 0-(highScoresButton.frame.height+120))
        playerPicker[2].name = "goldLaserShark"
        
        for player in playerPicker {
            player.setScale(2.0)
            self.addChild(player)
        }
        
        user.selectedPlayer = selectedPlayer
        selectionBorder = SKSpriteNode(imageNamed: "selectionBorder")
        selectionBorder.position = playerPicker[0].position
        selectionBorder.setScale(2.0)
        
        self.addChild(selectionBorder)
        
    }
    
//    func databaseCalls() {
//        if let docID = UserDefaults.standard.string(forKey: "documentid") {
//            docRef = Firestore.firestore().document("Users/"+docID)
//            docRef.getDocument { (document, error) in
//                if let document = document, let docData = document.data() {
//                    self.username = docData["username"] as? String ?? "Anonymous"
//                    self.coins = docData["coins"] as? Int ?? 0
//                    print(self.username)
//                } else {
//                    print("Document does not exist")
//                }
//            }
//            print("got to Database calls")
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.reversed().first {
            let tapLocation = touch.location(in: self)
            let nodesArray = self.nodes(at: tapLocation)
            
            if let firstNode = nodesArray.first {
                if firstNode == newGameButton {
                    newGameButton.texture = SKTexture(imageNamed: "newGameButton_clicked")
                } else if firstNode == highScoresButton {
                    highScoresButton.texture = SKTexture(imageNamed: "highScoresButton_clicked")
                } else if firstNode == playerPicker[0] {
                    if let _ = self.childNode(withName: "buyButton") {
                        buyButton.removeFromParent()
                        priceLabel.removeFromParent()
                    }
                    changedSelected(index: 0)
                } else if firstNode == playerPicker[1] {
                    if let _ = self.childNode(withName: "buyButton") {
                        buyButton.removeFromParent()
                        priceLabel.removeFromParent()
                    }
                    changedSelected(index: 1)
                }else if firstNode == playerPicker[2] {
                    if let _ = self.childNode(withName: "buyButton") {
                        buyButton.removeFromParent()
                        priceLabel.removeFromParent()
                    }
                    changedSelected(index: 2)
                } else if firstNode == buyButton {
                    buyButton.texture = SKTexture(imageNamed: "buyButton_clicked")
                }
            }
        }
    }
    
    func changedSelected(index: Int) {
        if index != selectedPlayer {
            selectedPlayer = index
            selectionBorder.position = playerPicker[index].position
            if !user.playerSkins[selectedPlayer].purchased {
                buyButton = SKSpriteNode(imageNamed: "buyButton_unclicked")
                buyButton.name = "buyButton"
                buyButton.position = CGPoint(x: 0, y: playerPicker[selectedPlayer].position.y-(buyButton.frame.height + 50))
                self.addChild(buyButton)
                
                priceLabel = SKLabelNode(text: "Cost: " + user.playerSkins[selectedPlayer].cost.description)
                priceLabel.position = CGPoint(x: playerPicker[selectedPlayer].position.x, y: playerPicker[selectedPlayer].position.y+50)
                priceLabel.fontName = "AmericanTypewriter-Bold"
                priceLabel.fontSize = 20
                priceLabel.fontColor = .white
                self.addChild(priceLabel)
            } else {
//                if let _ = self.childNode(withName: "buyButton") {
//                    buyButton.removeFromParent()
//                    priceLabel.removeFromParent()
//                }
                user.selectedPlayer = selectedPlayer
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
                } else if firstNode == buyButton {
                    buyButton.texture = SKTexture(imageNamed: "buyButton_unclicked")
                    if user.unlockPlayer(name: playerPicker[selectedPlayer].name!) {
                        buyButton.removeFromParent()
                        priceLabel.removeFromParent()
                        user.selectedPlayer = selectedPlayer
                        coinsLabel.text = "Coins: " + user.coins.description
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
                } else if firstNode == buyButton {
                    highScoresButton.texture = SKTexture(imageNamed: "buyButton_unclicked")
                    if user.unlockPlayer(name: playerPicker[selectedPlayer].name!) {
                        buyButton.removeFromParent()
                        priceLabel.removeFromParent()
                        user.selectedPlayer = selectedPlayer
                        coinsLabel.text = "Coins: " + user.coins.description
                    }
                }
            }
        }
    }
}
