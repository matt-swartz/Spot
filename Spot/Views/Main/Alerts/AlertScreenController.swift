//
//  AlertScreenController.swift
//  Spot
//
//  Created by Jin Kim on 10/29/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class AlertScreenController: UIViewController {
    
    // Standards
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    
    // string array for all alerts
    var all_alerts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register the view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // set the row height
        self.tableView.rowHeight = 60.0
        
        loadAlerts()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    // make an API request for all notifications
    func loadAlerts() {
        
        // get username for API call
        let username = defaults.string(forKey: "username")!
        let user: User = User(username: username)
        
        AF.request("https://spot-backend-api.herokuapp.com/fetchnotifications",
                   method: .post,
                   parameters: user,
                   encoder: JSONParameterEncoder.default).response { response in

                    let json = JSON(response.value!!)
                    
                    let statusCode = json["status"].int

                    let validRequest: Bool = (statusCode == 200)

                    // if the request returns statusCode == 200
                    if (validRequest == true) {
                        let all_notifications = json["notifications"]

                        self.parse_notifications(all_notifications)

                    } else {
                        print("Couldn't fetch notifications")
                    }
        }
        
    }
    
    func parse_notifications(_ json: JSON){
        // loop backwards through all notifications (display most recent ones first)
        for i in stride(from: json.count-1, through: 0, by: -1) {
            let notification = json[i]["message"].string!
            
            all_alerts.append(notification)
        }

        tableView.reloadData()
    }
}

extension AlertScreenController : UITableViewDataSource{
    
    // Override basic table functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return all_alerts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = all_alerts[indexPath.row]

        return cell
    }
}

extension AlertScreenController : UITableViewDelegate {
    
}
