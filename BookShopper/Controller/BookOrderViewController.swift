//
//  OrderViewController.swift
//  BookShopper
//
//  Created by Harrison Chin on 6/8/18.
//  Copyright © 2018 TaqTIk Health. All rights reserved.
//

import UIKit

class BookOrderViewController: UIViewController {
    @IBOutlet weak var labelBookTitle: UILabel!
    @IBOutlet weak var labelBookAuthor: UILabel!
    @IBOutlet weak var labelBookPrice: UILabel!
    @IBOutlet weak var textFirstName: UITextField!
    @IBOutlet weak var textLastName: UITextField!
    @IBOutlet weak var textEmailAddress: UITextField!
    @IBOutlet weak var buttonPlaceOrder: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var book:Book?
    var nonce = ""
    var pay_type:String?
    var pay_description:String?
    
    var firstName = ""
    var lastName = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        
        self.textFirstName.placeholder = "John"
        self.textLastName.placeholder = "Doe"
        self.textEmailAddress.placeholder = "John.Doe@test.com"

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.firstName = appDelegate.userFirstName
        self.lastName = appDelegate.userLastName
        self.email = appDelegate.userEmail
        self.textFirstName.text = self.firstName
        self.textLastName.text = self.lastName
        self.textEmailAddress.text = self.email

        if let curBook = self.book {
            self.labelBookTitle.text = curBook.title
            self.labelBookAuthor.text = "Author: " + (curBook.author.first_name + " " + curBook.author.family_name)
            var paymentText =  String(format:"Pay $%@ by %@", curBook.price, self.pay_type!, self.pay_description!)
            if let payDescription = self.pay_description {
                paymentText = String(format:"%@ (%@)",paymentText,payDescription)
            }
            self.labelBookPrice.text = paymentText
        }
        
        addDoneButtonOnKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPlaceOrderClicked(_ sender: Any) {
        self.activityIndicator.startAnimating()
        let firstNameText = self.textFirstName.text!.trimmingCharacters(in: .whitespaces)
        self.firstName = firstNameText
        let lastNameText = self.textLastName.text!.trimmingCharacters(in: .whitespaces)
        self.lastName = lastNameText
        let emailText = self.textEmailAddress.text!.trimmingCharacters(in: .whitespaces)
        self.email = emailText
        let amount = self.book!.price
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.userFirstName = self.firstName
        appDelegate.userLastName = self.lastName
        appDelegate.userEmail = self.email
        appDelegate.saveUserProfile()
        
        buttonPlaceOrder.isEnabled = false
        self.sendRequestPaymentToServer(nonce: nonce, amount: amount, firstName: self.firstName, lastName: self.lastName, email: self.email)
    }
    
    
    func sendRequestPaymentToServer(nonce: String, amount: String, firstName: String, lastName: String, email: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let paymentURL = URL(string: appDelegate.webBaseURL + "braintreepay")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(nonce)&amount=\(amount)&firstName=\(firstName)&lastName=\(lastName)&email=\(email)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let data = data else {
                self?.show(message: error!.localizedDescription)
                return
            }
            
            let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
            print(string1)
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
                self?.show(message: "Transaction failed. Please try again.")
                return
            }
            self?.show(message: "Successfully charged. Thanks for shopping the books!")
            }.resume()
    }
    
    func show(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "OK", style: .default) { (_) -> Void in
                self.navigationController?.popViewController(animated: true)
                return
            }
            alertController.addAction(acceptAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK - Customize Keyboard toolbar
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(BookOrderViewController.doneButtonAction))
        
        var items:[UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.textFirstName.inputAccessoryView = doneToolbar
        self.textLastName.inputAccessoryView = doneToolbar
        self.textEmailAddress.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.textFirstName.resignFirstResponder()
        self.textLastName.resignFirstResponder()
        self.textEmailAddress.resignFirstResponder()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
