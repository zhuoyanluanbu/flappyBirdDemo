//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Hu Youcheng on 2018/5/24.
//  Copyright © 2018年 FlappyBird. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)//创建一个场景
            
            scene.scaleMode = .aspectFill//场景填充方式
            
            view.presentScene(scene)//场景添加到控制器的视图中
            
            view.ignoresSiblingOrder = true
            
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {}
}
