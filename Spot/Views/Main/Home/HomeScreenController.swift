//
//  HomeScreenController.swift
//  Spot
//
//  Created by Jin Kim on 10/17/21.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import CoreLocation

struct GetNearby: Codable {
    let lat: Double
    let long: Double
}

class HomeScreenController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let defaults = UserDefaults.standard
    
    var locationManager = CLLocationManager()
    var currentUserLocation: CLLocation!

    var eventClicked: ReportEvent = ReportEvent()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapSettings() // Sets up the calls for the map
    }
    
    func mapSettings() {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
        
        // Gets user location if allowed
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .restricted, .denied:
            print("Don't have access to user location, do something here")
        default:
            currentUserLocation = locationManager.location
            
            getNearbyReports()
        }
    }
    
    func getNearbyReports() {
        // Makes API call to the backend
        let nearby: GetNearby = GetNearby(lat: currentUserLocation.coordinate.latitude,
                                          long: currentUserLocation.coordinate.longitude)
        
        AF.request("https://spot-backend-api.herokuapp.com/getnearbyreports",
                   method: .post,
                   parameters: nearby,
                   encoder: JSONParameterEncoder.default).response { response in

                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
                    
                    let validRequest: Bool = (statusCode == 200)
                    
                    if (validRequest == true) {
                        let reports = json["reports"]
                        
                        self.addPins(reports)

                    } else {
                        print("Something went wrong - couldn't fetch reports")
                    }
        }
    }
    
    func addPins(_ json: JSON) {
        
        var reports = [ReportEvent]()
        
        for i in 0 ..< json.count {

            let rep: ReportEvent = ReportEvent(lat: json[i]["lastLocation"]["lat"].double!,
                                               long: json[i]["lastLocation"]["long"].double!,
                                               petName: json[i]["petName"].string!,
                                               username: json[i]["username"].string!,
                                               approach: json[i]["approachIfFound"].bool!,
                                               lastSeen: json[i]["lastSeen"].string!,
                                               petId: json[i]["petId"].string!,
                                               breed: json[i]["breed"].string!)
            
            reports.append(rep)
        }
        
        for report in reports {
            let eventpins = EventAnnotation()
            eventpins.event = report // Here we link the event with the annotation
            eventpins.title = report.petName
            eventpins.coordinate = CLLocationCoordinate2D(latitude: report.lat, longitude: report.long)
            mapView.addAnnotation(eventpins)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect pin: MKAnnotationView) {
        // first ensure that it really is an EventAnnotation:
        if let eventAnnotation = pin.annotation as? EventAnnotation {
            self.eventClicked = eventAnnotation.event!
            self.performSegue(withIdentifier: "ToSpecificReport", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Sending information to the next
        if segue.identifier == "ToSpecificReport" {
            if let destView = segue.destination as? ViewSpecificReportController {
                destView.currReport = eventClicked
            }
        } else if segue.identifier == "showNearbyReportList" {
            // pass user location through segue
            let dest = segue.destination as! NearbyReportsController
            dest.curr_location = self.currentUserLocation
        }
    }
}

extension HomeScreenController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print(error)
    }

    // Utilize this if we plan on updating the user location and refreshing
    // We shouldn't need to though -> Doesn't make much sense to
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            print(location.coordinate.latitude)
//            print(location.coordinate.longitude)
//        }
    }
 }
