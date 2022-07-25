//
//  StartScreenController.swift
//  Spot
//
//  Created by Jin Kim on 10/22/21.
//

import UIKit
import CoreLocation

class StartScreenController: UIViewController, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getLocationPermission()
    }
    
    /// Tries to get authorization before the tracking begins to ensure that it is set up
    func getLocationPermission() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

}
