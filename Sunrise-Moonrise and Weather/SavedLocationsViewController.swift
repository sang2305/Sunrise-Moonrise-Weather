//
//  SavedLocationsViewController.swift
//  Sunrise-Moonrise and Weather
//
//  Created by Sangeetha on 1/6/16.
//  Copyright © 2016 Sangeetha. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import AddressBookUI
import GoogleMaps

class SavedLocationsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,LocateAddress{
    
    // Temperature Switch
    @IBOutlet weak var tempSwitch: UISwitch!
    
    
    
    @IBOutlet weak var locationTableView: UITableView!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var locationArray = [NSManagedObject]()
    
    var searchResultController:SearchResultsController!
    var resultsArray = [String]()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()

    var switchState : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        
        if (defaults.objectForKey("SwitchState") != nil) {
            tempSwitch.on = defaults.boolForKey("SwitchState")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest(entityName: "Location")
        do{
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            locationArray = results as! [NSManagedObject]
        }catch{
            print("Error fetching saved locations")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchResultController = SearchResultsController()
        searchResultController.delegate = self

    }
    
    func searchBar(searchBar: UISearchBar,
                   textDidChange searchText: String){
       
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:NSError?) -> Void in
            self.resultsArray.removeAll()
            
            if results == nil {
                return
            }
            guard error == nil else {
                print("Autocomplete error \(error)")
                return
            }
            for result in results!{
               
                if let result = result as? GMSAutocompletePrediction{
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
           
                self.searchResultController.reloadDataWithArray(self.resultsArray)
          
            
        }
    }

    
    @IBAction func addLocation(sender: AnyObject) {
      
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.presentViewController(searchController, animated: true, completion: nil)
       // self.forwardGeocoding(locationTextField.text!)
    }
    
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                let errorAlert = UIAlertController(title: "Enter a valid location as City,State/Country", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
       //       let cityName = (placemark?.locality)!
            
                if location != nil{
               //     self.saveLocation(self.locationTextField.text!)
                    self.saveLocation(address)
                    self.locationTableView.reloadData()
               //     self.locationTextField.text = ""
                } 
            }
        })
    }
    
    func saveLocation(locationText: String){
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: sharedContext)
        let place = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: sharedContext)
        place.setValue(locationText, forKey: "place")
        
        do{
            
            try sharedContext.save()
            locationArray.append(place)
        }catch{
            print("Error while adding new location")
        }
        
        
    }
    
    @IBAction func gotoCurrentLocation(sender: AnyObject) {
        let nextVC = self.storyboard?.instantiateViewControllerWithIdentifier("navVC") as! UINavigationController
        let destVC = nextVC.topViewController as! TabBarViewController
        destVC.selectedLocation = "Current Location"
        self.presentViewController(nextVC, animated: true, completion: nil)
    }
    
    @IBAction func saveSwitchState(sender: AnyObject) {
        tempSwitch.on = (sender as! UISwitch).on
        defaults.setBool(tempSwitch.on, forKey: "SwitchState")
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationTableCell") as! locationTableCell
        let place = locationArray[indexPath.row]
        cell.locationLabel.text = place.valueForKey("place") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        let nextVC = self.storyboard?.instantiateViewControllerWithIdentifier("navVC") as! UINavigationController
        let destVC = nextVC.topViewController as! TabBarViewController
        
        let place = locationArray[indexPath.row]
        let address = place.valueForKey("place") as! String
        destVC.selectedLocation = address
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
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

        
        self.presentViewController(nextVC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
    
            sharedContext.deleteObject(locationArray[indexPath.row])
            do {
                try sharedContext.save()
            } catch let error as NSError {
                print("Error removing location: \(error)")
            }
            
            locationArray.removeAtIndex(indexPath.row)
            
            // Refresh the table view to indicate that it's deleted
            self.locationTableView.reloadData()


        }
        
        
        
                   }
    
    class func sharedInstance() -> SavedLocationsViewController {
        
        struct Singleton {
            static var sharedInstance = SavedLocationsViewController()
        }
        
        return Singleton.sharedInstance
    }
    
   
    
}