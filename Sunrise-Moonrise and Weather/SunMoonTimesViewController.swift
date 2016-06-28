//
//  SunMoonTimesViewController.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/6/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AddressBookUI

class SunMoonTimesViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var sunsetLabel: UILabel!
    
    
    @IBOutlet weak var moonriseLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
    
    @IBOutlet weak var moonsetLabel: UILabel!
    
 
    
    @IBOutlet weak var phaseLabel: UILabel!
    
   
  
    @IBOutlet weak var phaseNameLabel: UILabel!
    
    var dateToday : String!
    var displayLocation : String!
    var latitude : Double!
    var longitude : Double!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTextField.delegate = self
       
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        dateToday = "\(year)"+"-"+"\(month)"+"-"+"\(day)"
       let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
       view.addGestureRecognizer(recognizer)
    }
    
   func handleTap(recognizer: UITapGestureRecognizer) {
        dateTextField.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        self.navigationController?.navigationBarHidden = false
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
        
        if savedLocation == nil{
            let errorAlert = UIAlertController(title: "Please enable location services", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorAlert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            return
        }else{
             self.displayInfo(dateToday)
        }
    }
    
    @IBAction func textFieldEditBegin(sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        
        if dateTextField.text!.isEmpty {
            let alertController = UIAlertController(title: "Please enter a date to search", message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.displayInfo(dateTextField.text!)
            self.dateTextField.text = ""
        }
    }
    
    func displayInfo(dateAssigned : String){
        self.cityLabel.text = displayLocation
        self.dateLabel.text = dateAssigned
        AerisAPIClient.sharedInstance().downloadSunMoonInfo(displayLocation,date: dateAssigned){(success,errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    print("success")
                    let sunInfo : Sun = AerisAPIClient.sharedInstance().sunForecast
                     let moonInfo : Moon = AerisAPIClient.sharedInstance().moonForecast
                    self.sunriseLabel.text = "Sunrise : \(sunInfo.sunrise)"
                    self.sunsetLabel.text = "Sunset : \(sunInfo.sunset)"
                    self.moonriseLabel.text = "Moonrise : \(moonInfo.moonrise)"
                   self.moonsetLabel.text = "Moonset : \(moonInfo.moonset)"
                    self.phaseLabel.text = "Moon Phase: \((moonInfo.phase)*100)%"
                    self.phaseNameLabel.text = "Moon Phase Name : \(moonInfo.phaseName)"
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    }
                )
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                })
                
            }
        }
        
    }
    
    
}

