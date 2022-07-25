//
//  ViewSpecificReportController.swift
//  Spot
//
//  Created by Jin Kim on 11/16/21.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class ViewSpecificReportController: UIViewController {
    
    var currReport: ReportEvent = ReportEvent()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var approachLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var justSeenButton: BubbleButton!
    
    @IBOutlet weak var petImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadReportInformation()
    }
    
    // Loads in the information into the screen
    func loadReportInformation() {
        nameLabel.text = currReport.petName
        lastSeenLabel.text = currReport.lastSeen
        if (currReport.approachIfFound) {
            approachLabel.text = "You can approach \(currReport.petName)"
        } else {
            approachLabel.text = "Do NOT approach \(currReport.petName)"
        }
        
        // Load in the image from AWS
        let imageURL = URL(string: currReport.imgLink)
        let imagedData = NSData(contentsOf: imageURL!)!
        petImage.image = UIImage(data: imagedData as Data)
        
        breedLabel.text = "Breed: " + currReport.breed
        
        ownerLabel.text = "Owner: " + currReport.username
        
        if currReport.email == "" && currReport.phone == "" {
            contactLabel.text = "No other contact information - send them a message!"
        } else {
            contactLabel.text = "Email " + currReport.email + " Phone: " + currReport.phone
        }
    }
    
    @IBAction func recentlySeen(_ sender: Any) {
        
        let alert = UIAlertController(title: "Report Updated!",
            message: "Thank you for your report",
            preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in })
        
        alert.addAction(confirm)

        // Used to set pet status to found
        AF.request("https://spot-backend-api.herokuapp.com/foundpet",
                   method: .post,
                   parameters: petKey(petId: currReport.petId),
                   encoder: JSONParameterEncoder.default).response { response in

                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int

                    let validRequest: Bool = (statusCode == 200)

                    if (validRequest == true) {
                        self.present(alert, animated: true)

                    } else {
                        print("Something went wrong - couldn't fetch reports")
                    }
        }
        
    }
    
}
