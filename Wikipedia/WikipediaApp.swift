//
//  WikipediaApp.swift
//  Wikipedia
//
//  Created by Henry Lunger (student LM) on 12/14/22.
//

import SwiftUI
import WikipediaKit

@main
struct WikipediaApp: App {
    
    init() {
        WikipediaNetworking.appAuthorEmailForAPI = "henry.lunger@gmail.com"
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {   
        WindowGroup {
            ContentView()
        }
    }
}
