//
//  MyReportsViewController.swift
//  Spot
//
//  Created by Matthew Swartz on 11/16/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

struct Location: Decodable {
    let lat: Double
    let long: Double
}

struct ClosedReport: Decodable {
    let imgLink: String
    let lastLocation: Location
    let dateTime: String
    let petName: String
}

class MyReportsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var reportTableView: UITableView!
    
    // Standards
    let defaults = UserDefaults.standard
    
    var openReports: [JSON] = []
    var closedReports: [JSON] = []
    var openInd = 0
    var closedInd = 0
    var addressString = ""
    var hasLoadedOpen = false
    var hasLoadedClosed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        reportTableView.delegate = self
        reportTableView.dataSource = self
        getReports()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    // reload table view after adding a pet or updating contact info
    @objc func loadList(notification: NSNotification){
        //load data here
        getReports()
        hasLoadedOpen = false
        hasLoadedClosed = false
        self.reportTableView.reloadData()
    }
    
    
    // fetches a users reports to be displayed
    func getReports() {
        let username = defaults.string(forKey: "username")!
        let user: User = User(username: username)
        
        AF.request("https://spot-backend-api.herokuapp.com/fetchreports",
                   method: .post,
                   parameters: user,
                   encoder: JSONParameterEncoder.default).response { response in
                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
                    
                    let addedPetSuccess: Bool = (statusCode == 200)
            
                    if (addedPetSuccess) {
                        self.openReports = json["openReports"].array!
                        self.closedReports = json["closedReports"].array!
                        self.reportTableView.reloadData()
                    } else {
                        print("NOPE..here")
                        // self.feedbackLabel.text = "User does not exist."
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
                            print(address)
                            //self.reportTableView.reloadData()
                            print(self.addressString)
                            print("hello")
                      }
                })
            }
            if hasLoaded == false {
                hasLoaded = true
                self.reportTableView.reloadData()
            }
    }
    // close our reports overview page
    @IBAction func closeReportsPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        openInd = 0
        closedInd = 0
        return (openReports.count + closedReports.count + 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportMissingCell")!
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayOpenCell")!
            return cell
        } else if (indexPath.row <= openReports.count + 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OpenReportCell") as! OpenReportCell
            // edit closed report cell
            let report = openReports[openInd]
            openInd += 1
            
            let petName = report["petName"]
            let lastSeen = report["lastSeen"]
            cell.petNameLabel.text = petName.string
            cell.lastTimeLabel.text = lastSeen.string
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
                    cell.petImage.image = UIImage(data: imageData)
                }
            }
            
            // coordinates
            let lat = report["lastLocation"]["lat"].double!
            let long = report["lastLocation"]["long"].double!
            getAddressFromLatLon(pdblLatitude: lat, withLongitude: long, hasLoaded: &hasLoadedOpen)
            if self.addressString != "" {
                cell.lastLocationLabel.text = self.addressString
            } else {
                cell.lastLocationLabel.text = "No Location"
            }
            
            return cell
        } else if (indexPath.row == openReports.count + 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CloseAReportCell")!
            return cell
        } else if (indexPath.row == openReports.count + 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayClosedCell")!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CloseReportCell") as! CloseReportCell
            // edit closed report cell
            let report = closedReports[closedInd]
            closedInd += 1
            let petName = report["petName"]
            let lastSeen = report["lastSeen"]
            cell.petNameLabel.text = petName.string
            cell.timeFoundLabel.text = lastSeen.string
            
            // load image
            let imgLink = report["imgLink"]
            if (imgLink.string != nil && imgLink.string != "") {
                let imageUrl = URL(string: imgLink.string!)
                let data = try? Data(contentsOf: imageUrl!)
                
                if let imageData = data {
                    cell.petImage.image = UIImage(data: imageData)
                }
            }
            
            // coordinates
            let lat = report["lastLocation"]["lat"].double!
            let long = report["lastLocation"]["long"].double!
            getAddressFromLatLon(pdblLatitude: lat, withLongitude: long, hasLoaded: &hasLoadedClosed)
            if self.addressString != "" {
                cell.locationFoundLabel.text = self.addressString
            } else {
                cell.locationFoundLabel.text = "No Location"
            }
            
            return cell
        }
    }
    

    //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("User touched on \(indexPath) row")
        
            //self.performSegue(withIdentifier: "ToChat", sender: self)
    //}

}
