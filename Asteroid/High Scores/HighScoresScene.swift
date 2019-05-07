//
//  HighScoreScene.swift
//  Asteroid
//
//  Created by Anthony W Fealy on 4/21/19.
//  Copyright © 2019 Anthony W Fealy. All rights reserved.
//

import SpriteKit

//struct Score: Codable {
//
//    let score: Int
//    let date: String
//
//    init(score: Int, date: String) {
//        self.score = score
//        self.date = date
//    }
//
//}
//
//struct highScoreCache {
//    static let key = "scores"
//    static let numOfScores = 5
//
//    static func save(_ value: Int) {
//        let now = Date()
//        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone.current
//        formatter.dateFormat = "yyyy-MM-dd HH:mm"
//        let dateString = formatter.string(from: now)
//        let newScore = Score(score: value, date: dateString)
//
//        if var cachedScores = get() {
//            cachedScores.sort { $0.score > $1.score }
//
//            if cachedScores.count >= numOfScores && cachedScores.last!.score < newScore.score {
//                _ = cachedScores.popLast()
//                cachedScores.append(newScore)
//                cachedScores.sort { $0.score > $1.score }
//            } else if cachedScores.count < numOfScores {
//                cachedScores.append(newScore)
//                cachedScores.sort { $0.score > $1.score }
//            }
//            UserDefaults.standard.set(try? PropertyListEncoder().encode(cachedScores), forKey: key)
//        } else {
//            UserDefaults.standard.set(try? PropertyListEncoder().encode([newScore]), forKey: key)
//        }
//    }
//
//    static func get() -> [Score]! {
//        var scoreData: [Score]?
//        if let data = UserDefaults.standard.value(forKey: key) as? Data {
//            scoreData = try! PropertyListDecoder().decode([Score].self, from: data)
//            return scoreData
//        } else {
//            return scoreData
//        }
//    }
//
//    static func remove() {
//        UserDefaults.standard.removeObject(forKey: key)
//    }
//}

class HighScoresScene: SKScene {

    let BackgroundColor: UIColor = UIColor(red: 51.0/255.0, green: 86.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    
    var user: User!
    
    var highScoreLabel: SKLabelNode!
    
    var highScoreLabels: [SKLabelNode] = []
    var scores: [Score] = []
    
    var mainMenuButton: SKSpriteNode!
    var mainMenuLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = BackgroundColor
        
        highScoreLabel = SKLabelNode(text: "High Scores")
        highScoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height-100)
        highScoreLabel.fontName = "AmericanTypewriter-Bold"
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = .white
        
        self.addChild(highScoreLabel)
        
//        highScoreCache.remove()
        
//        if let scoreList = highScoreCache.get() {
//            scores = scoreList
//        } else {
//            scores = []
//        }
        
        scores = user.scores
        
        // Generate labels for the top scores
        for i in 0 ..< scores.count {
            let scoreLabel = SKLabelNode(text: "\(i+1).     \(scores[i].score)        \(scores[i].date)")
            let offset: CGFloat = CGFloat((i-1)*50)
            let yPos: CGFloat = self.frame.size.height*0.75
            scoreLabel.position = CGPoint(x: self.frame.size.width/2, y: yPos - offset)
            scoreLabel.fontName = "AmericanTypewriter-Bold"
            scoreLabel.fontSize = 20
            scoreLabel.fontColor = .white
    
            self.addChild(scoreLabel)
        }
        
        mainMenuButton = SKSpriteNode(imageNamed: "mainMenuButton_unclicked")
        mainMenuButton.position = CGPoint(x: self.frame.size.width/2, y: 100)
        self.addChild(mainMenuButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.reversed().first {
            let tapLocation = touch.location(in: self)
            let nodesArray = self.nodes(at: tapLocation)
            
            if let firstNode = nodesArray.first {
                if firstNode == mainMenuButton {
                    mainMenuButton.texture = SKTexture(imageNamed: "mainMenuButton_clicked")
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        
        if let touch = touches.reversed().first {
            let tapLocation = touch.location(in: self)
            let nodesArray = self.nodes(at: tapLocation)
            
            if let firstNode = nodesArray.first {
                if firstNode == mainMenuButton {
                    mainMenuButton.texture = SKTexture(imageNamed: "mainMenuButton_unclicked")
                    if let mainMenuScene = MainMenuScene(fileNamed: "MainMenuScene") {
                        mainMenuScene.user = user
                        self.run(SKAction.wait(forDuration: 0.3)) {
                            self.view?.presentScene(mainMenuScene, transition: transition)
                        }
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
                if firstNode == mainMenuButton {
                    mainMenuButton.texture = SKTexture(imageNamed: "mainMenuButton_unclicked")
                    if let mainMenuScene = MainMenuScene(fileNamed: "MainMenuScene") {
                        mainMenuScene.user = user
                        self.run(SKAction.wait(forDuration: 0.3)) {
                            self.view?.presentScene(mainMenuScene, transition: transition)
                        }
                    }
                }
            }
        }
    }
}
