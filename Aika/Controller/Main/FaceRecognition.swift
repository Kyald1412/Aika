//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import ARKit

extension MainViewController: ARSCNViewDelegate {
    private func faceFrame(from boundingBox: CGRect) -> CGRect {
        
        //translate camera frame to frame inside the ARSKView
        let origin = CGPoint(x: boundingBox.minX * sceneView.bounds.width, y: (1 - boundingBox.maxY) * sceneView.bounds.height)
        let size = CGSize(width: boundingBox.width * sceneView.bounds.width, height: boundingBox.height * sceneView.bounds.height)
        
        return CGRect(origin: origin, size: size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
//        let node = SCNNode(geometry: faceMesh)
//        node.geometry?.firstMaterial?.fillMode = .lines
//        return node
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor{
//            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            
            DispatchQueue.main.async {
                self.lblAnalysis.text = self.analysis
            }
        }
    }
    
    func expression(anchor: ARFaceAnchor) {
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let lookUp = anchor.blendShapes[.eyeLookUpLeft]?.decimalValue ?? 0.0 > 0.5 && anchor.blendShapes[.eyeLookUpRight]?.decimalValue ?? 0.0 > 0.5
        let lookRight = anchor.blendShapes[.eyeLookOutLeft]?.decimalValue ?? 0.0 > 0.5 && anchor.blendShapes[.eyeLookInRight]?.decimalValue ?? 0.0 > 0.5
        let lookLeft = anchor.blendShapes[.eyeLookInLeft]?.decimalValue ?? 0.0 > 0.5 && anchor.blendShapes[.eyeLookOutRight]?.decimalValue ?? 0.0 > 0.5
        let lookDown = anchor.blendShapes[.eyeLookDownLeft]?.decimalValue ?? 0.0 > 0.5 && anchor.blendShapes[.eyeLookDownRight]?.decimalValue ?? 0.0 > 0.5

    
        self.analysis = ""
        
        if lookUp {
            self.analysis += "You are looking up!. "
        }
        
        if lookLeft {
            self.analysis += "You are looking left!. "
        }
        
        if lookRight {
            self.analysis += "You are looking right!. "
        }
        
        if lookDown {
            self.analysis += "You are looking down!. "
        }
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += "You are smiling. "
        }

    }
}
