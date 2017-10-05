//
//  QuoteViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/18/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController, UITextFieldDelegate {
    // name item storyboard
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var infoTweetUIview: UIView!
    @IBOutlet weak var accNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var heightphoto: NSLayoutConstraint!
    @IBOutlet weak var lengthTextUILabel: UILabel!
    @IBOutlet weak var quoteUIButton: UIButton!
    var maxLengthText: Int = 140
    
    var tweet: Tweet!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTweet(tweet: tweet)
        commentTextField.delegate = self
        self.quoteUIButton.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.commentTextField = textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        self.maxLengthText = 140 - newLength
        self.lengthTextUILabel.text = String(describing: self.maxLengthText)
        
        if self.maxLengthText < 20 {
            self.lengthTextUILabel.textColor = .red
        }
        
        if self.maxLengthText < 0 || self.maxLengthText == 140 {
            self.quoteUIButton.isEnabled = false
        } else {
            self.quoteUIButton.isEnabled = true
        }
        
        return true
    }
    
    func loadTweet(tweet: Tweet) {
        self.infoTweetUIview.layer.borderWidth = 0.3
        self.infoTweetUIview.layer.borderColor = UIColor.darkGray.cgColor
        self.infoTweetUIview.layer.cornerRadius =  5
        self.heightphoto.constant = 0
        self.photoImageView.isHidden = true
        if tweet.is_quote_status {
            
        } else {
            self.accNameLabel.text = tweet.user.name
            self.screenNameLabel.text = "@\(tweet.user.screen_name)"
            self.tweetLabel.text = tweet.text
            if let image_url = tweet.imageURL {
                self.photoImageView.isHidden = false
                self.heightphoto.constant = 100
                self.photoImageView.roundCorners([.bottomLeft,.bottomRight], radius: 5)
                self.photoImageView.sd_setImage(with: image_url, placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            }
            
        }
        
    }
    
    @IBAction func quoteTweet(_ sender: UIButton) {
        if let text = self.commentTextField.text {
            let tweet_web_url = "https://twitter.com/\(self.tweet.user.screen_name)/status/\(self.tweet.id)"
            let comment = text + " " + tweet_web_url
            let url = TwitterAPI.TwitterUrl(method: .POST, path: .statuses_update , twitterUrl: .api , parameters: ["status": comment])
            TwitterAPI.postNewTweet(url: url, result: { (data) in
                if let timelineViewController = self.storyboard?.instantiateViewController(withIdentifier: "Timeline") as? TimeLineTableViewController {
                    timelineViewController.tweets.insert(data, at: 0)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.newTweet = data
                    self.navigationController?.popViewController(animated: true)
                }
                
            }, error: { (err) in
                print(err)
            })
        }
    }
}
