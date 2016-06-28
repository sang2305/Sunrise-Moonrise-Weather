//
//  AerisAPIClient.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/6/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit


let BASE_URL_SUNMOON = "https://api.aerisapi.com/sunmoon/"
let CLIENT_ID = "nc19UtVrSz1ueRJU7swMr"
let CLIENT_SECRET = "AexgkPlJv46Nac2AYNLv6dCl8txJlgR5zdfkxN6y"

class AerisAPIClient : NSObject{
    var sunForecast : Sun!
    var moonForecast : Moon!
    var currentWeather : Weather!
    var weekWeather : [WeekForecast] = []
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
}
    
    
    func downloadTodaysWeather(location:String, completionHandler: (success:Bool, errorString:String?)-> Void){
        let methodArguments = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "filter" : "1hr",
            "limit":"2"
        ]
        let BASE_URL_WEATHER = "https://api.aerisapi.com/forecasts/\(location)"
        let urlString = BASE_URL_WEATHER + escapedParameters(methodArguments)
        let urlEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: urlEncoded!)!
        let request = NSURLRequest(URL: url)
       
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, errorString: "Could not complete the request. The internet connection seems to be offline")
                
            } else {
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                let response = parsedResult["response"] as? [[String:AnyObject]]
               
                for response in response!{
                   let periods = response["periods"] as? [[String:AnyObject]]
                    let info = periods![0] as? NSDictionary
                  
                    self.currentWeather = Weather(weatherDictionary: info!)
                
                }
                
               completionHandler(success: true, errorString: nil)
                
                
            }
        }
        
        task.resume()
    
    }
    
    func downloadWeekForecast(location:String, completionHandler: (success:Bool, errorString:String?)-> Void){
        let methodArguments = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "limit":"8"
        ]
        let BASE_URL_WEATHER = "https://api.aerisapi.com/forecasts/\(location)"
        let urlString : String = BASE_URL_WEATHER + escapedParameters(methodArguments)
        let urlEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: urlEncoded!)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, errorString: "Could not complete the request. The internet connection seems to be offline")
                
            } else {
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                let response = parsedResult["response"] as? [[String:AnyObject]]
                
                for response in response!{
                    let periods = response["periods"] as? NSArray
                    self.weekWeather = []
                    let today = periods![0] as! NSDictionary
                   for period in periods!{
                    
                    if period as! NSDictionary != today{
                        if let forecast = self.weekWeatherForecast(period as! NSDictionary){
                           
                            self.weekWeather.append(forecast)
                         
                        }
                        }
                    }
                    
                }
                
                completionHandler(success: true, errorString: nil)
                
                
            }
        }
        
        task.resume()
        
    }
   func weekWeatherForecast(forecastDict: NSDictionary)->WeekForecast? {
        let hitempC = forecastDict["maxTempC"] as! Int
        let lowtempC = forecastDict["minTempC"] as! Int
        let hitempF = forecastDict["maxTempF"] as! Int
        let lowtempF = forecastDict["minTempF"] as! Int
        let icon = forecastDict["icon"] as? String
    
        let forecastDictionary: [String : AnyObject] = ["hitempC":hitempC, "lowtempC":lowtempC, "icon":icon!,"hitempF":hitempF, "lowtempF":lowtempF]
        
        return WeekForecast(forecastDictionary : forecastDictionary )

    }
    
    func downloadSunMoonInfo(location:String, date:String ,completionHandler: (success:Bool, errorString:String?)-> Void){
        let methodArguments = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "from":"\(date)",
            "to" : "\(date)"
        ]
        let BASE_URL_WEATHER = "https://api.aerisapi.com/sunmoon/\(location)"
        let urlString = BASE_URL_WEATHER + escapedParameters(methodArguments)
        let urlEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: urlEncoded!)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, errorString: "Could not complete the request. The internet connection seems to be offline")
                
            } else {
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                let response = parsedResult["response"] as? [[String:AnyObject]]
                
                for response in response!{
                    let sunInfo = response["sun"] as? NSDictionary
                    self.sunForecast = Sun(SunDictionary: sunInfo!)
                    let moonInfo = response["moon"] as! NSDictionary
                    self.moonForecast = Moon(MoonDictionary: moonInfo)

                }
                
                completionHandler(success: true, errorString: nil)
                
                
            }
        }
        
        task.resume()
        
    }


    
    
    
    // MARK: Escape HTML Parameters
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    class func sharedInstance() -> AerisAPIClient {
        
        struct Singleton {
            static var sharedInstance = AerisAPIClient()
        }
        
        return Singleton.sharedInstance
    }


    
}
