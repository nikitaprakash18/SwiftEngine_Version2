//
//  ViewController.swift
//  AlamofireWithSwiftyJSON
//
//  Created by Nikita on 10/26/17.
//  Copyright © 2017 Nikita. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MessageUI
class viewcell:UITableViewCell{
    
    /* IBOutlet for email, topic and message*/
    
    @IBOutlet weak var email_IBoutlet: UILabel!
    @IBOutlet weak var topic_iboutlet: UILabel!
    @IBOutlet weak var message: UILabel!
    
}


class ViewController: UIViewController, MFMailComposeViewControllerDelegate  {

    @IBOutlet var tblJSON: UITableView!
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var email_String : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }

        /* Alamofire.request we will use it to get data from it via Alamofire.*/
        
        Alamofire.request("http://nikitamessagingboard.site.swiftengine.net/inc_functions.ssp").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["topicArray"].arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
                }
                if self.arrRes.count > 0 {
                    self.tblJSON.reloadData()
                }
            }
        }
    }

    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        showGetUserName()
        
          }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell : viewcell = tableView.dequeueReusableCell(withIdentifier: "jsonCell") as! viewcell!
        var dict = arrRes[(indexPath as NSIndexPath).row]
       
      
        
        cell.topic_iboutlet?.text = dict["topic"] as? String
        cell.email_IBoutlet?.text = dict["email"] as? String
        cell.message?.text = dict["message"]as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showGetUserName() {
        
    let alertController = UIAlertController(title: "Welcome to My App!", message: "Please tell me message, topic and email_ID:", preferredStyle: .alert)
        
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Message"
            textField.textAlignment = .center
             //tex1 = textField.text!
        })
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "topic"
            textField.textAlignment = .center
        })
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Email"
            textField.textAlignment = .center
        })
        let okAction = UIAlertAction(
        title: "OK", style: UIAlertActionStyle.default) {
            (action) -> Void in
            
            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
           
            func isValidEmail(testStr:String) -> String? {
                // print("validate calendar: \(testStr)")
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                
                let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                if(emailTest.evaluate(with: alertController.textFields![2].text!)){
                    self.email_String = alertController.textFields![2].text!
                    return  alertController.textFields![2].text!}
                   else {
                    return ""
                        }
            }
            
            func isValidMessage(testStr:String) -> String? {

                let MessageRegEx = "[A-Z0-9a-z._%+-]"
                
                let MessageTest = NSPredicate(format:"SELF MATCHES %@", MessageRegEx)
                if(MessageTest.evaluate(with: alertController.textFields![0].text!)){
                    return  alertController.textFields![0].text!}
                else {
                    return ""
                }
               
            }

            func isValidTopic(testStr:String) -> String? {
                
                let TopicRegEx = "[A-Z0-9a-z._%+-]"
                
                let TopicTest = NSPredicate(format:"SELF MATCHES %@", TopicRegEx)
                if(TopicTest.evaluate(with: alertController.textFields![1].text!)){
                    return  alertController.textFields![1].text!
                }
                else {
                    return ""

                }
            }

            
            let parameter:[String:String] = [
                "message": alertController.textFields![0].text!,
                "topic":  alertController.textFields![1].text!,
                "email":isValidEmail(testStr: alertController.textFields![2].text!)!,
                            ]
           
            Alamofire.request("http://nikitamessagingboard.site.swiftengine.net/inc_functions.ssp",method: .post,parameters:parameter,encoding:JSONEncoding.default).responseJSON{response in
                
            }
            self.arrRes.append(parameter as [String : AnyObject])
            self.tblJSON.reloadData()
        }
        let cancelAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
           
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["nikitaprakash18@gmail.com"])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
   }





