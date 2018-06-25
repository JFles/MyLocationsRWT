//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Jeremy Fleshman on 6/22/18.
//  Copyright © 2018 Jeremy Fleshman. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController,
                                     CLLocationManagerDelegate{
    //MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    //MARK: - Instance Variables and Constants
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    
    //MARK: - UIKit methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateLabels()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - IBAction methods
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
        updateLabels() // why does this need to be called here? Currently no reason AFAIK
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Misc methods (methods?)
    // What "category" is an extracted method
    func showLocationServicesDeniedAlert() {
        // create alert
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this in Settings.",
            preferredStyle: .alert)
        
        // create 'ok' action
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        
        // add 'ok' action to alert
        alert.addAction(okAction)
        
        // present the alert modal to user
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels(){
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            // for configuring app state and UI when app has not or cannot get a location
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            // expanding the messageLabel to handle multiple states
            let statusMessage: String
            // error is inferred as 'Error' type. Cast as 'NSError?' for more uses
            if let error = lastLocationError as NSError? {
                // check if the error domain is in CLErrorDomain
                // AND if the error code is CLError.denied.rawVal
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services are disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            // else if location services disabled
            } else if !CLLocationManager.locationServicesEnabled() {
                // tell user that location services are disabled
                statusMessage = "Location Services are disabled"
            // else if updating location == true
            } else if updatingLocation {
                // then tell user that currently searching
                statusMessage = "Searching..."
            // else
            } else {
                // base case -- give the user an instruction for base use
                statusMessage = "Tap 'Get My Location' to start!"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func startLocationManager() {
        // check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            // set location manager delegate to self
            locationManager.delegate = self
            // set accuracy for location manager
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            // tell locationManager to start updating location
            locationManager.startUpdatingLocation()
            // set updatingLocation flag to true
            updatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    //MARK: - CLLocationManager Delegate Methods
    // failure path delegate method
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with error \(error)")
        
        // ignore errors of not being able to find location
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            print("Could not find location")
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    // success path delegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        location = newLocation
        updateLabels()
        lastLocationError = nil
    }
}

