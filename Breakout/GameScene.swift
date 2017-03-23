//
//  GameScene.swift
//  Breakout
//
//  Created by balgard & jliu on 3/13/17.
//  Copyright © 2017 Brendan Algard & Jason Liu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var brick = SKSpriteNode()
    var button = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var label = SKLabelNode()
    var lives = 3
    var score = 0
    var level = 1
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BlockCategory  : UInt32 = 0x1 << 2
    let PaddleCategory : UInt32 = 0x1 << 3
    
    //create a lot more categories and change the paddle into an array of spriteNodes with each having a different bitmaskcategory, on collision change the impulse and direction of the ball based on what part of the paddle is hit.
    
    override func didMove(to view: SKView)
    {
        createButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            let node = self.nodes(at: location)
            if (node[0].name == "button")
            {
                createBackground()
                makeBall()
                makePaddle()
                makeBrick()
                makeLoseZone()
                createInfoLabel()
                physicsWorld.contactDelegate = self
                self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
                ball.physicsBody?.isDynamic = true
                ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 3))
                ball.physicsBody?.categoryBitMask = BallCategory
                button.removeFromParent()
            }
            else if (node[0].name == "Reset Button")
            {
                resetGame()
                lives = 3
                score = 0
            }
            paddle.position.x = location.x
        }
    }
    func createButton()
    {
        button = SKSpriteNode(imageNamed: "startButton")
        button.position = CGPoint(x: frame.midX, y: frame.midY)
        button.name = "button"
        addChild(button)
    }
    
    func checkGame()
    {
        if bricks.count == 0
        {
            var label = SKLabelNode()
            label.position = CGPoint(x: frame.midX, y: 0)
            label.text = "Level Completed \nScore: \(score) \nLives Left: \(lives)"
            label.fontColor = UIColor.white
            label.fontSize = 30
            addChild(label)
            
            ball.removeFromParent()
        }
    }
    func resetGame()
    {
        self.removeAllChildren()
        bricks.removeAll()
        createButton()
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        body1 = contact.bodyA
        body2 = contact.bodyB
        var x = 0
        for br in bricks
        {
            
            if body1.categoryBitMask == BlockCategory || body2.categoryBitMask == BlockCategory
            {
                br.removeFromParent()
                bricks.remove(at: x)
                checkGame()
                score += 4
                label.text = "Lives: \(lives) \t Score: \(score)"
            }
            if body1.categoryBitMask == BottomCategory || body2.categoryBitMask == BottomCategory
            {
                if lives > 1
                {
                    lives -= 1
                    resetGame()
                }
                else
                {
                    self.removeAllChildren()
                    var loss = SKLabelNode()
                    loss.position = CGPoint(x: frame.midX, y: 0)
                    loss.text = "You Lose \nScore: \(score)"
                    loss.fontColor = UIColor.white
                    loss.fontSize = 30
                    addChild(loss)
                    var reset = SKLabelNode()
                    reset.position = CGPoint(x: frame.midX, y: frame.minY + 25)
                    reset.text = "Restart"
                    reset.fontColor = UIColor.white
                    reset.fontSize = 30
                    reset.name = "Reset Button"
                    addChild(reset)
                    

                }
            }
            x += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            var location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    func createInfoLabel()
    {
        label = SKLabelNode()
        label.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        label.fontSize = 20
        label.name = "Info Label"
        label.fontColor = UIColor.black
        label.text = "Lives: \(lives) \t Score: \(score)"
        addChild(label)
    }
    
    func createBackground()
    {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x:0, y:starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y:-starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y:starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeBall()
    {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.fillColor = UIColor.yellow
        ball.name = "ball"
        
        //physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        //ignores forces and impulses
        ball.physicsBody?.isDynamic = false
        ball.physicsBody?.usesPreciseCollisionDetection = true
        //no loss of energy via friction
        ball.physicsBody?.friction = 0
        //gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        //bounces fully off other objects
        ball.physicsBody?.restitution = 1
        //does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        ball.physicsBody?.categoryBitMask = BallCategory
        addChild(ball) //add ball to the view
    }
    
    func makePaddle()
    {
        paddle = SKSpriteNode(color: UIColor.white, size:CGSize(width: frame.width/4, height: frame.height/25))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.categoryBitMask = PaddleCategory
        addChild(paddle)
    }
    
    func makeBrick()
    {
        brick = SKSpriteNode(color: UIColor.blue, size: CGSize(width: frame.width/5, height: frame.height/25))
        brick.position = CGPoint(x: frame.midX, y: frame.maxY - 30)
        brick.name = "brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.physicsBody?.categoryBitMask = BlockCategory
        addChild(brick)
        bricks.append(brick)
    }
    
    func makeLoseZone()
    {
        let loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y:frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        loseZone.physicsBody?.categoryBitMask = BottomCategory
        addChild(loseZone)
    }
    
}
