//
//  GameScene.swift
//  FlappyBird
//
//  Created by Hu Youcheng on 2018/5/24.
//  Copyright © 2018年 FlappyBird. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameStatus {
    case idle    //初始化
    case running    //游戏运行中
    case over    //游戏结束
}


let birdCate:UInt32 = 0x1 << 1
let landCate:UInt32 = 0x1 << 2
let pipesCate:UInt32 = 0x1 << 3
let gapCate:UInt32 = 0x1 << 4

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var gameStatus:GameStatus = .idle

    lazy var background:SKSpriteNode = {
        let background = SKSpriteNode(imageNamed: "bg_day_double")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -10
        background.size = CGSize(width: self.size.width*2, height: self.size.height)
        return background
    }()
    
    lazy var land:SKSpriteNode = {
        let land = SKSpriteNode(imageNamed: "land_double")
        land.anchorPoint = CGPoint(x: 0, y: 0)
        land.position = CGPoint(x: 0, y: 0)
        land.zPosition = -2
        land.size = CGSize(width: self.size.width*2, height: 70)
        return land
    }()
    
    lazy var bird:SKSpriteNode = {
        let bird = SKSpriteNode(imageNamed: "bird_red_0")
        bird.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        bird.zPosition = 2
        return bird
    }()
    
    //开始按钮
    let startBtnName = "startBtn"
    lazy var startBtn:SKSpriteNode = {
        let startBtn = SKSpriteNode(imageNamed: "button_play")
        startBtn.size = CGSize(width: startBtn.size.width/2, height: startBtn.size.height/2)
        startBtn.position = CGPoint(x:bird.position.x,y:bird.position.y-50)
        startBtn.name = startBtnName
        return startBtn
    }()
    
    //暂停按钮
    let pauseOrResumeBtnName = "pauseOrResumeBtn"
    lazy var pauseOrResumeBtn:SKSpriteNode = {
        let pauseOrResumeBtn = SKSpriteNode(texture: SKTexture(imageNamed: "button_pause"))
        pauseOrResumeBtn.size = CGSize(width: pauseOrResumeBtn.size.width, height: pauseOrResumeBtn.size.height)
        pauseOrResumeBtn.anchorPoint = CGPoint(x: 0, y: 0)
        pauseOrResumeBtn.zPosition = 99
        pauseOrResumeBtn.position = CGPoint(x:20,y:self.size.height - 15 - pauseOrResumeBtn.size.height)
        pauseOrResumeBtn.name = pauseOrResumeBtnName
        return pauseOrResumeBtn
    }()
    
    //准备文字
    lazy var getReadyAndTitleLabel:[SKSpriteNode] = {
        let getReadyLabel = SKSpriteNode(texture: SKTexture(imageNamed: "text_ready"))
        getReadyLabel.size = CGSize(width: getReadyLabel.size.width, height: getReadyLabel.size.height)
        getReadyLabel.position = CGPoint(x:bird.position.x,y:bird.position.y + 50)
        let titleLabel = SKSpriteNode(texture: SKTexture(imageNamed: "title"))
        titleLabel.size = CGSize(width: titleLabel.size.width, height: titleLabel.size.height)
        titleLabel.position = CGPoint(x:getReadyLabel.position.x,y:getReadyLabel.position.y + 60)
        return [getReadyLabel,titleLabel]
    }()
    
    //游戏结束label
    lazy var gameOverLabel:SKSpriteNode = {
        let gameOverLabel = SKSpriteNode(texture: SKTexture(imageNamed: "text_game_over"))
        gameOverLabel.zPosition = 99
        gameOverLabel.position = CGPoint(x:self.size.width*0.5,y:self.size.height+gameOverLabel.size.height)
        return gameOverLabel
    }()
    
    //游戏分数显示
    var score:Int = 0
    let scoreLabelName = "scoreLabel"
    lazy var scoreLabel:SKLabelNode = {
        let scoreLabel:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score:\(score)"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 15
        scoreLabel.zPosition = 99
        scoreLabel.position = CGPoint(x: self.size.width - 48, y: self.size.height - 37)
        scoreLabel.name = scoreLabelName
        return scoreLabel
    }()
    
    var soundManager = SoundManager()
    
    override func didMove(to view: SKView) {
        addChild(background)
        addChild(land)
        addChild(bird)
        addChild(startBtn)
        addChild(soundManager)
        for lable in getReadyAndTitleLabel {
            addChild(lable)
        }
        addChild(gameOverLabel)
        self.gameReady()
        //添加物理体，限制边框
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -3.3)
    }
    
    //每一帧都会调用这个方法
    override func update(_ currentTime: TimeInterval) {
        if gameStatus != .over {
            self.moveScene()
        }else{
            gameOverAnimation()
        }
    }
    
    /*
     * 点击
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pointInScene = touches.first?.location(in: self)
        let touchNode = self.atPoint(pointInScene!)
        switch self.gameStatus {
        case .idle:
            if (touchNode.name != nil) && (touchNode.name! == self.startBtnName) {//开始按钮
                self.startBtn.isHidden = true
                _ = self.getReadyAndTitleLabel.map{$0.isHidden = true}
                self.gameStarted()
                addChild(scoreLabel)
                addChild(pauseOrResumeBtn)
            }
        case .running:
            if (touchNode.name != nil) && (touchNode.name! == self.pauseOrResumeBtnName) {//暂停按钮
                if (self.scene?.isPaused)! {
                    self.pauseOrResumeBtn.texture = SKTexture(imageNamed: "button_pause")
                    self.scene?.isPaused = false
                }else {
                    self.pauseOrResumeBtn.texture = SKTexture(imageNamed: "button_resume")
                    self.scene?.isPaused = true
                }
                return
            }
            self.giveBirdImpulseY()
            self.soundManager.playTouchSound()
        case .over:
            print("game over")
            gameReStart()
//            self.gameReady()
        }
        
    }
    
    
    /*
     * 场景移动
     */
    func moveScene(){
        moveBackground()
        moveLand()
        movePipes()
    }
    
    /*
     * 背景移动
     */
    func moveBackground(){
        //移动背景
        background.position = CGPoint(x: background.position.x - 0.3, y: background.position.y)
        //当背景移动超出屏幕左边框，重设背景到初始位置
        if background.position.x < -self.size.width {
            background.position = CGPoint(x: 0, y: background.position.y)
        }
    }
    
    //移动地面
    func moveLand(){
        //移动背景
        land.position = CGPoint(x: land.position.x - 1, y: land.position.y)
        //当背景移动超出屏幕左边框，重设背景到初始位置
        if land.position.x < -self.size.width {
            land.position = CGPoint(x: 0, y: land.position.y)
        }
    }
    
    let flyActionKey = "fly"
    /*
     * 小鸟飞行动画
     */
    func birdFlying(){
        let flyAction = SKAction.animate(with: [SKTexture(imageNamed: "bird_red_0"),SKTexture(imageNamed: "bird_red_1"),SKTexture(imageNamed: "bird_red_2"),SKTexture(imageNamed: "bird_red_1")], timePerFrame: 0.1)
        bird.run(SKAction.repeatForever(flyAction),withKey:flyActionKey)
    }
    
    /*
     * 小鸟停止飞行
     */
    func birdStopFlying() {
        bird.removeAction(forKey: flyActionKey)
    }
    
    /*
     * 添加水管
     */
    func addPipes(pipesGap:CGFloat,topHeight:CGFloat){
        let topTexture = SKTexture(imageNamed: "pipe_up")
        let topSize = CGSize(width: topTexture.size().width, height: topHeight)
        let topPipe = SKSpriteNode(texture: topTexture, size: topSize)
        topPipe.name = "pipe"
        topPipe.position = CGPoint(x: self.size.width + 0.5*topSize.width, y: self.size.height - 0.5*topSize.height)
        
        let gap = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: pipesGap))
        gap.name = "gap"
        gap.position = CGPoint(x: topPipe.position.x + 0.5*topSize.width, y: topPipe.position.y - 0.5*topSize.height - 0.5*pipesGap)
        
        let bottomTexture = SKTexture(imageNamed: "pipe_down")
        let bottomSize = CGSize(width: bottomTexture.size().width, height: self.size.height - topHeight - pipesGap - land.size.height)
        let bottomPipe = SKSpriteNode(texture: bottomTexture, size: bottomSize)
        bottomPipe.name = "pipe"
        bottomPipe.position = CGPoint(x: topPipe.position.x, y: 0.5*bottomSize.height + land.size.height)
        
        topPipe.zPosition = 1
        gap.zPosition = 1
        bottomPipe.zPosition = 1
        
        addChild(topPipe)
        addChild(gap)
        addChild(bottomPipe)
        
        self.setPipesPhysics(topPipe: topPipe,gap: gap,bottomPipe: bottomPipe)
    }
    
    /*
     * 随机添加水管
     */
    func randomPipes() {
        //水管之间的间距，小鸟通过，这里最小为小鸟的3倍，最大为小鸟的5倍
        let minGap = self.bird.size.height * 3
        let maxGap = self.bird.size.height * 6
        let randomPipesGap = CGFloat(arc4random_uniform(UInt32(maxGap - minGap))) + minGap//上下水管的随机高度

        //上水管的随机高度
        let minTopHeight = self.size.height / 16
        let maxTopHeight = self.size.height / 16 * 13 - randomPipesGap
        let randomTopHeight = CGFloat(arc4random_uniform(UInt32(maxTopHeight - minTopHeight))) + minTopHeight
        
        addPipes(pipesGap: randomPipesGap, topHeight: randomTopHeight)
    }
    
    /*
     * 重复创建水管
     */
    let createPipesActionKey = "createPipes"
    func startCreatePipesAction(){
        //创建一个等待的action,等待时间的平均值为3秒，变化范围为1秒
        let waitAction = SKAction.wait(forDuration: 4, withRange: 1)
        
        //创建水管
        let bornPipeAction = SKAction.run {
            self.randomPipes()
        }
        
        //让场景重复执行“等待->创建->等待->创建”的过程
        run(SKAction.repeatForever(SKAction.sequence([waitAction,bornPipeAction])),withKey:createPipesActionKey)
    }
    
    /*
     * 停止创建水管
     */
    func stopCreatePipesAction(){
       self.removeAction(forKey: createPipesActionKey)
    }
    
    /*
     * 移除所有水管
     */
    func removeAllPipesNodes(){
        for pipe in self.children {
            if pipe.name == "pipe" || pipe.name == "gap" {
                pipe.removeFromParent()
            }
        }
    }
    
    /*
     * 水管移动
     */
    func movePipes(){
        for pipeNode in self.children {
            if pipeNode.name == "pipe" || pipeNode.name == "gap" {
                if let pipeSpriteNode = pipeNode as? SKSpriteNode {
                    pipeSpriteNode.position = CGPoint(x: pipeSpriteNode.position.x - 1, y: pipeSpriteNode.position.y)
                    //移动出屏幕后要删除该节点
                    if pipeSpriteNode.position.x < -pipeSpriteNode.size.width {
                        pipeSpriteNode.removeFromParent()
                    }
                }
            }
        }
    }
    
    /*
     * game over 下落
     */
    func gameOverAnimation(){
        if isCanRestart {
            return
        }
        if self.gameOverLabel.position.y <= self.size.height/9*5{
            self.isCanRestart = true
            return
        }
        self.gameOverLabel.position.y -= 3
    }
    
    /*
     * 刷新分数
     */
    func refreshScore(){
        score += 1
        self.scoreLabel.text = "Score:\(score)"
    }
    
    func gameReady(){
        self.gameStatus = .idle
        self.birdFlying()
    }
    func gameStarted(){
        self.setBirdPhysics()
        self.setLandPhysics()
        self.startCreatePipesAction()
        self.gameStatus = .running
    }
    func gameEnded(){
        if self.gameStatus != .over {
            self.gameStatus = .over
            self.birdStopFlying()
            self.stopCreatePipesAction()
            self.soundManager.playHitSound()
            pauseOrResumeBtn.removeFromParent()
            for pipe in self.children where (pipe.name == "pipe" || pipe.name == "gap") {  //去掉物理属性
                pipe.physicsBody = nil
            }
            self.score = 0
        }
    }
    
    /*
     * 重新开始游戏
     */
    var isCanRestart = false
    func gameReStart(){
        if isCanRestart {
            let scene = GameScene(size: (self.view?.bounds.size)!)//创建一个场景
            scene.scaleMode = self.scaleMode//场景填充方式
            self.view?.presentScene(scene,transition:SKTransition.fade(withDuration: 1))//场景添加到控制器的视图中
            self.view?.ignoresSiblingOrder = true
            if #available(iOS 10.0, *) {
                self.view?.preferredFramesPerSecond = 60
            }
            self.view?.showsFPS = true
        }
    }
    
    deinit{print("GameScene deinited")}
}
