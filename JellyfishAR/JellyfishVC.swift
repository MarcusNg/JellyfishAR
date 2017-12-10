//
//  JellyfishVC.swift
//  JellyfishAR
//
//  Created by Marcus Ng on 12/9/17.
//  Copyright © 2017 Marcus Ng. All rights reserved.
//

import UIKit
import ARKit
import Each

class JellyfishVC: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var timerLbl: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    
    var timer = Each(1).seconds
    var countdown = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startBtnPressed(_ sender: Any) {
        self.setTimer()
        self.addNode()
        self.startBtn.isEnabled = false
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        self.timer.stop()
        self.restoreTimer()
        self.startBtn.isEnabled = true
        // Remove all nodes from rootnode
        sceneView.scene.rootNode.enumerateHierarchy { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.pause()
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func addNode() {
        let jellyfishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyfishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false) // Jellyfish is an immediate child of the root node (don't search every node recursively)
        let x = randomNumbers(firstNum: -1, secondNum: 1)
        let y = randomNumbers(firstNum: -0.5, secondNum: 0.5)
        let z = randomNumbers(firstNum: -1, secondNum: 1)
        jellyfishNode?.position = SCNVector3(x,y,z)
        self.sceneView.scene.rootNode.addChildNode(jellyfishNode!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoords = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoords)
        if hitTest.isEmpty {
            print("didn't hit anything")
        } else {
            if countdown > 0 {
                let results = hitTest.first!
                let node = results.node
                // Check if animation is occurring
                if node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    self.animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.addNode()
                        self.restoreTimer()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        let pos = node.presentation.position
        spin.fromValue = pos
        spin.toValue = SCNVector3(pos.x - 0.2, pos.y - 0.2, pos.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLbl.text = String(self.countdown)
            if self.countdown == 0 {
                self.timerLbl.text = "You lose!"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countdown = 10
        self.timerLbl.text = String(self.countdown)
    }
    
}

extension JellyfishVC {
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
}


