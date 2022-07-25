//
//  LoginController.swift
//  Spot
//
//  Created by Jin Kim on 10/18/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

struct Login: Encodable {
    let username: String
    let password: String
    
    let lat: Double
    let long: Double
    
    func notEmpty() -> Bool {
        return username.isEmpty || password.isEmpty
    }
}

/**
 This controller is used to handle everything on the Login View Controller in the New User storyboard
 */
class LoginController: UIViewController, CLLocationManagerDelegate {
    
    // Standards
    let defaults = UserDefaults.standard
    
    // Text fields
    @IBOutlet weak var usernameTextField: BubbleTextField!
    @IBOutlet weak var passwordTextField: BubbleTextField!
    
    // Response label
    @IBOutlet weak var responseOfLogin: UILabel!
    
    // Login Button
    @IBOutlet weak var loginButton: BubbleButton!
    
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
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let username: String = usernameTextField.text!
        let password: String = passwordTextField.text!
        
        let login = Login(username: username, password: password, lat: currentUserLocation.coordinate.latitude, long: currentUserLocation.coordinate.longitude)
        
        if (login.notEmpty()) {
            responseOfLogin.text = "Username/password not filled out"
            return
        }

        AF.request("https://spot-backend-api.herokuapp.com/login",
                   method: .post,
                   parameters: login,
                   encoder: JSONParameterEncoder.default).response { response in
                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
                    
                    let validLogin: Bool = (statusCode == 200)
                    
                    if (validLogin) {
                        // See documentation
                        let accessToken = json["token"].string
                        let firstName = json["firstName"].string
                        let completedTraining: Bool = json["completedTraining"].bool!
                        
                        self.save("username", username)
                        self.save("accessToken", accessToken!)
                        self.save("firstName", firstName!)
                        
                        if (completedTraining) {
                            self.performSegue(withIdentifier: "LoginComplete", sender: self)
                        } else {
                            self.save("completedTraining", false)
                            self.performSegue(withIdentifier: "ToTraining", sender: self)
                        }
                    } else {
                        // Login failed -> Display response
                        self.responseOfLogin.text = "Incorrect username/password. Try again."
                    }
        }
    }
    
}

extension LoginController {

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
