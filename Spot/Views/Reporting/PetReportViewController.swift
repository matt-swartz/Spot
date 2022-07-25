//
//  PetReportViewController.swift
//  Spot
//
//  Created by Matthew Swartz on 11/15/21.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation

struct Report: Encodable {
    let username: String
    let petName: String
    let lat: Double
    let long: Double
    let approachIfFound: Bool
    let petId: String
}

class PetReportViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Standards
    let defaults = UserDefaults.standard
    // Current Location
    var currentUserLocation: CLLocation!
    // pets array
    var pets: [JSON] = []
    // our selected pet
    var petSelected: JSON = []
    // Outlets
    @IBOutlet weak var petPickerView: UIPickerView!
    @IBOutlet weak var approachControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadPets()
        petPickerView.delegate = self
        petPickerView.dataSource = self
    }
    // load a users pets
    func loadPets() {
        let username = defaults.string(forKey: "username")!
        let user: User = User(username: username)
        AF.request("https://spot-backend-api.herokuapp.com/getuserspets",
                   method: .post,
                   parameters: user,
                   encoder: JSONParameterEncoder.default).response { response in
                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
            
                    let retrievalSuccess: Bool = (statusCode == 200)
                    
                    if (retrievalSuccess) {
                        self.pets = json["pets"].array!
                        self.petPickerView.reloadAllComponents()
                    } else {
                        print("Failed to get pets")
                    }
        }
    }
    // updating our pet picker with pets
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pets.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pet = pets[row]
        var name = pet[0].string
        if (pets.count == 0) {
            name = "Please Add Pets"
        }
        return name
    }
    // getting picker value
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        petSelected = pets[row]
     }
    
    // submit button pressed
    @IBAction func submitReport(_ sender: Any) {
        if (pets.isEmpty && petSelected.isEmpty) {
            // feedbackLabel.text = "Please fill out all fields."
            print("in here")
        } else {
            if (petSelected.isEmpty) {
                petSelected = pets[0]
            }
            let username = defaults.string(forKey: "username")!
            let petName: String = petSelected[0].string!
            let petId: String = petSelected[4].string!
            // let latitude = currentUserLocation.coordinate.latitude
            // let longitude = currentUserLocation.coordinate.longitude
            let latitude = 40.0
            let longitude = -70.0
            let approachType: Bool =  (approachControl.selectedSegmentIndex == 0) ? true : false
            
            let report: Report = Report(username: username, petName: petName, lat: latitude, long: longitude, approachIfFound: approachType, petId: petId)
            
            AF.request("https://spot-backend-api.herokuapp.com/createpetreport",
                       method: .post,
                       parameters: report,
                       encoder: JSONParameterEncoder.default).response { response in
                        let json = JSON(response.value!!)
                        let statusCode = json["status"].int
                        
                        let addedReportSuccess: Bool = (statusCode == 200)
                        
                        if (addedReportSuccess) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            // self.feedbackLabel.text = "User does not exist."
                            print("in here")
                        }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
