//
//  ContentsViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 20..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit


class ContentsViewController: UITableViewController, XMLParserDelegate {

    var book = Book()
    
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    
    var contentTitle = String()
    var contentKey = String()
   
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
       
        posts = []
        
        
        let xml = "\(book.homeDir)/audios/list.xml"
        
        print("xml :" + xml)
        
        parser = XMLParser(contentsOf:URL(fileURLWithPath: xml))!
        
        parser.delegate = self
        parser.parse()
        
    }
    
    //XMLParser Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "item")
        {
            elements = NSMutableDictionary()
            elements = [:]
            contentTitle = String()
            contentTitle = ""
            
            
            contentKey = attributeDict["key"]! as String
           
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqual(to: "item") {
            if !contentTitle.isEqual(nil) {
                elements.setObject(contentTitle, forKey: "title" as NSCopying)
            }
            if !contentKey.isEqual(nil) {
                elements.setObject(contentKey, forKey: "key" as NSCopying)
            }
            posts.add(elements)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if element.isEqual(to: "title") {
            contentTitle.append(string)
        } else if element.isEqual(to: "key") {
            contentKey.append(string)
        }
    }
    
    //Tableview Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("posts count : \(posts.count)")
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let content:NSMutableDictionary = posts.object(at: indexPath.row) as! NSMutableDictionary
        
        cell.textLabel?.text = content.object(forKey: "title") as! String?
        
        print("key : \(content.object(forKey: "key"))")
            
        //cell?.authorLabel.text = book.author
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "show" {
            if let readBookViewController = segue.destination as? ReadBookViewController {
                
                let indexPath = self.tableView.indexPathForSelectedRow
                //print(" indexPath  "+self.books[(indexPath?.row)!].bookId)
                //bookInfoViewController.book = self.books[(indexPath?.row)!]
                
                readBookViewController.book = book
            }
        }
    }
    
    
}
