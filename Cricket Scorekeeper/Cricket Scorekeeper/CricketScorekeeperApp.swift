/*
Vishnu Sreekanth

Cricket Scorekeeper

CricketScorekeeperApp.swift
 
Primary Swift file for the app, displays MainView when the app is opened.
*/

import SwiftUI

@main
struct CricketScorekeeperApp: App {
    @StateObject private var dataController = DataController.shared
    @StateObject private var sheetManager = SheetDismissalManager()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(sheetManager)
        }
    }
}
