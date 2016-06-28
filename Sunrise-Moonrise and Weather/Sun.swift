//
//  SunMoonInfo.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/27/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit

struct Sun {
    var sunrise: String!
    var sunset: String!
   
  init(SunDictionary: NSDictionary) {
        
        sunrise = timeStringFromUnixTime1(SunDictionary["rise"] as! Double)
        sunset = timeStringFromUnixTime1(SunDictionary["set"] as! Double)
    }
    
    func timeStringFromUnixTime1(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.timeZone = NSTimeZone(name: GoogleTimeZoneAPIClient.sharedInstance().timeZone)
        return dateFormatter.stringFromDate(date)
    }

    
    
}

