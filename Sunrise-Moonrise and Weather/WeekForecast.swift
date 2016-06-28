//
//  WeekForecast.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/25/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit

struct WeekForecast {
    
    var hitempC: Int
    var lowtempC: Int
    var hitempF: Int
   var lowtempF: Int
    var icon: String!
   
    
    init(forecastDictionary: [String : AnyObject]) {
        
        hitempC = forecastDictionary["hitempC"] as! Int
        lowtempC = forecastDictionary["lowtempC"] as! Int
        hitempF = forecastDictionary["hitempF"] as! Int
        lowtempF = forecastDictionary["lowtempF"] as! Int
        icon = forecastDictionary["icon"] as! String
        
        
}
}


