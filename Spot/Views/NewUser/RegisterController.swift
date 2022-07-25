//
//  RegisterController.swift
//  Spot
//
//  Created by Jin Kim on 10/18/21.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation

struct Register: Encodable {
    let firstName: String
    let username: String
    let password: String
    let lat: Double
    let long: Double
}

/**
 This controller is used to handle everything on the Register View Controller in the New User storyboard
 */
class RegisterController: UIViewController, CLLocationManagerDelegate {
    
    // Standards
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var firstNameTextField: BubbleTextField!
    @IBOutlet weak var usernameTextField: BubbleTextField!
    @IBOutlet weak var passwordTextField: BubbleTextField!
    @IBOutlet weak var confirmPasswordTextField: BubbleTextField!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var createAccountButton: BubbleButton!
    
    var locationManager = CLLocationManager()
    var currentUserLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        }
    }
    
    func save(_ key: String, _ value: Any) {
        defaults.set(value, forKey: "\(key)")
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        let firstName: String = firstNameTextField.text!
        let username: String = usernameTextField.text!
        let password: String = passwordTextField.text!
        let confirmPassword: String = confirmPasswordTextField.text!
        
        if (password != confirmPassword) {
            feedbackLabel.text = "Passwords do not match"
        } else if (password.count < 8) {
            feedbackLabel.text = "Please select a longer password"
        } else if (firstName.isEmpty || username.isEmpty) {
            feedbackLabel.text = "Please fill out all fields"
        } else {
            
            let register: Register = Register(firstName: firstName, username: username, password: password,
                                              lat: currentUserLocation.coordinate.latitude, long: currentUserLocation.coordinate.longitude)
            
            AF.request("https://spot-backend-api.herokuapp.com/register",
                       method: .post,
                       parameters: register,
                       encoder: JSONParameterEncoder.default).response { response in

                        let json = JSON(response.value!!)
                        let statusCode = json["status"].int
                        
                        let validRegistration: Bool = (statusCode == 200)
                        
                        if (validRegistration == true) {
                            
                            // See documentation
                            let accessToken = json["token"].string
                            let firstName = json["firstName"].string
                            
                            self.save("username", username)
                            self.save("accessToken", accessToken!)
                            self.save("firstName", firstName!)
                            self.save("completedTraining", false)
                            
                            self.performSegue(withIdentifier: "ToTrainingRegistered", sender: self)
                        } else {
                            self.feedbackLabel.text = "Username taken"
                        }
            }
        }
    }
}

extension RegisterController {

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
