/*
Vishnu Sreekanth

Cricket Scorekeeper

SheetDismissalManager.swift
 
Keeps track of whether sheet views are open. Has published variables so that 
the sheet views can be closed from anywhere when required.
*/

import Foundation

class SheetDismissalManager: ObservableObject {
    @Published var wicketsViewShowing = false
    @Published var widesViewShowing = false
    @Published var noBallViewShowing = false
    @Published var byesViewShowing = false
    @Published var legByesViewShowing = false
    @Published var nextBowlerViewShowing = false
    @Published var inningsSwitchViewShowing = false
    @Published var matchCompletedViewShowing = false
}
