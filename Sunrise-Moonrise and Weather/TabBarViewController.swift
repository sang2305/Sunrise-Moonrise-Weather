
//
//  TabBarViewController.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/28/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import UIKit
import Foundation

class ModelData {
    var newLocation : String!
    
}

class TabBarViewController: UITabBarController{
   
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var check : Bool!
    
    var selectedLocation : String!
    
    var model = ModelData()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.menuButton.enabled = true
        if selectedLocation != nil{
        model.newLocation = selectedLocation
        
        }
        self.navigationController?.navigationBarHidden = false
    }
   
       
}