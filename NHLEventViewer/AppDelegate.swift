//
//  AppDelegate.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 11/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: NSView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let viewController = EventsViewController()
        self.view.addSubview(viewController.view)
        viewController.view.frame = self.window.contentView!.bounds
        
        //readJsonFile(filename: "livefeed")
        //readJsonFile(filename: "schedule")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func readJsonFile(filename: String) {
        let str = "2018-11-15T01:00:00Z"
        let fmt = "yyyy-MM-dd'T'HH:mm:ssZ"
        let gmtTS:Date = str.toDate(format: fmt)!
        print(gmtTS, gmtTS.adding(minutes: -6 * 60))
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                //decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                let schedule = try decoder.decode(ScheduleFeed.self, from: data)
                print(schedule)
                //let livefeed = try decoder.decode(Schedule.self, from: data)
                //print(livefeed.liveData.plays)
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
    }
}

