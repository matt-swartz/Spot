//
//  ChatViewController.swift
//  Spot
//
//  Created by Jin Kim on 12/3/21.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChatViewController : UIViewController {
    
    // Standards
    let defaults = UserDefaults.standard
    
    struct Chat {
        let sender : String
        let message : String
    }
    
    struct MessageToSend: Encodable{
        let sender : String
        let message : String
        let chatId : String
    }
    
    var all_chats = [Messages]()
    var chat_log = [Chat]()
    var chatID: String?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var responseField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMessages()
        
        // set the row height
        self.tableView.rowHeight = 80.0
        
        //sendButton.titleLabel?.isHidden=true
        
        tableView.delegate = self
        tableView.dataSource = self
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
                        print("Couldn't fetch messages -- maybe use an alert here?")
                    }
        }
    }
    
    var chatWith = ""
    func parse_messages(_ json: JSON) {
        // for each message object, pull out the username of the person you are chatting with
        // and store it in an array
        for i in 0 ..< json.count {
            if (json[i]["chatId"].string! == chatID){
                chatWith = json[i]["chatWith"].string!
                for chat in json[i]["messages"]{
                    let mess_sender = chat.1["username"].string!
                    let themessage = chat.1["message"].string!
                    
                    let chatlog = Chat(sender: mess_sender, message: themessage)
                    chat_log.append(chatlog)
                    
                }
                tableView.reloadData()
                autoScrollToBottom()
                return
            }
        }
        tableView.reloadData()
        autoScrollToBottom()
    }
    
    // automatically go to the bottom of the message list
    func autoScrollToBottom(){
        // set the row and section you want to be at (last cell, and there is only one section)
        let index = IndexPath(row: self.chat_log.count-1, section: 0)
        
        // as long as there somehthing there, scroll to the bottom
        if (index.row >= 0) {
            // use the tableView method scrollToRow to automatically set the chat window to show
            // the most recent messages
            /*
             see documentation: https://developer.apple.com/documentation/uikit/uitableview/1614997-scrolltorow
             */
            self.tableView.scrollToRow(at: index, at: .bottom, animated: false)
        }
    }
    
    @IBAction func sendMessagePressed(_ sender: Any) {
        // get the text from the chat bar
        let messagetosend = responseField.text!
        
        // if the message isn't empty
        if (!messagetosend.isEmpty) {
            // get user information
            let username = defaults.string(forKey: "username")!
            
            // format the message to send
            let tosend = MessageToSend(sender: username, message: messagetosend, chatId: chatID!)
            
            // post the message
            AF.request("https://spot-backend-api.herokuapp.com/sendmessage",
                       method: .post,
                       parameters: tosend,
                       encoder: JSONParameterEncoder.default).response { [self] response in
                        let json = JSON(response.value!!)
                        let statusCode = json["status"].int
                        
                        let updateSuccess: Bool = (statusCode == 200)
                
                         //if the message is sent successfully, add it to the list of chats that we have, reload the data, and set the input box back to 0
                        if (updateSuccess) {
                            let append_chat = Chat(sender: username, message: messagetosend)
                            self.chat_log.append(append_chat)
                            
                            
                            self.responseField.text = ""
                            
                            let messagelog = Messages(name: self.chatWith, last_message: messagetosend, chat_id: self.chatID!)
                            self.all_chats.append(messagelog)
                            
                            self.tableView.reloadData()
                            self.autoScrollToBottom()
                            
                            print("Sent!")
                        } else {
                            print("Message failed to send.")
                        }
                }
        }
    }
}

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat_log.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // configure all the cells that store the chat log
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageCell
        let chat = chat_log[indexPath.row]
        cell.configure(message: chat.message, name: chat.sender)
        return cell
    }
}

// LEAVE THIS EMPTY
extension ChatViewController : UITableViewDelegate {
    
}
