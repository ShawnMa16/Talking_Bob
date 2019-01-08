//
//  Post.swift
//  Talking_Bob
//
//  Created by Shawn Ma on 10/30/18.
//  Copyright © 2018 Shawn Ma. All rights reserved.
//

import Foundation
import SceneKit
import UIKit
import SnapKit
import SpriteKit

class PostView: SCNNode {
    
    let skScene: SKScene = {
        let scene = SKScene(size: CGSize(width: 400, height: 100))
        return scene
    }()
    
    let labelNode : SKLabelNode = {
        let node = SKLabelNode()
        node.fontSize = 30
        node.fontName = "SFProText-Semibold"
        node.position = CGPoint(x: 200, y: 50)
        node.numberOfLines = 0
        node.verticalAlignmentMode = .center
        node.fontColor = .black
        return node
    }()
    
    let plane: SCNPlane = {
        let plane = SCNPlane(width: 0.2, height: 0.05)
        plane.cornerRadius = plane.width / 32
        return plane
    }()
    
    let planeNode: SCNNode = {
        let node = SCNNode()
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = [.Y]
        node.constraints = [constraint]
        return node
    }()
    
    
    init(text: String) {
        super.init()
        
        skScene.addChild(labelNode)
        
        labelNode.text = text
        
        setupView()
        
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView() {
        
        plane.firstMaterial?.diffuse.contents = skScene
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        
        planeNode.geometry = plane
        
        adjustLabelFontSizeToFitRect(labelNode: self.labelNode, rect: skScene.frame)

    }
    
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {
        
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / (labelNode.frame.width + 30), rect.height / (labelNode.frame.height + 30))
        
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor
        
        // Optionally move the SKLabelNode to the center of the rectangle.
//        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
    
    func setBackground(isBob: Bool, alpha: CGFloat) {
        let color = isBob ? UIColor(named: "bobColor") : UIColor(named: "userColor")
        skScene.backgroundColor = (color?.withAlphaComponent(0.5))!
        self.opacity = alpha
    }
}
