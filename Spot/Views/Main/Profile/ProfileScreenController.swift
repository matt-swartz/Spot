//
//  ProfileScreenController.swift
//  Spot
//
//  Created by Jin Kim on 10/29/21.
//

import UIKit
import Alamofire
import SwiftyJSON

struct User: Encodable {
    let username: String
}

class ProfileScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Standards
    let defaults = UserDefaults.standard
    var pets: [JSON] = []
    var email: String = ""
    var phone: String = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPets()
        loadContactInfo()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    // reload table view after adding a pet or updating contact info
    @objc func loadList(notification: NSNotification){
        //load data here
        loadPets()
        loadContactInfo()
        self.tableView.reloadData()
    }
    
    func loadPets() {
        let username = defaults.string(forKey: "username")!
        let user: User = User(username: username)
        
        // this just puts the username somewhere on the screen
        self.nameLabel.text = username
        self.nameLabel.textColor = Colors.spotRed
        
        AF.request("https://spot-backend-api.herokuapp.com/getuserspets",
                   method: .post,
                   parameters: user,
                   encoder: JSONParameterEncoder.default).response { response in
                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
            
                    let retrievalSuccess: Bool = (statusCode == 200)
                    
                    if (retrievalSuccess) {
                        self.pets = json["pets"].array!
                        self.tableView.reloadData()
                    } else {
                        print("Failed to load")
                    }
        }
    }
    
    func loadContactInfo() {
        let username = defaults.string(forKey: "username")!
        let user: User = User(username: username)
        AF.request("https://spot-backend-api.herokuapp.com/getcontactinfo",
                   method: .post,
                   parameters: user,
                   encoder: JSONParameterEncoder.default).response { response in
                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
            
                    let retrievalSuccess: Bool = (statusCode == 200)
            
                    if (retrievalSuccess) {
                        // grab users contact info
                        self.email = json["email"].string!
                        self.phone = json["phone"].string!
                        // reload table to display data
                        self.tableView.reloadData()
                    } else {
                        print("Failed to load")
                    }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count + 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !(pets.isEmpty) {
            if (indexPath.row < pets.count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PetCell")! as! PetCell
                let pet = pets[indexPath.row]
                    
                let name = pet[0], type = pet[1], breed = pet[2], url = pet[3]
                
                cell.nameLabel.text = name.string
                cell.breedLabel.text = breed.string
                if type == "Dog" {
                    cell.petTypeLabel.text = "Dog"
                } else {
                    cell.petTypeLabel.text = "Cat"
                }
                
                if (url.string != nil) {
                    let imageUrl = URL(string: url.string!)
                    let data = try? Data(contentsOf: imageUrl!)
                    
                    if let imageData = data {
                        cell.petImage.image = UIImage(data: imageData)
                    }
                }
                return cell
            }
        }
        
        if (indexPath.row == pets.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPetCell")!
            return cell
        } else if (indexPath.row == pets.count + 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactInfoCell")! as! ContactInfoCell
            if (email.isEmpty) {
                cell.contactInfoLabel.text = "Phone: \(phone)"
            } else if (phone.isEmpty) {
                cell.contactInfoLabel.text = "Email: \(email)"
            } else {
                cell.contactInfoLabel.text = "Phone: \(phone)\nEmail: \(email)"
            }
            return cell
        } else if (indexPath.row == pets.count + 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddContactCell")!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell")!
            return cell
        }
    }
    
    func save(_ key: String, _ value: Any) {
        defaults.set(value, forKey: "\(key)")
    }
    
    // when logout button is pressed
    //
    @IBAction func logout(_ sender: Any) {
        self.save("username", "")
        self.save("accessToken", "")
        self.save("firstName", "")
    }
}
