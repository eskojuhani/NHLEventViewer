//
//  EventsView.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 11/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Cocoa

class EventsView: NSView {
    var delegate: EventDelegate? = nil { didSet { } }
    
    @IBOutlet weak var scheduledGames: NSTableView!
    @IBOutlet weak var gameEvents: NSTableView!
    @IBOutlet weak var dateField: NSDatePicker!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func itemSelected(_ sender: Any) {
        let index = scheduledGames.selectedRow
        if (index > -1) {
            delegate?.gameSelected(index: index)
        }
    }
    
    @IBAction func fetchSchedule(_ sender: Any) {
        
        let date = dateField.dateValue
        let interval = dateField.timeInterval
        let endDate: Date = Date(timeInterval: interval, since: date)
        
        delegate?.daysSelected(start: date, end: endDate)
    }
}
