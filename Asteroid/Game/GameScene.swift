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
    
    //let BackgroundColor: UIColor = UIColor(red: 51.0/255.0, green: 86.0/255.0, blue: 137.0/255.0, alpha: 1.0)
   // var background = SKSpriteNode()
    
    var user: User!
    
    var player: SKSpriteNode!
    var gameOver = false
    var sharkSwimmingFrames: [SKTexture] = []
    var subMovingFrames: [SKTexture] = []
    let subBossScore = 0 //Score at which subs can appear

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
    
  
    func createWater(){
        //self.backgroundColor = BackgroundColor
        let backgroundTexture = SKTexture(imageNamed: "water")
        let background1 = SKSpriteNode(texture: backgroundTexture)
        let background2 = SKSpriteNode(texture: backgroundTexture)
        
        background1.position = CGPoint(x: 0, y: 0)
        background1.size = self.size
        background1.zPosition = -40

        background2.position = CGPoint(x: background1.size.width, y: 0)
        background2.size = self.size
        background2.zPosition = -40
        background2.xScale = -1

        addChild(background1)
        addChild(background2)
        
        
        animatebg1(background: background1)
        animatebg2(background: background2)
    }
    
    func animatebg1(background: SKSpriteNode){
        let width = background.size.width
        
        let moveLeftInitial = SKAction.moveTo(x: -width, duration: 100)
        
        let reset = SKAction.moveTo(x: width, duration: 0)
        let moveLeft = SKAction.moveTo(x: -width, duration: 200)
        
        let moveLoop = SKAction.sequence([reset,moveLeft])
        let moveForever = SKAction.repeatForever(moveLoop)
        let seq = SKAction.sequence([moveLeftInitial,moveForever])
        
        background.run(seq)
    }
    
    func animatebg2(background: SKSpriteNode){
        let width = background.size.width

        let reset = SKAction.moveTo(x: width, duration: 0)
        let moveLeft = SKAction.moveTo(x: -width, duration: 200)
        
        let moveLoop = SKAction.sequence([moveLeft,reset])
        let moveForever = SKAction.repeatForever(moveLoop)
        
        background.run(moveForever)

    }
    
    override func didMove(to view: SKView) {
        
       createWater()
        
        // Set physics of environment
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame) //removed since it ibhibits wraparound,
        //updated to unique CGRect w/ padding
        let padding = CGFloat(67)
        let frameWithPadding: CGRect = CGRect(x: self.frame.minX - padding, y: self.frame.minY - padding, width: self.frame.width + (padding * 2), height: self.frame.height + (padding * 2))
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frameWithPadding)
        self.physicsBody?.categoryBitMask = wallCategory
       // self.physicsBody?.friction = 1
        
        // Sets up animation textures
        buildShark()
        buildLaser()
        buildSub()
        
        // loads whole game scene. Separated to easily reset game
        loadGame()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        infinityWrapUpdater(player)
        
    }
    
    func infinityWrapUpdater(_ obj: SKSpriteNode){
        let x = obj.position.x
        let y = obj.position.y
        let pad = CGFloat(30)
        if(x >= self.frame.maxX+pad){
            obj.position.x = self.frame.minX - pad
        }
        else if (x <= self.frame.minX-pad){
            obj.position.x = self.frame.maxX + pad
        }
        if(y >= self.frame.maxY+pad){
            obj.position.y = self.frame.minY - pad
        }
        else if (y <= self.frame.minY-pad){
            obj.position.y = self.frame.maxY + pad
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!gameOver){ //prevents shooting at time of death
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
        
        //Black shark fires better laser
        if (user.playerSkins[user.selectedPlayer].name == "blackLaserShark"){
            laserNode.xScale *= 1.5
            laserNode.yScale *= 3
            laserNode.physicsBody = SKPhysicsBody(texture: laserNode.texture!, size: CGSize(width: laserNode.size.width*1.5, height: laserNode.size.height*3))
        }
        else{
            laserNode.physicsBody = SKPhysicsBody(texture: laserNode.texture!, size: laserNode.size)

        }
        
        laserNode.physicsBody?.isDynamic = true
        laserNode.physicsBody?.categoryBitMask = laserCategory
        laserNode.physicsBody?.contactTestBitMask = enemyCategory
        laserNode.physicsBody?.collisionBitMask = 0
        laserNode.physicsBody?.usesPreciseCollisionDetection = true
        
        // Plays fired laser sound
      //  self.run(SKAction.playSoundFileNamed("laser.mp3", waitForCompletion: false))
        
        self.addChild(laserNode)
        
        let animationDuration: TimeInterval = 0.5
        
        var actionArray = [SKAction]()
   
        actionArray.append(SKAction.move(to: CGPoint(x: tapLocation.x, y: tapLocation.y), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        // ! Laser animation not working !
//        animateLaser(laser: laserNode)
        laserNode.run(SKAction.sequence(actionArray))
    }
    
    func fireTorpedoAtPlayer(enemy2: SKSpriteNode, impulseVector: CGVector){
        let torp = SKSpriteNode(imageNamed: "torpedo")
        torp.setScale(2.5)
        torp.position.x = enemy2.position.x + impulseVector.dx
        torp.position.y = enemy2.position.y + impulseVector.dy
        torp.zRotation = enemy2.zRotation
        
        torp.physicsBody = SKPhysicsBody(texture: torp.texture!, size: torp.size)
        
        torp.physicsBody?.isDynamic = true
        torp.physicsBody?.categoryBitMask = enemyCategory
        torp.physicsBody?.contactTestBitMask = laserCategory
        torp.physicsBody?.collisionBitMask = wallCategory
        torp.physicsBody?.usesPreciseCollisionDetection = true
        
        //self.run(SKAction.playSoundFileNamed("laser.mp3", waitForCompletion: false)) //TODO: replace w/ torpedo sounds
        
        self.addChild(torp)
        
        let animationDuration: TimeInterval = 1.75
        var actionArray = [SKAction]()
        actionArray.append(SKAction.fadeIn(withDuration: 0.35))
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y:  player.position.y), duration: animationDuration))
        actionArray.append(SKAction.run {
            self.explodeAt(laserNode: torp, position: torp.position)
        })
        torp.run(SKAction.sequence(actionArray))

    }
    
    /* Spawns new enemy - ! need to have them spawn off the screen !
     * Currently they spawn in the 4 corners of the screen
     * Want to adjust so they float in from anywhere but having problems with collisonBitMask (line 179)
     * The problem is they can't get on the screen if they don't spawn on it since they're blocked by the wall
     * Potential fix is to not set that bit mask until after they float in
     */
    @objc func addEnemy() {
        let bossRandomizer =  Bool.random() && Bool.random() //boss appears 1/4 of time after subBossScore threshold met
        enemyQueue.async {
            if(self.score >= self.subBossScore && bossRandomizer){
            
                let enemy2 = SKSpriteNode(texture: self.subMovingFrames[0])
            enemy2.setScale(3.5)
            
            self.enemySpawnPositions = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.enemySpawnPositions) as! [CGPoint]
                enemy2.position = self.enemySpawnPositions[0]
            
            enemy2.physicsBody = SKPhysicsBody(texture: enemy2.texture!, size: enemy2.size)
            enemy2.physicsBody?.isDynamic = true
            enemy2.physicsBody?.categoryBitMask = self.enemyCategory
            enemy2.physicsBody?.contactTestBitMask = self.laserCategory
                enemy2.physicsBody?.collisionBitMask = self.wallCategory
            
            self.addChild(enemy2)

                let impulseVector = self.calcVector(firstLocation: enemy2.position, secondLocation: CGPoint(x: self.player.position.x, y: self.player.position.y))
            enemy2.zRotation = impulseVector.theAngle

            enemy2.physicsBody?.applyImpulse(impulseVector.theVector)
            
                self.animateSub(enemy2: enemy2, impulseVector: impulseVector.theVector)
            } else {
                
                self.possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.possibleEnemies) as! [String]
                
                let enemy = SKSpriteNode(imageNamed: self.possibleEnemies[0])
                enemy.setScale(2)
            
                self.enemySpawnPositions = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.enemySpawnPositions) as! [CGPoint]
                    enemy.position = self.enemySpawnPositions[0]
            
                enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                enemy.physicsBody?.isDynamic = true
                enemy.physicsBody?.categoryBitMask = self.enemyCategory
                enemy.physicsBody?.contactTestBitMask = self.laserCategory
                    enemy.physicsBody?.collisionBitMask = self.wallCategory
                
                self.addChild(enemy)
            
                // Used to pick a random location for the enemies to float towards
                let randomEnemyPositionX = GKRandomDistribution(lowestValue: Int(self.frame.minX), highestValue: Int(self.frame.maxX))
                let randomEnemyPositionY = GKRandomDistribution(lowestValue: Int(self.frame.minY), highestValue: Int(self.frame.maxY))
                let positionX = CGFloat(randomEnemyPositionX.nextInt())
                let positionY = CGFloat(randomEnemyPositionY.nextInt())
                    let impulseVector = self.calcVector(firstLocation: enemy.position, secondLocation: CGPoint(x: positionX, y: positionY))
            
                enemy.physicsBody?.applyImpulse(impulseVector.theVector)
                
                
                    self.animateTrash(enemy: enemy)
                
            }

        }
        
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
    
    func explodeAt  (laserNode: SKSpriteNode, position: CGPoint){
            let explosion = SKSpriteNode(fileNamed: "Explosion")!
            explosion.setScale(CGFloat(0.5))
            explosion.position = position
            self.addChild(explosion)

            //self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            laserNode.removeFromParent()
        
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
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
            //self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            
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
           // self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            
            laserNode.removeFromParent()
            enemyNode.removeFromParent()
            gameOver = true
            
            // Game Over!
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size)
                gameOverScene.user = self.user
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
        player.setScale(2.2)
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.affectedByGravity = false
        //player.physicsBody?.friction = 1
        
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
        let sharkAnimatedAtlas = SKTextureAtlas(named: user.playerSkins[user.selectedPlayer].name+"Images")
        var swimFrames: [SKTexture] = []
        
        let numImages = sharkAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let sharkTextureName = user.playerSkins[user.selectedPlayer].name+"\(i)"
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
    func animateTrash(enemy: SKSpriteNode){
        var actionArray = [SKAction]()
        actionArray.append(SKAction.wait(forDuration: 10))
        actionArray.append(SKAction.fadeOut(withDuration: 0.25))
        actionArray.append(SKAction.run {
            enemy.removeFromParent()
            self.score -= 3 // remove for trash littered
        })
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
    
    // builds textures for sub animation
    func buildSub() {
        let subAnimatedAtlas = SKTextureAtlas(named: "subImages")
        var moveFrames: [SKTexture] = []
        
        let numImages = subAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let subTextureName = "sub\(i)"
            moveFrames.append(subAnimatedAtlas.textureNamed(subTextureName))
        }
        moveFrames.append(contentsOf: moveFrames.reversed())
        
        subMovingFrames = moveFrames
    }
    
    // starts sub animation
    func animateSub(enemy2: SKSpriteNode, impulseVector: CGVector) {
        enemy2.run(SKAction.repeatForever(
            SKAction.animate(with: subMovingFrames,
                             timePerFrame: 0.15,
                             resize: false,
                             restore: true)),
                   withKey:"movingInPlaceSub")
        
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.wait(forDuration: 1 ))
       
        actionArray.append(SKAction.run {
            self.fireTorpedoAtPlayer(enemy2: enemy2, impulseVector: impulseVector)
        })
        actionArray.append(SKAction.wait(forDuration: 200/Double(score) )) //wait decreases w/ score increase

        enemy2.run(SKAction.repeatForever(SKAction.sequence(actionArray)))
        
    
    }
    
}
