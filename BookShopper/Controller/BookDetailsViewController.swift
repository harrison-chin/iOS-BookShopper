//
//  BookDetailsViewController.swift
//  BookShopper
//
//  Created by Harrison Chin on 5/21/18.
//  Copyright © 2018 TaqTIk Health. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class BookDetailsViewController: UIViewController {
    @IBOutlet weak var labelBookTitle: UILabel!
    @IBOutlet weak var labelBookAuthor: UILabel!
    @IBOutlet weak var labelBookISBN: UILabel!
    @IBOutlet weak var labelBookPrice: UILabel!
    @IBOutlet weak var textViewBookDescription: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonCheckOut: UIButton!
    var book:Book?
    
    var clientTokenOrTokenizationKey = "{key}"
    var firstName = "John"
    var lastName = "Doe"
    var email = "John.Doe@test.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        
        if let curBook = self.book {
            labelBookTitle.text = curBook.title
            labelBookAuthor.text = "Author: " + (curBook.author.first_name + " " + curBook.author.family_name)
            labelBookISBN.text = "ISBN: " + curBook.isbn
            labelBookPrice.text = "Price: $" + curBook.price
            textViewBookDescription.text = "Summary:\n" + curBook.summary + "\n" + "(ID: " + curBook.id + ")"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonCheckOutClicked(_ sender: Any) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { [unowned self] (controller, result, error) in
            
            if let error = error {
                self.show(message: error.localizedDescription)
                
            } else if (result?.isCancelled == true) {
                self.show(message: "Transaction Cancelled")
                
            } else if let nonce = result?.paymentMethod?.nonce, let amount = self.book?.price {
                self.sendRequestPaymentToServer(nonce: nonce, amount: amount, firstName: self.firstName, lastName: self.lastName, email: self.email)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func sendRequestPaymentToServer(nonce: String, amount: String, firstName: String, lastName: String, email: String) {
        activityIndicator.startAnimating()
        
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
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
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
