//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit
import ARKit

class SettingViewController : UIViewController{
   
    @IBOutlet weak var offlineRecognitionControl: UISwitch!

    @IBAction func onUseOfflineRecognition(_ sender: Any) {
        
        if offlineRecognitionControl.isOn {
            Constants.useOnDeviceRecognition = true
        } else {
            Constants.useOnDeviceRecognition = false
        }
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
