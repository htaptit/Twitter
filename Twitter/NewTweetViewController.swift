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
class NewTweetViewController: UIViewController, UITextFieldDelegate , UITableViewDelegate {

    @IBOutlet weak var newTweetLabel: UITextField!
    @IBOutlet weak var numberTextLabel: UILabel!
    var delegate: NewTweetViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTweetLabel.delegate = self
        // Do any additional setup after loading the view.
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
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func postTweet(_ sender: UIButton) {
//        let delegate = self.storyboard?.instantiateViewController(withIdentifier: "timeline") as? TimelineControllerViewController
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
//        dismiss(animated: true, completion: nil)
    }
}

//protocol NewTweetProtocol {
//    var tweet: [TwitterData]
////    func initTweet(tweet: TwitterData)
//}
