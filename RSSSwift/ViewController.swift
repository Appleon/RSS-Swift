//
//  ViewController.swift
//  RSSSwift
//
//  Created by Muukii on 6/13/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate {
                            
    @IBOutlet var tableView : UITableView

    var entries : NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        entries = NSMutableArray()

        let url : NSURL = NSURL(string: "http://qiita.com/tags/Swift/feed.atom")
        let request : NSURLRequest = NSURLRequest(URL:url)
        func completionBlock(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void {
            var parser : NSXMLParser = NSXMLParser(data: data)
            parser.delegate = self;
            parser.parse()
        }
        var task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:completionBlock)
        task.resume()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // TableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        return 1;
    }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return self.entries.count;
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        var cell : TableViewCell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath) as TableViewCell
        let entry : Entry! = entries.objectAtIndex(indexPath.row) as Entry
        entry.toString()
        cell.textLabel.text = entry.title
        return cell
    }

    // NSXMLParserDelegate

    var entryFlag : Bool = false
    var titleFlag : Bool = false
    var linkFlag : Bool = false
    var urlFlag : Bool = false
    var currentEntry : Entry!

    let entryKey = "entry"
    let titleKey = "title"
    let urlKey   = "url"
    let linkKey  = "link"

    func parserDidStartDocument(parser: NSXMLParser!)
    {
        println("Parse Start")
    }
    func parser(parser: NSXMLParser!, foundElementDeclarationWithName elementName: String!, model: String!)
    {
        println(elementName)
    }
    func parser(parser: NSXMLParser!, foundInternalEntityDeclarationWithName name: String!, value: String!){
        println(value)
    }

    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!)
    {
        if elementName == entryKey {
            println("open \(elementName)")

            entryFlag = true
            currentEntry = Entry()
        } else if elementName == titleKey {
            titleFlag = true
            currentEntry = Entry()
        } else if elementName == linkKey{
            linkFlag = true
        } else if elementName == urlKey {
            urlFlag = true
        }
    }

    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if elementName == entryKey {
            println("close \(elementName)")

            entryFlag = false
            entries.addObject(currentEntry)
        } else if elementName == titleKey {
            titleFlag = false
        } else if elementName == linkKey {
            linkFlag = false
        } else if elementName == urlKey {
            urlFlag = false
        }
    }

    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
//        println(string)
        if entryFlag {
            if titleFlag {
                if string.isEmpty == false {
                    var tmpString : String? = currentEntry.title;

                    currentEntry.title = tmpString! + string
                }

            } else if linkFlag {
                currentEntry.link = string
            }
        }
    }

    func parserDidEndDocument(parser: NSXMLParser!)
    {
        println("Parse End　\(self.entries)")
        self.tableView.reloadData()
    }
}

