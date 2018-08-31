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
    
    var clientTokenOrTokenizationKey = "sandbox_jzgw4n4x_z68vm2n954m3r2yz"
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
                
            } else if let nonce = result?.paymentMethod?.nonce {
                let description = result?.paymentMethod?.localizedDescription
                let type = result?.paymentMethod?.type
                self.showOrderView(book: self.book, nonce: nonce, type: type, description: description)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func showOrderView(book: Book?, nonce: String, type: String?, description: String?) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BookOrderViewController") as! BookOrderViewController
        
        viewController.book = book
        viewController.nonce = nonce
        viewController.pay_type = type
        viewController.pay_description = description
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func show(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
