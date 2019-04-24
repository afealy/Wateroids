//
//  GameScene.swift
//  Asteroid
//
//  Created by Anthony W Fealy on 4/17/19.
//  Copyright © 2019 Anthony W Fealy. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BackgroundColor: UIColor = UIColor(red: 51.0/255.0, green: 86.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    
    var player: SKSpriteNode!
    
    var sharkSwimmingFrames: [SKTexture] = []
    var laserFiringFrames: [SKTexture] = []
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer: Timer!
    
    var possibleEnemies = ["trashBag"]
    var enemySpawnPositions: [CGPoint] = []
    
    let wallCategory: UInt32 = 0x1 << 2
    let enemyCategory: UInt32 = 0x1 << 1
    let laserCategory: UInt32 = 0x1 << 0
    
    // Might wanna change enemy spawning to its own thread
    var enemyQueue = DispatchQueue(label: "enemy-queue")
    
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = BackgroundColor
        
        // Set physics of environment
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = wallCategory
        
        // Sets up animation textures
        buildShark()
        buildLaser()
        
        // loads whole game scene. Separated to easily reset game
        loadGame()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.reversed().first {
            
            // get tap and ship locations in the scene
            let tapLocation = touch.location(in: self)
            let playerLocation = player.position
            
//            print("tap: \(tapLocation)")
//            print("player: \(playerLocation)")

            let posVariables = calcVector(firstLocation: playerLocation, secondLocation: tapLocation)
            player.zRotation = posVariables.theAngle
            
            player.physicsBody?.applyImpulse(posVariables.theVector)
            fireLaser(tapLocation: tapLocation)
        }
    }
    
    // Calculates vector and angle between 2 positions
    func calcVector(firstLocation: CGPoint, secondLocation: CGPoint) -> (theAngle: CGFloat, theVector: CGVector) {
        
        // neccessary variable to orient and move ship based on tap
        let pi = CGFloat.pi
        let xDiff = firstLocation.x-secondLocation.x
        let yDiff = firstLocation.y-secondLocation.y
        let theta: CGFloat = atan((yDiff)/(xDiff))
        var calculatedAngle: CGFloat = 0.0;
        
        // Calculate orientation in radians
        if(yDiff > 0) {
            if(xDiff < 0) {
                calculatedAngle = ((-pi/2)-theta);
            }
            else if(xDiff > 0) {
                calculatedAngle = ((pi/2)-theta)
            }
        }
        else if(yDiff < 0) {
            if(xDiff < 0) {
                calculatedAngle = ((3*pi/2)-theta)
            }
            else if(xDiff > 0) {
                calculatedAngle = ((pi/2)-theta)
            }
        }
        
        // Had to negate and add pi. This fixed orientation
        calculatedAngle = -1 * calculatedAngle + pi
        
        // Find vector from firstLocation to secondLocation
        let xVec: CGFloat = sin(calculatedAngle) * -10
        let yVec: CGFloat = cos(calculatedAngle) * 10
        let theVector: CGVector = CGVector(dx: xVec, dy: yVec)
        
        return (calculatedAngle, theVector)
    }
    
    // Handles the laser being fired from the player ship
    func fireLaser(tapLocation: CGPoint) {
        let laserNode = SKSpriteNode(imageNamed: "laser1")
        laserNode.setScale(2)
        laserNode.position = player.position
        laserNode.zRotation = player.zRotation
        
        // ! find way to make laser fire from front of ship !
        
        laserNode.physicsBody = SKPhysicsBody(texture: laserNode.texture!, size: laserNode.size)
        laserNode.physicsBody?.isDynamic = true
        laserNode.physicsBody?.categoryBitMask = laserCategory
        laserNode.physicsBody?.contactTestBitMask = enemyCategory
        laserNode.physicsBody?.collisionBitMask = 0
        laserNode.physicsBody?.usesPreciseCollisionDetection = true
        
        // Plays fired laser sound
//        self.run(SKAction.playSoundFileNamed("laser.mp3", waitForCompletion: false))
        
        self.addChild(laserNode)
        
        let animationDuration: TimeInterval = 0.5
        
        var actionArray = [SKAction]()
   
        actionArray.append(SKAction.move(to: CGPoint(x: tapLocation.x, y: tapLocation.y), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        // ! Laser animation not working !
//        animateLaser(laser: laserNode)
        laserNode.run(SKAction.sequence(actionArray))
    }
    
    /* Spawns new enemy - ! need to have them spawn off the screen !
     * Currently they spawn in the 4 corners of the screen
     * Want to adjust so they float in from anywhere but having problems with collisonBitMask (line 179)
     * The problem is they can't get on the screen if they don't spawn on it since they're blocked by the wall
     * Potential fix is to not set that bit mask until after they float in
     */
    @objc func addEnemy() {
//        enemyQueue.async {
            self.possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.possibleEnemies) as! [String]
            
            let enemy = SKSpriteNode(imageNamed: self.possibleEnemies[0])
            enemy.setScale(2)
        
            self.enemySpawnPositions = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.enemySpawnPositions) as! [CGPoint]
            enemy.position = enemySpawnPositions[0]
        
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.physicsBody?.isDynamic = true
            enemy.physicsBody?.categoryBitMask = self.enemyCategory
            enemy.physicsBody?.contactTestBitMask = self.laserCategory
            enemy.physicsBody?.collisionBitMask = wallCategory
            
            self.addChild(enemy)
        
            // Used to pick a random location for the enemies to float towards
            let randomEnemyPositionX = GKRandomDistribution(lowestValue: Int(self.frame.minX), highestValue: Int(self.frame.maxX))
            let randomEnemyPositionY = GKRandomDistribution(lowestValue: Int(self.frame.minY), highestValue: Int(self.frame.maxY))
            let positionX = CGFloat(randomEnemyPositionX.nextInt())
            let positionY = CGFloat(randomEnemyPositionY.nextInt())
            let impulseVector = calcVector(firstLocation: enemy.position, secondLocation: CGPoint(x: positionX, y: positionY))
        
            enemy.physicsBody?.applyImpulse(impulseVector.theVector)
//        }
    }
    
    // Runs when contact is detected
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & laserCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0 {
//            print(firstBody.description)
//            print(secondBody.description)
            if let enemyNode = secondBody.node, let laserNode = firstBody.node {
                laserDidHitEnemy(laserNode: laserNode as! SKSpriteNode, enemyNode: enemyNode as! SKSpriteNode)
            }
        }
    }
    
    // Handles enemy and player explosions
    func laserDidHitEnemy (laserNode: SKSpriteNode, enemyNode: SKSpriteNode) {
        
        let explosion = SKSpriteNode(fileNamed: "Explosion")!
        
        // laser shoots enemy
        if laserNode != player {
            explosion.position = enemyNode.position
            self.addChild(explosion)
            
            // Explosion sound
//            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            
            laserNode.removeFromParent()
            enemyNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            
            score += 5
        } else { // enemy collides with ship
            explosion.position = laserNode.position
            self.addChild(explosion)
            
            // Explosion sound
//            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            
            laserNode.removeFromParent()
            enemyNode.removeFromParent()
            
            // Game Over!
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size)
                gameOverScene.score = self.score
                self.view?.presentScene(gameOverScene, transition: transition)
            }
        }
    }
    
    func resetGame() {
        gameTimer = nil
        for childNode in self.children {
            childNode.removeFromParent()
        }
        loadGame()
    }
    
    // Holds everything that needed to run again if the game was reset without changing scenes
    func loadGame() {
        
        let borderBuffer:CGFloat = 30.0
        enemySpawnPositions = [CGPoint(x: self.frame.minX + borderBuffer, y: self.frame.minY + borderBuffer),
                               CGPoint(x: self.frame.minX + borderBuffer, y: self.frame.maxY - borderBuffer),
                               CGPoint(x: self.frame.maxX - borderBuffer, y: self.frame.minY + borderBuffer),
                               CGPoint(x: self.frame.maxX - borderBuffer, y: self.frame.maxY - borderBuffer)]
        
        // Set up player
        player = SKSpriteNode(texture: sharkSwimmingFrames[0])
        player.setScale(2)
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.collisionBitMask = wallCategory
        player.physicsBody?.categoryBitMask = laserCategory
        self.addChild(player)
        
        animateShark()
        
        // Set up score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: self.frame.minX + 75, y: self.frame.maxY - 75)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        score = 0
        self.addChild(scoreLabel)
        
        // Timer to spawn in enemies
        gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        
    }
    
    // builds textures for shark animation
    func buildShark() {
        let sharkAnimatedAtlas = SKTextureAtlas(named: "laserSharkImages")
        var swimFrames: [SKTexture] = []
        
        let numImages = sharkAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let sharkTextureName = "laserShark\(i)"
            swimFrames.append(sharkAnimatedAtlas.textureNamed(sharkTextureName))
        }
        sharkSwimmingFrames = swimFrames
    }
    
    // starts shark animation
    func animateShark() {
        player.run(SKAction.repeatForever(
            SKAction.animate(with: sharkSwimmingFrames,
                             timePerFrame: 0.15,
                             resize: false,
                             restore: true)),
                 withKey:"swimmingInPlaceShark")
    }
    
    // builds textures for laser animation
    func buildLaser() {
        let laserAnimatedAtlas = SKTextureAtlas(named: "laserImages")
        var fireFrames: [SKTexture] = []
        
        let numImages = laserAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let laserTextureName = "laser\(i)"
            fireFrames.append(laserAnimatedAtlas.textureNamed(laserTextureName))
        }
        laserFiringFrames = fireFrames
    }
    
    // starts laser animation
    func animateLaser(laser: SKSpriteNode) {
        laser.run(SKAction.repeatForever(
            SKAction.animate(with: laserFiringFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
                 withKey:"firingLaser")
    }
    
}
