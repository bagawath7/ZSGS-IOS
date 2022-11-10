//
//  MessageContractor.swift
//  Arattai-IOS
//
//  Created by zs-mac-4 on 26/10/22.
//

import Foundation

protocol MessagePresentationLogic:AnyObject{
    func attemptToAssembleGroupedMessages()
}

class MessagePresenter:MessagePresentationLogic{
    weak var viewcontroller:MessageDisplayLogic!
    
    var chatMessages:[[ChatMessage]] = [[]]
    let messagesFromServer = [
            ChatMessage(text: "Here's my very first message", isIncoming: true, date: Date.dateFromCustomString(customString: "08/03/2018")),
            ChatMessage(text: "I'm going to message another long message that will word wrap", isIncoming: true, date: Date.dateFromCustomString(customString: "08/03/2018")),
            ChatMessage(text: "I'm going to message another long message that will word wrap, I'm going to message another long message that will word wrap, I'm going to message another long message that will word wrap", isIncoming: false, date: Date.dateFromCustomString(customString: "09/15/2018")),
            ChatMessage(text: "Yo, dawg, Whaddup!", isIncoming: false, date: Date()),
            ChatMessage(text: "This message should appear on the left with a white background bubble", isIncoming: true, date: Date.dateFromCustomString(customString: "09/15/2018")),
            ChatMessage(text: "Third Section message", isIncoming: true, date: Date.dateFromCustomString(customString: "10/31/2018"))
        ]
        
       
        
         func attemptToAssembleGroupedMessages() {
            print("Attempt to group our messages together based on Date property")
            
            let groupedMessages = Dictionary(grouping: messagesFromServer) { (element) -> Date in
                return element.date.reduceToMonthDayYear()
            }
            
            // provide a sorting for your keys somehow
            let sortedKeys = groupedMessages.keys.sorted()
            sortedKeys.forEach { (key) in
                let values = groupedMessages[key]
                chatMessages.append(values ?? [])
            }
             viewcontroller.displayMessages(viewmodel: chatMessages)
            
        }
        
        
        
    
    
    
}


extension Date {
    static func dateFromCustomString(customString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: customString) ?? Date()
        
        
    }
    func reduceToMonthDayYear() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.date(from: "\(month)/\(day)/\(year)") ?? Date()
}
}
