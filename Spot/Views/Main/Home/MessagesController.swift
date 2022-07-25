//
//  MessagesController.swift
//  Spot
//
//  Created by rachel.okeefe on 11/29/21.
//

import UIKit
import Alamofire
import SwiftyJSON

// create an instance for each person the user messages
struct Messages {
    let name : String
    let last_message : String
    let chat_id : String
}

class MessagesController: UITableViewController {
    
    // Standards
    let defaults = UserDefaults.standard
    
    // create an array of all messages
    var all_chats = [Messages]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
    }
    
    // refreshes the table every time you come back to the page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadMessages()
        self.tableView.reloadData()
    }

    // load message history
    func loadMessages() {

        // get username for API call
        let username = defaults.string(forKey: "username")!
        let user: User = User(username: username)

        // make API call to retrieve all messages
        AF.request("https://spot-backend-api.herokuapp.com/fetchmessages",
                   method: .post,
                   parameters: user,
                   encoder: JSONParameterEncoder.default).response { response in

                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int

                    let validRequest: Bool = (statusCode == 200)

                    if (validRequest == true) {
                        let all_messages = json["messages"]

                        self.parse_messages(all_messages)

                    } else {
                        print("Couldn't fetch messages")
                    }
        }
    }
    
    func parse_messages(_ json: JSON) {
        // for each message object, pull out the username of the person you are chatting with
        // and store it in an array --> show most recently created chats first
        for i in stride(from: json.count-1, through: 0, by: -1) {
            
            let username = json[i]["chatWith"].string!
            
            // set the last message to an empty string initially
            var message = ""
            
            // only get the last message if there are messages
            if (json[i]["messages"].count > 0){
                message = json[i]["messages"][json[i]["messages"].count - 1]["message"].string!
            }
            
            let mymessage = message
            
            let id = json[i]["chatId"].string!
                
            let chatwith = Messages(name: username, last_message: mymessage, chat_id: id)
                
            all_chats.append(chatwith)
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToChat") {
            // pass data to next view
            let next = segue.destination as? ChatViewController
            
            // Get the cell index that was tapped so we can use it to map to a chatID
            let indexPath = tableView.indexPathForSelectedRow
            let index = indexPath?.row
            
            // Map cell contents to a chat ID and pass through segue
            next!.chatID = all_chats[index!].chat_id
        }
    }
}

extension MessagesController {
    
    // Override basic table functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return all_chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageCell
        let chat = all_chats[indexPath.row]
        
        cell.configure(message: chat.last_message, name: chat.name)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User touched on \(indexPath) row")
        self.performSegue(withIdentifier: "ToChat", sender: self)
    }
}
