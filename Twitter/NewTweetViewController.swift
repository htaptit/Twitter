//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/12/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterCore
import TwitterKit
class NewTweetViewController: UIViewController, UITextFieldDelegate , UITableViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTweet(_ sender: UIButton) {
        let url = TwitterAPI.TwitterUrl(method: .POST, path: .statuses_update, parameters: ["status" : newTweetLabel.text!])
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (result) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.newTweet = result
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        }) { (error) in
            print(error)
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        // Why not use dissmis
    }
}
