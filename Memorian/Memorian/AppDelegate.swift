//
//  AppDelegate.swift
//  Memorian
//
//  Created by Che Blankenship on 8/5/20.
//  Copyright © 2020 Che Blankenship. All rights reserved.
//

import Cocoa
import SwiftUI
import RealmSwift
import Foundation


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
                
        // 1. Check & allow "Security and Privacy".
        let checkAccesibilityResult = isAccessibilityEnabled(isPrompt: true);

        // 2. Show default page if accessibility is disabled. If accessibility is enabled, show clipboard history page.
        if checkAccesibilityResult == false {
            
            // Show an alert that informs user to enable accessibility.
             enableAccessibilityAlert()
            
            // Create the SwiftUI view that provides the window contents.
            let contentView = DefaultPage()
            // Create the window and set the content view.
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.contentView = NSHostingView(rootView: contentView)
            window.makeKeyAndOrderFront(nil)
            window.title = "Initial Setting Page"
            
        } else {
            // Create the SwiftUI view that provides the window contents.
            let contentView = ContentView().environmentObject(ClipBoard())

            // Create the window and set the content view.
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.contentView = NSHostingView(rootView: contentView)
            window.makeKeyAndOrderFront(nil)
            window.title = "Memorian | Clipboard History"
            
            // 3. Refresh the clipboard page to get the latest clipboard data.
            self.refreshClipboardHistory()
        }
        
        
        // Add copied data into the DB if cmd+c or cmd+x is detected.
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { (event) in
            if(event.keyCode == 8 || event.keyCode == 7) {
                print("cmd+c or cmd+x was pressed")
                self.refreshClipboardHistory()
            }
        }
        
        
    }

    
    // Window open/hide/close configuration
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}



// REALM related code.
extension AppDelegate {
    
//    This commented script is for updating realm file schema (ex, adding column etc). Necessary for the future db schema update.
//    fileprivate func copyRealm() -> String {
//        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
//        // If realm file exist, do not do anything
//        if FileManager.default.fileExists(atPath: defaultRealmPath.path) {
//            return "No realm DB file exsist"
//        }
//        let bundleRealmPath = Bundle.main.url(forResource: "default", withExtension: "realm")
//        do {
//            try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
//        } catch let error {
//            print("error copying realm file: \(error)")
//        }
//        return bundleRealmPath!.absoluteString
//    }
    
    
    // Refresh button will check your latest copied content and check if clipboard history should be updated.
    fileprivate func refreshClipboardHistory() {
        
        // Get Realm DB path.
        let libraryPath = NSHomeDirectory() + "/Library/Application Support"
        let filePath =  NSURL(fileURLWithPath: libraryPath + "/default.realm")
        let realm = try! Realm(fileURL: filePath as URL)
        
        // Set realm DB data as list. (going to use it for checking duplication)
        let queryData = Array(realm.objects(ItemEntity.self))
        print("realm db data >> ", queryData)
        // Get the whole clipboard content.
        guard let pasteboardItems = NSPasteboard.general.pasteboardItems else {
            return
        }
        
        // Loop through the clipboard content
        for pasteboardItem in pasteboardItems {
            // Loop though types
            for type in pasteboardItem.types {
                // Find type of utf8-plain or rtf
                if (type.rawValue == "public.utf8-plain-text") {
                    // If type is utf8-plain
                    if let data = pasteboardItem.data(forType: type) {
                        // Check if duplicate is found. if not, insert data into clipboard history.
                        var checkDuplicate = false
                        if queryData.count != 0 {
                            for i in 0..<queryData.count {
                                if ( String(data: data, encoding: .utf8) == String(data: queryData[i].copiedContent!, encoding: .utf8) ){
                                    checkDuplicate = true
                                }
                            }
                            // Check if duplicate is found. if not, insert data into clipboard history.
                            if(checkDuplicate == false) {
                                // Create object to store into DB
                                let item = ItemEntity()
                                item.id = String(UUID().uuidString)
                                item.copiedContent = Data(data)
                                item.type = "text"
                                try! realm.write {
                                    realm.add(item, update: .modified)
                                }
                            }
                            else {
                                print("Already exsist in clipboard history")
                                checkDuplicate = false
                            }
                        } else{
                            // Create object to store into DB
                            let item = ItemEntity()
                            item.id = String(UUID().uuidString)
                            item.copiedContent = Data(data)
                            item.type = "text"
                            try! realm.write {
                                realm.add(item, update: .modified)
                            }
                        }
                        
                    } else {
                        print("unsuccesful definision")
                    }
                } else {
                    print("Copied content is not a string or rich text format")
                }
            }
        }
    }
    
}


// ACCESSIBILITY related code.
extension AppDelegate {
    
    
//    func check() -> Bool {
//        let options = NSDictionary(
//            object: kCFBooleanTrue ?? true,
//            forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
//            ) as CFDictionary
//
//        print("CHECK option value >> ", options)
//        print("Check AXIs >> ", AXIsProcessTrustedWithOptions(options))
//        return AXIsProcessTrustedWithOptions(options)
//
//    }
    
    
    // Check keyboard accesibility permission.
    func isAccessibilityEnabled(isPrompt: Bool) -> Bool {
        /// Accessibility permission is required for paste command from macOS 10.14 Mojave.
        /// For macOS 10.14 and later only, check accessibility permission at startup and paste
        //guard #available(macOS 10.14, *) else { return true }
        let options = NSDictionary(object: kCFBooleanTrue ?? true, forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionary
        //let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString : isPrompt]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Access Not Enabled")
        } else{
            print("Able to access keyboard")
        }
        
        return accessEnabled
    }
    
    
    // Show an alert if accesibility is disabled.
    func enableAccessibilityAlert() {
        print("Show popup")
        let alert = NSAlert()
        alert.messageText = "\"Memorian.app\" whould like to control this computer using accessibility feature."
        alert.informativeText = "Grant access to this application in Security & Privacy preference, located in System Preferences."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Deny")
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Learn more")
        NSApp.activate(ignoringOtherApps: true)
        
        // Switch based on which button the user clicks
        let ret = alert.runModal()
        switch ret {
        case .alertFirstButtonReturn:
            print("Denied")
        case .alertSecondButtonReturn:
            openSystemPreferenceAccesibilityPrivacy()
        case .alertThirdButtonReturn:
            openUrl()
        default:
            print("Other:\(ret)")
        }
    }
    
    // Redirect the user to System Preference > Security & Privacy > [Privacy] > Accessibility
    func openSystemPreferenceAccesibilityPrivacy() {
        print("Go to System Preferences")
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    // Redirect the user to Customer support page. Web page that shows how to allow accessibility.
    func openUrl() {
        let url = URL(string: "http://memorian_support.surge.sh/")!
        if NSWorkspace.shared.open(url) {
            print("Learn more page is launched.")
            print("default browser was successfully opened")

        }
    }
}


