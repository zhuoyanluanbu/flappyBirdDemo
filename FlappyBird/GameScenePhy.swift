//
//  GameScenePhy.swift
//  FlappyBird
//
//  Created by Hu Youcheng on 2018/5/25.
//  Copyright © 2018年 FlappyBird. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

extension GameScene {
    
    /*
     * 设置小鸟节点的物理属性
     */
    func setBirdPhysics() {
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdCate //物理体表示
        bird.physicsBody?.contactTestBitMask = pipesCate | gapCate | landCate//设置可以和小鸟相碰撞的物体检测
        giveBirdImpulseY()
    }
    
    func setLandPhysics(){
        land.physicsBody = SKPhysicsBody(rectangleOf: land.size,center:CGPoint(x: land.size.width*0.5, y: 0.5*land.size.height))
        land.physicsBody?.isDynamic = false
        land.physicsBody?.allowsRotation = false
        land.physicsBody?.categoryBitMask = landCate
    }
    
    /*
     * 给小鸟一个速度
     */
    func giveBirdImpulseY(){
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 7))//y方向冲量
    }
    
    /*
     * 设置水管节点的物理属性
     */
    func setPipesPhysics(topPipe:SKSpriteNode,gap:SKSpriteNode,bottomPipe:SKSpriteNode) {
        topPipe.physicsBody = SKPhysicsBody(texture: topPipe.texture!, size: (topPipe.size))
        topPipe.physicsBody?.isDynamic = false //不能活动
        topPipe.physicsBody?.categoryBitMask = pipesCate
        gap.physicsBody = SKPhysicsBody(rectangleOf: gap.size)
        gap.physicsBody?.isDynamic = false
        gap.physicsBody?.categoryBitMask = gapCate
        bottomPipe.physicsBody = SKPhysicsBody(texture: bottomPipe.texture!, size: (bottomPipe.size))
        bottomPipe.physicsBody?.isDynamic = false //不能活动
        bottomPipe.physicsBody?.categoryBitMask = pipesCate
    }
    
    /*
     * 检测碰撞的委托
     */
    func didBegin(_ contact: SKPhysicsContact){
        if contact.bodyB.categoryBitMask == gapCate { //通过水管
            if contact.bodyB.node?.parent != nil {
                contact.bodyB.node?.removeFromParent()
                self.soundManager.playgetPointSound()
                self.refreshScore()
            }
        }else{
            if contact.bodyB.categoryBitMask != landCate {
                soundManager.playDieSound()
            }
            gameEnded()
        }
    }
    func didEnd(_ contact: SKPhysicsContact){
    }
    
}
