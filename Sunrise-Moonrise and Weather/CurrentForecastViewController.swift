//
//  CurrentForecastViewController.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/4/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentForecastViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

  
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var currentTempLabel: UILabel! 
    
    @IBOutlet weak var feelsLikeTempLabel: UILabel!
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var precipitationLabel: UILabel!
    
    @IBOutlet weak var WindSpeedLabel: UILabel!
    
    @IBOutlet weak var windDirLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
   
    let locationManager = CLLocationManager()
   var place : String!
    
    @IBOutlet weak var tempUnitLabel: UILabel!
    
    
    @IBOutlet weak var feelsUnitLabel: UILabel!
    
    var attStringCT:NSMutableAttributedString!
    var attStringCF:NSMutableAttributedString!
    var attStringFT:NSMutableAttributedString!
    var attStringFF:NSMutableAttributedString!

    
    var defaults = NSUserDefaults.standardUserDefaults()

  override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        //To use superscript for degreeC and degreeF)
        let fontCT:UIFont? = UIFont(name: "Helvetica", size:42)
        let fontSuperCT:UIFont? = UIFont(name: "Helvetica", size:18)
        let fontCF:UIFont? = UIFont(name: "Helvetica", size:17)
        let fontSuperCF:UIFont? = UIFont(name: "Helvetica", size:8)
        unitCheck = NSUserDefaults.standardUserDefaults().boolForKey("SwitchState")
        if (unitCheck == true){
            
            attStringFT = NSMutableAttributedString(string: "oF", attributes: [NSFontAttributeName:fontCT!])
            attStringFT.setAttributes([NSFontAttributeName:fontSuperCT!,NSBaselineOffsetAttributeName:18], range: NSRange(location:0,length:1))
            attStringFF = NSMutableAttributedString(string: "oF", attributes: [NSFontAttributeName:fontCF!])
            attStringFF.setAttributes([NSFontAttributeName:fontSuperCF!,NSBaselineOffsetAttributeName:8], range: NSRange(location:0,length:1))
            tempUnitLabel.attributedText = attStringFT
            feelsUnitLabel.attributedText = attStringFF
        }else{
            attStringCT = NSMutableAttributedString(string: "oC", attributes: [NSFontAttributeName:fontCT!])
            attStringCT.setAttributes([NSFontAttributeName:fontSuperCT!,NSBaselineOffsetAttributeName:18], range: NSRange(location:0,length:1))
            attStringCF = NSMutableAttributedString(string: "oC", attributes: [NSFontAttributeName:fontCF!])
            attStringCF.setAttributes([NSFontAttributeName:fontSuperCF!,NSBaselineOffsetAttributeName:8], range: NSRange(location:0,length:1))
            tempUnitLabel.attributedText = attStringCT
            feelsUnitLabel.attributedText = attStringCF
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        let model = (tabBarController as! TabBarViewController).model
        
        if(model.newLocation != nil){
            if model.newLocation == "Current Location"{
                activityIndicator.hidden = false
                activityIndicator.startAnimating()
                findCurrentLocation()
            }else{
                activityIndicator.hidden = false
                activityIndicator.startAnimating()
                self.updateWeatherInfo(model.newLocation)
                self.cityLabel.text = model.newLocation
            }
        }
        if launch == "First" {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            findCurrentLocation()
        }
        

    }
    
    func findCurrentLocation(){
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
            launch = "Second"
       
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let geoCoder = CLGeocoder()
        
        let location = locations.last! as CLLocation
        
        self.locationManager.stopUpdatingLocation()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            // City
            let city = placeMark.addressDictionary!["City"] as? String
            let State = placeMark.addressDictionary!["State"] as? String
            savedLocation = city!+","+State!
            print("Location: \(savedLocation)")
            self.cityLabel.text = savedLocation
            geoCoder.geocodeAddressString(savedLocation, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error)
                    return
                }
                if placemarks?.count > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    let latlon : String = "\(coordinate!.latitude),\(coordinate!.longitude)"
                    let timestamp = NSDate().timeIntervalSince1970
                    
                    GoogleTimeZoneAPIClient.sharedInstance().findTimeZone(latlon, timestamp: timestamp){(success,errorString) in
                        if success{
                            dispatch_async(dispatch_get_main_queue(),{
                                print("Time Zone found")
                                
                                }
                            )
                        }else{
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(errorAlert, animated: true, completion: nil)
                            })
                            
                        }
                    }
                    
                    
                }
            })
            

            self.updateWeatherInfo(savedLocation)
            
        })
       
     
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
         self.locationManager.stopUpdatingLocation()
        let errorAlert = UIAlertController(title: "Please enable the location services", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(errorAlert, animated: true, completion: nil)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
       
    }

    //location authorization status changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .AuthorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        case .Denied:
            let errorAlert = UIAlertController(title: "Please enable the location services", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorAlert, animated: true, completion: nil)

            
        default:
            break
        }
    }
    
    func updateWeatherInfo(currentLocation:String){
        AerisAPIClient.sharedInstance().downloadTodaysWeather(currentLocation){(success,errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    print("Success")
                    let weatherInfo : Weather = AerisAPIClient.sharedInstance().currentWeather
                    if (unitCheck == true){
                        self.currentTempLabel.text = "\(String(weatherInfo.temperatureF))"
                        self.feelsLikeTempLabel.text = "Feels like \(String(weatherInfo.feelTemperatureF))"
                        
                    }else{
                        self.currentTempLabel.text = "\(String(weatherInfo.temperatureC))"
                        self.feelsLikeTempLabel.text = "Feels like \(String(weatherInfo.feelTemperatureC))"
                        
                    }

                    
                    self.summaryLabel.text = weatherInfo.summary
                    self.iconView.image = UIImage(named: "\(weatherInfo.icon)")
                    self.humidityLabel.text = "Humidity :\(String(weatherInfo.humidity))"
                    self.precipitationLabel.text = "Precipitation :\((weatherInfo.precipProbability) * 100)%"
                    self.windDirLabel.text = weatherInfo.windDir
                    self.WindSpeedLabel.text = "Wind :\(String(weatherInfo.windSpeed))mph"

                    }
                )
                }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
                
            }
        }
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        


    }
    

    class func sharedInstance() -> CurrentForecastViewController {
        
        struct Singleton {
            static var sharedInstance = CurrentForecastViewController()
        }
        
        return Singleton.sharedInstance
    }
    

   

}

