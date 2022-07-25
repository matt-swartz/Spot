//
//  AddContactScreenController.swift
//  Spot
//
//  Created by Matthew Swartz on 11/4/21.
//

import UIKit
import SwiftyJSON
import Alamofire

struct ContactInfo: Encodable {
    let username: String
    let email: String
    let phoneNumber: String
}

class AddContactScreenController: UIViewController {
    
    // Standards
    let defaults = UserDefaults.standard

    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var phoneLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sumbitContactInfo(_ sender: Any) {
        let phone = phoneLabel.text!
        let email_addr = emailLabel.text!
        
        if (email_addr.isEmpty && phone.isEmpty) {
            feedbackLabel.text = "Please enter one or both fields above"
        } else {
            // add phone number to user
            let user = defaults.string(forKey: "username")!
            
            let contactInfo: ContactInfo = ContactInfo(username: user, email: email_addr, phoneNumber: phone)
            
            AF.request("https://spot-backend-api.herokuapp.com/updatecontactinfo",
                       method: .post,
                       parameters: contactInfo,
                       encoder: JSONParameterEncoder.default).response { response in
                        let json = JSON(response.value!!)
                        let statusCode = json["status"].int
                        
                        let updateSuccess: Bool = (statusCode == 200)
                
                        if (updateSuccess) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.feedbackLabel.text = "Try Again Later"
                        }
                }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
