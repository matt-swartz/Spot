//
//  NewChatController.swift
//  Spot
//
//  Created by rachel.okeefe on 12/3/21.
//

import UIKit
import SwiftyJSON
import Alamofire

class NewChatController : UIViewController {
    
    // Standards
    let defaults = UserDefaults.standard
    
    struct ChatData: Encodable {
        let sender : String
        let receiver : String
    }
    
    struct MessageToSend: Encodable{
        let sender : String
        let message : String
        let chatId : String
    }
    
    // connect all aspects of the view to this code file
    @IBOutlet var tableView: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var recipientField: UITextField!
    @IBOutlet var messageField: UITextField!
    @IBOutlet var statusIndicator: UILabel!
    @IBOutlet weak var showChatWindow: UIButton!
    
    // if the showChatButton is clicked, go to the chat controller
    @IBAction func showChat(_ sender: Any) {
        performSegue(withIdentifier: "showChatWindow", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipientField.placeholder = "Enter a username."
        messageField.placeholder = "Enter a message."
        
        // hide button by default
        showChatWindow.isHidden = true
        
        sendButton.titleLabel?.isHidden=true
        
    }
    
    @IBAction func sendMessageClicked(_ sender: UIButton) {
        createChat()
    }
    
    var chat_id = ""
    
    func createChat() {
        // get the username of the person we want to send a message to and the message
        // we want to send to them from the correct fields
        let messagetosend = messageField.text!
        let recipient = recipientField.text!
        
        // assuming neither field is empty
        if (!messagetosend.isEmpty && !recipient.isEmpty){
            
            // get the current user's information
            let username = defaults.string(forKey: "username")!
            
            // format the data needed to create the chat
            let chat_info = ChatData(sender: username, receiver: recipient)
            
            // post the message
            AF.request("https://spot-backend-api.herokuapp.com/createchat",
                       method: .post,
                       parameters: chat_info,
                       encoder: JSONParameterEncoder.default).response { response in
                        let json = JSON(response.value!!)
                        let statusCode = json["status"].int
                        
                        let updateSuccess: Bool = (statusCode == 200)
                
                        // if we successfully created a chat
                        if (updateSuccess) {
                            // format the status label
                            self.statusIndicator.textColor = UIColor.systemGreen
                            self.statusIndicator.text = "Chat created!"
                            self.statusIndicator.textAlignment = .center
                            print("Chat created!")
                            
                            // since we know the chat was created correctly, a chat id is returned
                            let chatID = json["chatId"].string
                            self.chat_id = json["chatId"].string!
                            
                            // send a message
                            self.sendMessage(chatID: chatID!, username: username, message_content: messagetosend)
                            
                            // show the button that takes us to the next window
                            self.showChatWindow.isHidden = false
                            
                        } else {
                            let errorMessage = json["errorMessage"]
                            print(errorMessage)
                            self.statusIndicator.textColor = UIColor.red
                            self.statusIndicator.textAlignment = .center
                            self.statusIndicator.text = "Error: " + errorMessage.string!
                            print("Failure to create chat.")
                            
                        }
                }
        }
    }
    
    // function to send a message that takes a chatID,
    func sendMessage(chatID: String, username: String, message_content: String){
        
        // format the message object
        let tosend = MessageToSend(sender: username, message: message_content, chatId: chatID)
        
        // post the message
        AF.request("https://spot-backend-api.herokuapp.com/sendmessage",
                   method: .post,
                   parameters: tosend,
                   encoder: JSONParameterEncoder.default).response { response in
                    let json = JSON(response.value!!)
                    let statusCode = json["status"].int
                    
                    let updateSuccess: Bool = (statusCode == 200)
            
                    // if the message is sent successfully, add it to the list of chats
                    // that we have, reload the data, and set the input box back to 0
                    if (updateSuccess) {
                        print("Chat sent!")
                        self.messageField.text = ""
                        
                    } else {
                        print("Message failed to send.")
                    }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showChatWindow") {
            // pass data to next view
            let next = segue.destination as? ChatViewController
            
            // Map cell contents to a chat ID and pass through segue
            next!.chatID = chat_id
        }
    }
}
