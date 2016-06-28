//
//  GoogleTimeZoneAPIClient.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 2/13/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit

let KEY = "AIzaSyCYhzAMdl1wBrxL1yAu7x-8OdZtyxQFqgo"


class GoogleTimeZoneAPIClient : NSObject{
   
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    var timeZone : String!
    
    func findTimeZone(Place: String, timestamp: Double, completionHandler: (success:Bool, errorString:String?)-> Void){
        let methodArguments = [
            "key": KEY,
            "timestamp":"\(timestamp)",
            "location": "\(Place)"
            ]
        let BASE_URL_WEATHER = "https://maps.googleapis.com/maps/api/timezone/json"
        let urlString = BASE_URL_WEATHER + escapedParameters(methodArguments)
        let urlEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: urlEncoded!)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, errorString: "Could not complete the request. The internet connection seems to be offline")
                
            } else {
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                let response = parsedResult["timeZoneId"] as! String
                self.timeZone = response
                
              
                
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
    
    
    class func sharedInstance() -> GoogleTimeZoneAPIClient {
        
        struct Singleton {
            static var sharedInstance = GoogleTimeZoneAPIClient()
        }
        
        return Singleton.sharedInstance
    }
    
    

}
