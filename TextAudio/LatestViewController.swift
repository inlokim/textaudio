//
//  LatestViewController.swift
//  TextAudioBooks
//
//  Created by 김인로 on 2017. 4. 14..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit
import SDWebImage
import StoreKit

class LatestViewController: UITableViewController, XMLParserDelegate {
    
    
    //MARK: Properties
    
    let baseUrl = "http://inlokim.com/textAudioBooks/list.php"
    
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) as UIActivityIndicatorView
    
    var books:[Book] = []
    //var booksCount:Int = 0
    
    var eName: String = String()
    
    var bookId:String = String()
    var bookTitle:String = String()
    var author:String = String()
    var time:String = String()
    var size:String = String()
    var preview:String = String()
    var full:String = String()
    var content:String = String()
    var image:String = String()
    
    //XML
    var parser = XMLParser()
    var element = NSString()
    
    //Purchase
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        actInd.center = (self.parent?.view.center)!
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        parent?.view.addSubview(actInd)
        
        getDataFromURL()
        
        
/*      
        //SKProduct
        
        products = []
        
        for book in books
        {
            let productId = "kr.co.highwill.TextAudioBooks.\(book.bookId)"
            TextAudioProducts.productIdentifiers.insert(productId)

        }
        
        print("TextAudioProducts.productIdentifiers.count : \(TextAudioProducts.productIdentifiers.count)")
        
        TextAudioProducts.store.requestProducts { success, products in
            
            if success
            {
                print("success")
                self.products = products!
                
            }
        }
 */
 
 
    }
    

    
    func getDataFromURL()
    {
        self.runActivity()

        parser = XMLParser(contentsOf:(URL(string:baseUrl))!)!
        parser.delegate = self
        parser.parse()
        
        
        tableView.reloadData()
        self.stopActivity()
    }
    
    
    func runActivity() {
        actInd.startAnimating()
    }
    
    
    func stopActivity() {
        actInd.stopAnimating()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //XMLParser Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        eName = elementName
        if elementName == "entry" {
            bookId = String()
            bookTitle = String()
            author = String()
            time = String()
            size = String()
            preview = String()
            full = String()
            content = String()
            image = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "entry" {
            
            let book = Book()
            book.bookId = bookId
            book.title = bookTitle
            book.author = author
            book.content = content
            book.time = time
            book.size = size
            book.preview = preview
            book.full = full
            book.image = image
            
            books.append(book)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if eName == "tab_title" {
                bookTitle += data
            } else if eName == "tab_author" {
                author += data
            }
            else if eName == "tab_id" {
                bookId += data
            }
            else if eName == "tab_content" {
                content += data
            }
            else if eName == "tab_time" {
                time += data
            }
            else if eName == "tab_size" {
                size += data
            }
            else if eName == "tab_preview" {
                preview += data
            }
            else if eName == "tab_full" {
                full += data
            }
            else if eName == "tab_image" {
                image += data
            }
        }
    }

    //Tableview Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BookTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookTableViewCell
        
        let book = books[indexPath.row]
        
        cell?.titleLabel.text = book.title
        cell?.authorLabel.text = book.author
        
        //print("content : [\(book.content)]")
        
        let book_id :String = book.bookId
        let coverUrl :String = "http://inlokim.com/textAudioBooks/images/s_\(book_id).png"
        
        cell?.bookCover.sd_setImage(with: URL(string: coverUrl))
        cell?.bookCover = Util.imageViewBorder((cell?.bookCover)!)
        
        //product
        
       // print("products count : \(products.count)")
        
       // let product = products[(indexPath as NSIndexPath).row]
       // book.price = Util.priceFormatter.string(from: product.price)!
                
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "show" {
            if let bookInfoViewController = segue.destination as? BookInfoViewController {
                
                let indexPath = self.tableView.indexPathForSelectedRow
                //print(" indexPath  "+self.books[(indexPath?.row)!].bookId)
                bookInfoViewController.book = self.books[(indexPath?.row)!]
            }
        }
    }
}


