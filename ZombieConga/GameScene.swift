//
//  GameScene.swift
//  ZombieConga
//
//  Created by Allan Im on 2019-05-28.
//  Copyright © 2019 Allan Im. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieAnimation: SKAction
    
    var invincible = false
    let catMovePointsPerSec:CGFloat = 480.0
    var lives = 5
    var gameOver = false
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2
            + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2
            + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    // Playable
    let playableRect: CGRect
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        // 4
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        super.init(size: size) // 5
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
//        let background = SKSpriteNode(imageNamed: "background1")
//        background.position = CGPoint(x: size.width/2, y: size.height/2)
//        background.anchorPoint = CGPoint.zero
//        background.position = CGPoint.zero
        
        // PI = 180 , zRotation = 22.5
//        background.zRotation = CGFloat.pi / 8
//        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
//        background.position = CGPoint(x: size.width/2, y: size.height/2)
//
//        background.zPosition = -1
//
//        let mySize = background.size
//        print("Size: \(mySize)")
//
//        addChild(background)
        
        // background
        let background = backgroundNode()
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.zero
        background.name = "background"
        background.zPosition = -1
        addChild(background)
        
        
        zombie.position = CGPoint(x: 400, y: 400)
//        zombie.setScale(2) // SKNode method
        zombie.zPosition = 100
        addChild(zombie)
        
//        zombie.run(SKAction.repeatForever(zombieAnimation))
        
        
        debugDrawPlayableArea()
        
        spawnEnemy()
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                },SKAction.wait(forDuration: 2.0)])))
        
        // cat
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnCat()
                },SKAction.wait(forDuration: 1.0)])))
        

        // sounds
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        // camera
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        // background
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        
        // label
        livesLabel.text = "Lives: X"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
//        livesLabel.position = CGPoint(x: size.width/2, y: size.height/2)
//        addChild(livesLabel)
//        livesLabel.position = CGPoint.zero
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(livesLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
//        print("\(dt*1000) milliseconds since last update")
        
//        move(sprite: zombie, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
//        move(sprite: zombie, velocity: velocity)
        
        
//        rotate(sprite: zombie, direction: velocity)
//        zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
        
//        if let lastTouchLocation = lastTouchLocation {
//            let diff = lastTouchLocation - zombie.position
//            if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
//                zombie.position = lastTouchLocation
//                velocity = CGPoint.zero
//                stopZombieAnimation()
//            } else {
                move(sprite: zombie, velocity: velocity)
                rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
//            }
//        }
        
        boundsCheckZombie()
        
//        checkCollisions()
        
        moveTrain()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            
            // 1
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
            
        }
        
//        cameraNode.position = zombie.position
        moveCamera()
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        // 1
//        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
//        print("Amount to move: \(amountToMove)")
        // 2
//        sprite.position = CGPoint(
//            x: sprite.position.x + amountToMove.x,
//            y: sprite.position.y + amountToMove.y)
        
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec,
                           y: direction.y * zombieMovePointsPerSec)
    }
    
    // touch
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    // bound
    func boundsCheckZombie() {
        // scene area
//        let bottomLeft = CGPoint.zero
//        let topRight = CGPoint(x: size.width, y: size.height)
        
        // playable area
//        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
//        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
//            velocity.x = -velocity.x
            velocity.x = abs(velocity.x)
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    // debug draw
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    // rotation
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
//        sprite.zRotation = atan2(direction.y, direction.x)
        
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: "animation")
        }
    }
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnCat() {
        // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        
//        cat.position = CGPoint(
//            x: CGFloat.random(min: playableRect.minX,
//                              max: playableRect.maxX),
//            y: CGFloat.random(min: playableRect.minY,
//                              max: playableRect.maxY))
        
        // with camera
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX,
                              max: cameraRect.maxX),
            y: CGFloat.random(min: cameraRect.minY,
                              max: cameraRect.maxY))
        cat.zPosition = 50
        
        cat.setScale(0)
        addChild(cat)
        // 2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
//        let wait = SKAction.wait(forDuration: 10.0)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
//        let actions = [appear, wait, disappear, removeFromParent]
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
//        let wiggleWait = SKAction.repeat(fullWiggle, count: 10)
//        let actions = [appear, wiggleWait, disappear, removeFromParent]
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let actions = [appear, groupWait, disappear, removeFromParent]
        
        cat.run(SKAction.sequence(actions))
    }
    
    // action
//    func spawnEnemy() {
//        let enemy = SKSpriteNode(imageNamed: "enemy")
//        enemy.position = CGPoint(x: size.width + enemy.size.width/2,
//                                 y: size.height/2)
//        addChild(enemy)
//
////        let actionMove = SKAction.move(
////            to: CGPoint(x: -enemy.size.width/2, y: enemy.position.y),
////            duration: 2.0)
////        enemy.run(actionMove)
//
//        // 1
////        let actionMidMove = SKAction.move(
////            to: CGPoint(x: size.width/2,
////                        y: playableRect.minY + enemy.size.height/2),
////            duration: 1.0)
//        // 2
////        let actionMove = SKAction.move(
////            to: CGPoint(x: -enemy.size.width/2, y: enemy.position.y),
////            duration: 1.0)
//
//        // 3
////        let sequence = SKAction.sequence([actionMidMove, actionMove])
//
//        let wait = SKAction.wait(forDuration: 0.25)
////        let sequence = SKAction.sequence([actionMidMove, wait, actionMove])
//
//        let logMessage = SKAction.run() {
//            print("Reached bottom!")
//        }
////        let sequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
//
//        let actionMidMove = SKAction.moveBy(
//            x: -size.width/2-enemy.size.width/2,
//            y: -playableRect.height/2 + enemy.size.height/2,
//            duration: 1.0)
//        let actionMove = SKAction.moveBy(
//            x: -size.width/2-enemy.size.width/2,
//            y: playableRect.height/2 - enemy.size.height/2,
//            duration: 1.0)
////        let reverseMid = actionMidMove.reversed()
////        let reverseMove = actionMove.reversed()
////        let sequence = SKAction.sequence([
////            actionMidMove, logMessage, wait, actionMove,
////            reverseMove, logMessage, wait, reverseMid
////            ])
//
//
//        let halfSequence = SKAction.sequence(
//            [actionMidMove, logMessage, wait, actionMove])
//        let sequence = SKAction.sequence(
//            [halfSequence, halfSequence.reversed()])
//
//        // 4
//        enemy.run(sequence)
//
//        let repeatAction = SKAction.repeatForever(sequence)
//        enemy.run(repeatAction)
//
//    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
//        enemy.position = CGPoint(
//            x: size.width + enemy.size.width/2,
//            y: CGFloat.random(
//                min: playableRect.minY + enemy.size.height/2,
//                max: playableRect.maxY - enemy.size.height/2))
        // with camera
        enemy.position = CGPoint(
            x: cameraRect.maxX + enemy.size.width/2,
            y: CGFloat.random(
                min: cameraRect.minY + enemy.size.height/2,
                max: cameraRect.maxY - enemy.size.height/2))
        enemy.zPosition = 50
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func zombieHit(cat: SKSpriteNode) {
//        cat.removeFromParent()
//        run(catCollisionSound)
        
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        
        let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
        cat.run(turnGreen)
        
        run(catCollisionSound)
    }
    func zombieHit(enemy: SKSpriteNode) {
//        enemy.removeFromParent()
//        run(enemyCollisionSound)
        
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.zombie.isHidden = false
            self?.invincible = false
        }
        zombie.run(SKAction.sequence([blinkAction, setHidden]))
        
        run(enemyCollisionSound)
        
        loseCats()
        lives -= 1
    }
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        
        if invincible {
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(
                self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }
    
    
    func moveTrain() {
        
        var trainCount = 0
        var targetPosition = zombie.position
        
        enumerateChildNodes(withName: "train") { node, stop in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            
            // 1
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
            
        }
    }
    
    func loseCats() {
        // 1
        var loseCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            // 2
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            // 3
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: π*4, duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ]))
            // 4
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    // background
    func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        // 3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity =
            CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
    }
    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
//
//    override func didMove(to view: SKView) {
//
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
//
//
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
}
