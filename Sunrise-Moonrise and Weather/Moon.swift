//
//  Moon.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/27/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit

struct Moon {
   
    var moonrise: String!
    var moonset: String!
    var phase : Double!
    var phaseName : String!
    
    init(MoonDictionary: NSDictionary) {
       
        moonrise = timeStringFromUnixTime1(MoonDictionary["rise"] as! Double)
        if let moonsettime = MoonDictionary["set"] as? Double {
        moonset = timeStringFromUnixTime1(moonsettime)
        }else{
            moonset = "No set"
        }
        let phaseInfo = MoonDictionary["phase"] as! NSDictionary
        phase = phaseInfo["phase"] as! Double
        phaseName = phaseInfo["name"] as! String
        
    }
    
    func timeStringFromUnixTime1(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.timeZone = NSTimeZone(name: GoogleTimeZoneAPIClient.sharedInstance().timeZone)
        return dateFormatter.stringFromDate(date)
    }

    
}
