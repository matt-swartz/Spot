//
//  ConclusionController.swift
//  Spot
//
//  Created by Jin Kim on 10/28/21.
//

import UIKit
import Alamofire
import SwiftyJSON

struct Params: Encodable {
    let username: String
}

class ConclusionController: UIViewController {
    
    // Standards
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var doneButton: BubbleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func save(_ key: String, _ value: Any) {
        defaults.set(value, forKey: "\(key)")
    }
    
    @IBAction func completedTrainingClicked(_ sender: Any) {
        save("completedTraining", true)
        
        let username: String = defaults.object(forKey: "username") as! String
        
        let params: Params = Params(username: username)
        
        AF.request("https://spot-backend-api.herokuapp.com/updatetrainingstatus",
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { _ in
        }
        
        performSegue(withIdentifier: "DoneWithTraining", sender: self)
        
        
    }
    
}
