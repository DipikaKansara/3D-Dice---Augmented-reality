//
//  ViewController.swift
//  3DDice
//
//  Created by Dipika Kansara on 2/9/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dicearray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
   
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchlocation = touch.location(in: sceneView)
            
            let result = sceneView.hitTest(touchlocation, types: .existingPlaneUsingExtent)
            
            
            if let hitresult = result.first{
                
                addDice(AtLocation: hitresult)
              
         
            }
        }
    }
    
    
    func addDice(AtLocation: ARHitTestResult){
        
        let scene = SCNScene(named: "art.scnassets/diceCollada copy.scn")!

        if  let dicenode =  scene.rootNode.childNode(withName: "Dice", recursively: true){
            dicenode.position = SCNVector3(
                AtLocation.worldTransform.columns.3.x,
                AtLocation.worldTransform.columns.3.y + dicenode.boundingSphere.radius,
                AtLocation.worldTransform.columns.3.z)

            dicearray.append(dicenode)
            
            sceneView.scene.rootNode.addChildNode(dicenode)
            
            roll(dice: dicenode)
      

        }
        
    }
    
    func   roll(dice: SCNNode){
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5
        ))

        
    }
    
    
    func rollAll(){
        if !dicearray.isEmpty {
            for dice  in dicearray{
                roll(dice: dice)
            }
        }
    }
    
    
    @IBAction func RollButtonPressed(_ sender: UIBarButtonItem) {
        
        rollAll()
        
        print("Pressed")
    }
    
    @IBAction func RemoveDice(_ sender: UIBarButtonItem) {
        
        if !dicearray.isEmpty {
            for dice  in dicearray{
                dice.removeFromParentNode()
            }
    }
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

            // Run the view's session
            sceneView.session.run(configuration)
      
        
     
    }
    
 
   
    
    
    
    
   
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is  ARPlaneAnchor{

           let planeAnchor = anchor as! ARPlaneAnchor

            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

            let planenode = SCNNode()

            planenode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)

            planenode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)

            let gridmaterial = SCNMaterial()

            gridmaterial.diffuse.contents = UIImage(named: "art.scnassets/Grid-two-BLUE.png")

            plane.materials = [gridmaterial]

            planenode.geometry = plane

            node.addChildNode(planenode)
        }
        else{
            return
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        // Pause the view's session
//        sceneView.session.pause()
//    }

    
}
