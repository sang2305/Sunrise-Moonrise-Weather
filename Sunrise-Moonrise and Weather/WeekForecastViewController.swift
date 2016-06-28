//
//  WeekForecastViewController.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/6/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit


class WeekForecastViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weatherTableView: UITableView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var currentDay: Int!
    
    var weekArray: NSArray!
   
    var displayLocation: String!
    
    var attStringCF:NSMutableAttributedString!
    var attStringFF:NSMutableAttributedString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
        weekArray = self.identifyWeekday()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        self.navigationController?.navigationBarHidden = false
        let fontCF:UIFont? = UIFont(name: "Helvetica", size:17)
        let fontSuperCF:UIFont? = UIFont(name: "Helvetica", size:8)
        unitCheck = NSUserDefaults.standardUserDefaults().boolForKey("SwitchState")
        if (unitCheck == true){
            
            
            attStringFF = NSMutableAttributedString(string: "oF", attributes: [NSFontAttributeName:fontCF!])
            attStringFF.setAttributes([NSFontAttributeName:fontSuperCF!,NSBaselineOffsetAttributeName:8], range: NSRange(location:0,length:1))
            
        }else{
            
            attStringCF = NSMutableAttributedString(string: "oC", attributes: [NSFontAttributeName:fontCF!])
            attStringCF.setAttributes([NSFontAttributeName:fontSuperCF!,NSBaselineOffsetAttributeName:8], range: NSRange(location:0,length:1))
            
        }
        
        let model = (self.tabBarController as! TabBarViewController).model
        if(model.newLocation != nil){
            if(model.newLocation == "Current Location"){
                displayLocation = savedLocation
            }else{
            displayLocation = model.newLocation
            }
        }else{
            displayLocation = savedLocation
        }
        self.cityLabel.text = displayLocation
        if savedLocation == nil{
            let errorAlert = UIAlertController(title: "Please enable location services", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorAlert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            return
            
        }else{
            displayTableView()
        }
    }
    
    func displayTableView(){
        AerisAPIClient.sharedInstance().downloadWeekForecast(displayLocation){(success,errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    print("success")
                    self.weatherTableView.reloadData()

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
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (AerisAPIClient.sharedInstance().weekWeather).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WeekTableCell") as! WeekTableCell
     let forecast = (AerisAPIClient.sharedInstance().weekWeather)[indexPath.row]
        cell.dayLabel.text = weekArray[indexPath.row] as? String
        
        if (unitCheck == true){
            cell.hiUnitLabel.attributedText = attStringFF
            cell.loUnitLabel.attributedText = attStringFF
           cell.hitempLabel.text = " Hi: \(forecast.hitempF)"
            cell.lotempLabel.text = " Lo: \(forecast.lowtempF)"
        }else{
            cell.hiUnitLabel.attributedText = attStringCF
            cell.loUnitLabel.attributedText = attStringCF
            cell.hitempLabel.text = " Hi: \(forecast.hitempC)"
            cell.lotempLabel.text = " Lo: \(forecast.lowtempC)"
        }
        

        cell.weatherImage.image = UIImage(named: "\(forecast.icon)")
        return cell
    }
    
    func identifyWeekday()-> NSArray{
        currentDay = NSDate().dayOfWeek()
        switch currentDay {
        case 1:
            return ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        case 2:
            return ["Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday","Monday"]
        case 3:
            return ["Wednesday","Thursday","Friday","Saturday","Sunday","Monday","Tuesday"]
        case 4:
            return ["Thursday","Friday","Saturday","Sunday","Monday","Tuesday","Wednesday"]
        case 5:
            return ["Friday","Saturday","Sunday","Monday","Tuesday","Wednesday","Thursday"]
        case 6:
            return ["Saturday","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday"]
        case 7:
            return ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        default:
            print("Error fetching days")
            return ["Error","Error","Error","Error","Error","Error","Error"]
        }
       
    }
    
       
}

extension NSDate {
    func dayOfWeek() -> Int? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Weekday, fromDate: self) {
                return comp.weekday
        } else {
            return nil
        }
    }
}
