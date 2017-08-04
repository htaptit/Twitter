//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/12/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
//import TwitterCore
import TwitterKit

class NewTweetViewController: UIViewController, UITextFieldDelegate , UITableViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageIDUploaded: String? = nil
    
    @IBOutlet weak var newTweetLabel: UITextField!
    @IBOutlet weak var numberTextLabel: UILabel!
    @IBOutlet weak var imageUploadedUIImageView: UIImageView!
    @IBOutlet weak var imageUploadedHeight: NSLayoutConstraint!
    var delegate: NewTweetViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTweetLabel.delegate = self
        imageUploadedUIImageView.isHidden = true
        imageUploadedHeight.constant = 0
        imageUploadedUIImageView.contentMode = .scaleAspectFill
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        newTweetLabel.text = textField.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func viewLibrary(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageUploadedUIImageView.isHidden = false
        imageUploadedHeight.constant = 150
        
        let imageSelected = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageUploadedUIImageView.image = imageSelected
        
        let imageData: Data? = UIImageJPEGRepresentation(imageSelected, 0.9)

        TwitterAPI.postNewImage(image: imageData, result: { (data) in
            if let id = data {
                self.imageIDUploaded = id
            }
        }) { (error) in
            print(error)
        }

        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTweet(_ sender: UIButton) {
        var params = [
            "status" : newTweetLabel.text!
        ]
        
        if imageIDUploaded != nil {
            params["media_ids"] = imageIDUploaded
        }
        
        let url = TwitterAPI.TwitterUrl(method: .POST, path: .statuses_update, twitterUrl: TwitterURL.api, parameters: params)
        TwitterAPI.postNewTweet(url: url, result: { (result) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.newTweet = result
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error)
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        // Why not use dissmis
    }
}
