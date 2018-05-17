//
//  ViewController.swift
//  BookShopper
//
//  Created by Harrison Chin on 5/15/18.
//  Copyright © 2018 TaqTIk Health. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableViewBooks: UITableView!
    
    var allBooks:[Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable self sizing cells
        self.tableViewBooks.dataSource = self
        self.tableViewBooks.delegate = self
//        self.tableViewBooks.estimatedRowHeight = 120
//        self.tableViewBooks.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view, typically from a nib.
        if let url = URL(string: "https://lab.taqtik.com/api/books") {
            Alamofire.request(url)
                .responseJSON { response in
                    guard response.result.isSuccess,
                        let value = response.result.value else {
                            print("Error while fetching tags: \(String(describing: response.result.error))")
                            return
                    }
                    let books = JSON(value).array?.map { json in
                        Book(id: json["_id"].stringValue,
                                   title: json["title"].stringValue,
                                   author: Author(id: JSON(json["author"].rawValue)["_id"].stringValue,
                                                  family_name: JSON(json["author"].rawValue)["family_name"].stringValue,
                                                  first_name: JSON(json["author"].rawValue)["first_name"].stringValue,
                                                  date_of_birth: JSON(json["author"].rawValue)["date_of_birth"].stringValue))
                    }
//                    for curBook in books! {
//                        print(curBook)
//                        self.allBooks.append(curBook)
//                    }
//                    print(books)
                    self.allBooks = books!
                    DispatchQueue.main.async {
                        self.tableViewBooks.reloadData()
                    }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! BookTableViewCell
        
        cell.labelBookName?.text = self.allBooks[indexPath.row].title
        cell.labelAuthorName?.text = self.allBooks[indexPath.row].author.first_name + " " + self.allBooks[indexPath.row].author.family_name
        cell.accessoryType = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

