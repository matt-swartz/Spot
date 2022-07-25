//
//  NearbyReportsController.swift
//  Spot
//
//  Created by rachel.okeefe on 12/7/21.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import CoreLocation

class NearbyReportsController: UITableViewController{
    
    // Standards
    let defaults = UserDefaults.standard
    
    var curr_location : CLLocation?
    var nearbyReports: [JSON] = []
    var addressString = ""
    var hasLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the row height
        self.tableView.rowHeight = 140.0
        
        getNearbyReports()

    }
    
    // reload table view after adding a pet or updating contact info
    @objc func loadList(notification: NSNotification){
        //load data here
        getNearbyReports()
        hasLoaded = false
        self.tableView.reloadData()
    }
    
    func getNearbyReports() {
        // Makes API call to the backend
        let nearby: GetNearby = GetNearby(lat: curr_location!.coordinate.latitude,
                                          long: curr_location!.coordinate.longitude)
        
        AF.request("https://spot-backend-api.herokuapp.com/getnearbyreports",
                   method: .post,
                   parameters: nearby,
                   encoder: JSONParameterEncoder.default).response { response in

                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
                    
                    let validRequest: Bool = (statusCode == 200)
                    
                    if (validRequest == true) {
                        self.nearbyReports = json["reports"].array!
                        self.tableView.reloadData()
                    
                    } else {
                        print("Something went wrong - couldn't fetch reports")
                    }
        }
        
    }
    
    // get address with longitude and latitude
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double, hasLoaded: inout Bool) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = pdblLatitude
            let lon: Double = pdblLongitude
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon
            var pm: [CLPlacemark] = []
            var address = ""

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

            do {
                ceo.reverseGeocodeLocation(loc, completionHandler:
                    {(placemarks, error) in
                        if (error != nil)
                        {
                            print("reverse geodcode fail: \(error!.localizedDescription)")
                        }

                        if placemarks != nil {
                            pm = placemarks! as [CLPlacemark]
                        }

                        if pm.count > 0 {
                            let pm = placemarks![0]

                            if pm.subThoroughfare != nil {
                                address = address + pm.subThoroughfare! + " "
                            }
                            if pm.thoroughfare != nil {
                                address = address + pm.thoroughfare! + ", "
                            }
                            if pm.subLocality != nil {
                                address = address + pm.subLocality! + ", "
                            }
                            if pm.locality != nil {
                                address = address + pm.locality! + ", "
                            }
                            if pm.postalCode != nil {
                                address = address + pm.postalCode! + " "
                            }
                            self.addressString = address
                            if self.hasLoaded == false {
                                self.hasLoaded = true
                                self.tableView.reloadData()
                            }
                      }
                })
            }
    }
}

extension NearbyReportsController  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyReports.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NearbyReportsCell

        let report = nearbyReports[indexPath.row]

        let petName = report["petName"]
        let lastSeen = report["lastSeen"]
        cell.nameLabel.text = petName.string
        cell.lastSeenLabel.text = lastSeen.string
        
        // check if dog should be approached
        let approach = report["approachIfFound"]
        if approach.bool! {
            cell.approachLabel.text = "APPROACH"
        } else {
            cell.approachLabel.text = "DO NOT APPROACH"
        }
        // load image
        let imgLink = report["imgLink"]
        if (imgLink.string != nil && imgLink.string != "") {
            let imageUrl = URL(string: imgLink.string!)
            let data = try? Data(contentsOf: imageUrl!)

            if let imageData = data {
                cell.imageLink.image = UIImage(data: imageData)
            }
        }

        // coordinates
        let lat = report["lastLocation"]["lat"].double!
        let long = report["lastLocation"]["long"].double!
        getAddressFromLatLon(pdblLatitude: lat, withLongitude: long, hasLoaded: &hasLoaded)
        if self.addressString != "" {
            cell.lastLocationLabel.text = self.addressString
        } else {
            cell.lastLocationLabel.text = "No Location"
        }

        return cell
    }
}
