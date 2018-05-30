//
//  SoundManager.swift
//  FlappyBird
//
//  Created by Hu Youcheng on 2018/5/26.
//  Copyright © 2018年 FlappyBird. All rights reserved.
//

import SpriteKit
import AVFoundation

class SoundManager: SKNode {
    
    let touchSound = SKAction.playSoundFileNamed("sfx_wing.mp3", waitForCompletion: false)
    func playTouchSound(){
        self.run(touchSound)
    }
    
    let getPointSound = SKAction.playSoundFileNamed("sfx_point.mp3", waitForCompletion: false)
    func playgetPointSound(){
        self.run(getPointSound)
    }
    
    let getHitSound = SKAction.playSoundFileNamed("sfx_hit.mp3", waitForCompletion: false)
    func playHitSound(){
        self.run(getHitSound)
    }
    
    let getDieSound = SKAction.playSoundFileNamed("sfx_die.mp3", waitForCompletion: false)
    func playDieSound(){
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),getDieSound]))
    }
}
