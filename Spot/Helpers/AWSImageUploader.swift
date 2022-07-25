import UIKit
import AWSS3

// Image Uploader
// Progress block which tells how much data has been uploaded
typealias progressBlock = (_ progress: Double) -> Void
// Completion block whcih executes when uploading finish
typealias completionBlock = (_ response: Any?, _ fileName: String, _ error: Error?) -> Void

class AWSS3Manager {
    
    static let shared = AWSS3Manager()
    private init () { }
    let bucketName = "sessions-images"
    
    // Upload image using UIImage object
    func uploadImage(image: UIImage, progress: progressBlock?, completion: completionBlock?) {
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            let error = NSError(domain: "", code: 402,
                                userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, "", error)
            return
        }
        
        let tmpPath = NSTemporaryDirectory() as String
        let fileName: String = ProcessInfo.processInfo.globallyUniqueString + (".jpeg")
        let filePath = tmpPath + "/" + fileName
        let fileUrl = URL(fileURLWithPath: filePath)
        
        do {
            try imageData.write(to: fileUrl)
            self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: "image", progress: progress, completion: completion)
        } catch {
            let error = NSError(domain: "", code: 402,
                                userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, "", error)
        }
    }
    
    // Get unique file name
    func getUniqueFileName(fileUrl: URL) -> String {
        let strExt: String = "." + (URL(fileURLWithPath: fileUrl.absoluteString).pathExtension)
        return (ProcessInfo.processInfo.globallyUniqueString + (strExt))
    }
    
    // MARK:- AWS file upload
    // fileUrl :  file local path url
    // fileName : name of file, like "myimage.jpeg"
    // contenType: file MIME type
    // progress: file upload progress, value from 0 to 1, 1.0 for 100% complete
    // completion: completion block when uplaoding is finish, you will get S3 url of upload file here
    private func uploadfile(fileUrl: URL, fileName: String,
                            contenType: String, progress: progressBlock?,
                            completion: completionBlock?) {
        
        // Upload progress block
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, awsProgress) in
            guard let uploadProgress = progress else { return }
            DispatchQueue.main.async {
                uploadProgress(awsProgress.fractionCompleted)
            }
        }
        
        // Completion block
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error == nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(self.bucketName).appendingPathComponent(fileName)
//                    print("Uploaded to: \(String(describing: publicURL))")
                    if let completionBlock = completion {
                        completionBlock(publicURL?.absoluteString, fileName as String, nil)
                    }
                } else {
                    if let completionBlock = completion {
                        completionBlock(nil, "", error)
                    }
                }
            })
        }
        
        // Start uploading using AWSS3TransferUtility
        let awsTransferUtility = AWSS3TransferUtility.default()
        awsTransferUtility.uploadFile(fileUrl, bucket: bucketName, key: fileName,
                                      contentType: contenType, expression: expression,
                                      completionHandler: completionHandler)
            .continueWith { (task) -> Any? in
            if let error = task.error {
                print("error is: \(error.localizedDescription)")
            }
            if let _ = task.result {
                // your uploadTask
            }
            return nil
        }
    }
    
    /// Used to delete images -> Given the URL of the image link, it will be deleted
    func deleteObject(_ fileName: String) {
        let s3 = AWSS3.default()
        guard let deleteObjectRequest = AWSS3DeleteObjectRequest() else {
            return
        }
        
        deleteObjectRequest.bucket = "sessions-image"
        deleteObjectRequest.key = fileName
        s3.deleteObject(deleteObjectRequest).continueWith { (task: AWSTask) -> AnyObject? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            print("Deleted successfully.")
            return nil
            
        }
    }
}

class Uploader {
    
    var progress: Float = 0.0
    
    func uploadImage(_ pickedImage: UIImage?, completion: @escaping (String, String) -> Void) {
        guard let image = pickedImage else { return }
            AWSS3Manager.shared.uploadImage(image: image, progress: {[weak self] ( uploadProgress) in
                
                guard let strongSelf = self else { return }
                // Used to see the speed of the upload + guess how large the file is
                strongSelf.progress = Float(uploadProgress)
//                print(uploadProgress)
                
            }) {[weak self] (uploadedFileUrl, fileName, error) in
                
                guard self != nil else { return }
                if let finalPath = uploadedFileUrl as? String {
                    completion(String(describing: finalPath), String(describing: fileName))
                    
                } else {
                    print("\(String(describing: error?.localizedDescription))")
                    completion("", "")
                }
            }
    }
}
