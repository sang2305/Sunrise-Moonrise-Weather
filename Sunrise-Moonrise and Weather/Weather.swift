//
//  Weather.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/14/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit

struct Weather {
    
    var temperatureC: Int
    var feelTemperatureC: Int
    var temperatureF: Int
    var feelTemperatureF: Int
    var humidity: Double
    var precipProbability: Double
    var summary: String!
    var icon: String!
    var windDir: String!
    var windSpeed: Double
    
    init(weatherDictionary: NSDictionary) {
        
        temperatureC = weatherDictionary["tempC"] as! Int
        feelTemperatureC = weatherDictionary["feelslikeC"] as! Int
        temperatureF = weatherDictionary["tempF"] as! Int
        feelTemperatureF = weatherDictionary["feelslikeF"] as! Int
        humidity = weatherDictionary["humidity"] as! Double
        precipProbability = weatherDictionary["precipIN"] as! Double
        summary = weatherDictionary["weather"] as! String
        windDir = weatherDictionary["windDir"] as! String
        windSpeed = weatherDictionary["windSpeedMPH"] as! Double
        icon = weatherDictionary["icon"] as! String
        
    }
       
       
    }
