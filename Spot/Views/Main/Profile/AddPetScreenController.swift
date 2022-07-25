//
//  AddPetScreenController.swift
//  Spot
//
//  Created by Matthew Swartz on 11/3/21.
//

import UIKit
import SwiftyJSON
import Alamofire

struct Pet: Encodable {
    let username: String
    let petName: String
    let isFound: Bool
    let typePet: String
    let petBreed: String
    let imgLink: String
}

class AddPetScreenController: UIViewController {
    
    // Standards
    let defaults = UserDefaults.standard

    @IBOutlet weak var petNameField: UITextField!
    @IBOutlet weak var petBreedField: UITextField!
    @IBOutlet weak var petTypeControl: UISegmentedControl!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var pictureButton: UIButton!
    
    let uploader = Uploader()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func changePictureButton(_ sender: Any) {
        showImagePickerOptions()
    }
    
    func imagePick(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        return picker
    }
    
    func showImagePickerOptions() {
        let alertVC = UIAlertController(title: "Show us your pet", message: "Pick from library or camera", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            let cameraImagePicker = self.imagePick(sourceType: .camera)
            cameraImagePicker.delegate = self
            self.present(cameraImagePicker, animated: true) {}
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            let libraryImagePicker = self.imagePick(sourceType: .photoLibrary)
            libraryImagePicker.delegate = self
            self.present(libraryImagePicker, animated: true) {}
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func addNewPet(_ sender: Any) {
        
        uploader.uploadImage(compressImage(image: imagePicker.image!)) { link, fileName in
    
            // Make POST request using Alamofire
            let petName: String = self.petNameField.text!
            let petBreed: String = self.petBreedField.text!
            let petType: String =  (self.petTypeControl.selectedSegmentIndex == 0) ? "Dog" : "Cat"

            if (petName.isEmpty || petBreed.isEmpty) {
                self.feedbackLabel.textColor = .red
                self.feedbackLabel.text = "Please fill out all fields."
            } else {
                let user = self.defaults.string(forKey: "username")!
                let pet: Pet = Pet(username: user, petName: petName, isFound: true, typePet: petType, petBreed: petBreed, imgLink: "https://sessions-images.s3.amazonaws.com/" + fileName)
                
                AF.request("https://spot-backend-api.herokuapp.com/addpet",
                           method: .post,
                           parameters: pet,
                           encoder: JSONParameterEncoder.default).response { response in
                            let json = JSON(response.value!!)
                            let statusCode = json["status"].int
                            
                            let addedPetSuccess: Bool = (statusCode == 200)
                    
                            if (addedPetSuccess) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.feedbackLabel.text = "User does not exist."
                            }
                }
            }
        
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddPetScreenController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.imagePicker.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
