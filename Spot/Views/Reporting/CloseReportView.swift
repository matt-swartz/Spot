//
//  CloseReportView.swift
//  Spot
//
//  Created by rachel.okeefe on 12/7/21.
//

import UIKit
import SwiftyJSON
import Alamofire

struct PetData: Encodable{
    let petId : String
}

class CloseReportController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Standards
    let defaults = UserDefaults.standard
    
    // pets array
    var pets: [JSON] = []
    
    // our selected pet
    var petSelected: JSON = []
    
    
    @IBOutlet weak var petPickerView: UIPickerView!
    @IBOutlet weak var confirmTextBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        print(self.pets)
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
        print(row)
        petSelected = pets[row]
     }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if (pets.isEmpty && petSelected.isEmpty){
            print("Nothing is selected.")
        } else if (confirmTextBox.text == "") {
            print("Confirmation is required.")
        } else if (confirmTextBox.text == "confirm") {
            // if nothing was selected
            if (petSelected.isEmpty) {
                petSelected = pets[0]
            }
            
            let pet_id: String = petSelected[4].string!
            let pet_data = PetData(petId: pet_id)
            
            // make backend request
            AF.request("https://spot-backend-api.herokuapp.com/foundpet",
                       method: .post,
                       parameters: pet_data,
                       encoder: JSONParameterEncoder.default).response { response in
                        let json = JSON(response.value!!)
                        let statusCode = json["status"].int
                        
                        let addedReportSuccess: Bool = (statusCode == 200)
                        
                        if (addedReportSuccess) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            print("Closing of report was unsuccessful.")
                        }
            }
        } else {
            print("Something went wrong.")
        }
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
