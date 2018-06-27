//
//  ViewController.swift
//  Voter
//
//  Created by Alexander Fox on 6/20/18.
//  Copyright © 2018 Alexander Fox. All rights reserved.
//

import UIKit
import LocalAuthentication
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var topLogo: WKWebView!
    @IBOutlet weak var bottomLogo: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let topPath: String = Bundle.main.path(forResource: "ballot_box-blue", ofType: "svg")!
        let topUrl: NSURL = NSURL.fileURL(withPath: topPath) as NSURL
        let topRequest: NSURLRequest = NSURLRequest(url: topUrl as URL)
        topLogo.load(topRequest as URLRequest)
        let bottomPath: String = Bundle.main.path(forResource: "usagov-logo", ofType: "png")!
        let bottomURL: NSURL = NSURL.fileURL(withPath: bottomPath) as NSURL
        let bottomRequest: NSURLRequest = NSURLRequest(url: bottomURL as URL)
        bottomLogo.load(bottomRequest as URLRequest)
        //bioLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func bioLogin() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [unowned self] success, authenticationError in
                    
                    DispatchQueue.main.async {
                        if success {
                            self.allowVoting(username: "", password: "")
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(ac, animated: true)
                            self.bioLogin()
                        }
                    }
                }
            } else {
                let ac = UIAlertController(title: "Outdated Device", message: "Your device is not configured for Touch or Face ID.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                bioLogin()
            }
    }

    func allowVoting(username: String,password: String) {
        let params = ["username":username, "password":password] as Dictionary<String, String>
        let url = "https://www.vote.gov/"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
            } catch {
                print("error")
            }
        })
        
        task.resume()
    }
    
}

