//
//  ReportEvent.swift
//  Spot
//
//  Created by Jin Kim on 11/19/21.
//

import Foundation
import Alamofire
import SwiftyJSON

struct petKey: Codable {
    let petId: String
}

struct userKey: Codable {
    let username: String
}

// This class is used to transfer information between pets
class ReportEvent {
    
    var lat: Double = 0.0
    var long: Double = 0.0
    
    var petName: String = ""
    var username: String = ""
    
    var approachIfFound: Bool = true
    var lastSeen: String = ""
    var breed: String = ""
    
    var imgLink: String = ""
    var petId: String = ""
    
    var email: String = ""
    var phone: String = ""
    
    init(lat: Double, long: Double, petName: String, username: String,
         approach: Bool, lastSeen: String, petId: String, breed: String) {
        self.lat = lat
        self.long = long
        self.petName = petName
        self.username = username
        self.approachIfFound = approach
        self.lastSeen = lastSeen
        self.petId = petId
        self.breed = breed
        // Currently hardcoded
        self.imgLink = "https://bestdogwalkerkelowna.com/wp-content/uploads/2019/12/white-and-black-siberian-husky-2853129.jpg"
        
        let pet = petKey(petId: petId)
        
        AF.request("https://spot-backend-api.herokuapp.com/getpetimage",
                   method: .post,
                   parameters: pet,
                   encoder: JSONParameterEncoder.default).response { response in

                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
                    
                    let validRequest: Bool = (statusCode == 200)
                    
                    if (validRequest == true) {
                        self.imgLink = json["imgLink"].string!

                    } else {
                        print("Something went wrong - maybe use an alert here?")
                    }
        }
        
        AF.request("https://spot-backend-api.herokuapp.com/getcontactinfo",
                   method: .post,
                   parameters: userKey(username: self.username),
                   encoder: JSONParameterEncoder.default).response { response in

                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
                    
                    let validRequest: Bool = (statusCode == 200)
                    
                    if (validRequest == true) {
                        self.email = json["email"].string!
                        self.phone = json["phone"].string!

                    } else {
                        print("Something went wrong - maybe use an alert here?")
                    }
        }
    }
    
    // Used to initialize in a view controller
    // -> Should never be sent anywhere in this state
    init() {}
}
