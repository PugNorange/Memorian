//
//  ContentView.swift
//  Memorian
//
//  Created by Che Blankenship on 8/5/20.
//  Copyright © 2020 Che Blankenship. All rights reserved.
//

import SwiftUI
import RealmSwift
import Combine


class ItemEntity: Object, Identifiable {
    @objc dynamic var id: String = ""
    @objc dynamic var copiedContent: Data? = nil
    @objc dynamic var type: String? = nil
    @objc dynamic var date: Date = Date()
    
    override class func primaryKey() -> String? { "id" }
    override class func indexedProperties() -> [String] { ["id"] }
    
    
    //file:///Users/cheb/Library/Containers/com.proto.Memorian/Data/Library/Application%20Support/default.realm
    private static var realm = try! Realm()
    
    static func setUp() {
        try! realm.write {
            print("### update \(Date())")
            //realm.deleteAll()
            let item = ItemEntity()
            item.id = String(UUID().uuidString)
            item.copiedContent = Data(base64Encoded: "test making copyyyyy contentview.swift line 33")
            item.type = "text"
            item.date = Date()
            
            realm.add(item, update: .modified)
        }
    }

    
    
    static func all() -> Results<ItemEntity> {
        realm.objects(ItemEntity.self).sorted(byKeyPath: "date", ascending: false)
    }
    
}

class ClipBoard: ObservableObject {
    var objectWillChange: ObservableObjectPublisher = .init()
    private(set) var itemEntities: Results<ItemEntity> = ItemEntity.all()
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        notificationTokens.append(itemEntities.observe { _ in
            self.objectWillChange.send()
        })
    }
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}




// Main UI page
struct ContentView: View {
    
    // Monitor changes. If there is any change to the object, it will sync with the frontend.
    @EnvironmentObject private var clipBoard: ClipBoard
    
    var body: some View {
        
        NavigationView{
            
            ZStack{
                
                ScrollView {
                    
                    // Add space 60 when adding header
                    Spacer(minLength: 20) // Extra space between header and first row.
                    
                    ForEach(clipBoard.itemEntities.self) { cp in
                        
                        VStack{
                            // Needs to be fixed
                            Text("\(String(data: cp.copiedContent!, encoding: .utf8) ?? "Invalid data type. not type string...")")
                            //.lineLimit(1)
                            .foregroundColor(Color.init(red: 190/255, green: 190/255, blue: 190/255))
                            .frame(width: 370, height: 40, alignment: .center)
                            .background(Color.init(red: 36/255, green: 36/255, blue: 36/255))
                            .cornerRadius(5)
                            .padding(.bottom)
                            
                            HStack (alignment: .center, spacing: 5){
                                
                                // Show copied date.
                                Text("\(self.dateToString(date: cp.date))")
                                    .foregroundColor(Color.init(red: 190/255, green: 190/255, blue: 190/255))
                                    .frame(width: 120, height: 30, alignment: .center)
                                    .background(Color.init(red: 36/255, green: 36/255, blue: 36/255))
                                    .cornerRadius(5)

                                // Re-copy button.
                                Button(action: {
                                    self.reCopy(reCopyContent: Data(cp.copiedContent!))
                                }){
                                    Text("Copy")
                                    .frame(width: 120, height: 30, alignment: .center)
                                    .background(Color.init(red: 41/255, green: 86/255, blue: 76/255))
                                    .foregroundColor(Color.init(red: 190/255, green: 190/255, blue: 190/255))
                                    .cornerRadius(5)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Delete content button.
                                Button(action: {
                                    self.deleteSelectedData(contentId: cp.id)
                                }){
                                    Text("Delete")
                                    .frame(width: 120, height: 30, alignment: .center)
                                    .background(Color.init(red: 115/255, green: 38/255, blue: 40/255))
                                    .foregroundColor(Color.init(red: 190/255, green: 190/255, blue: 190/255))
                                    .cornerRadius(5)
                                }
                                .buttonStyle(PlainButtonStyle())
                            
                            }
                        
                        }
                        .frame(width: 380, height: 100, alignment: .center)
                        .background(Color.init(red: 46/255, green: 46/255, blue: 46/255))
                        .cornerRadius(10)
                        .padding()
                    
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                }
                
//                // Add Header to ZStack
//                HStack {
//
//                    Text("Clipboard History").bold().foregroundColor(Color.init(red: 148/255, green: 148/255, blue: 148/255))
//                        .padding(.leading, 25)
//
//                    Spacer()
//
//                    // Add setting button later on.
//                    // Button(action: {
//                    //    print("refresh clicked")
//                    // }){
//                    //    Text("Refresh")
//                    //    .frame(width: 120, height: 30, alignment: .center)
//                    //    .background(Color.init(red: 157/255, green: 92/255, blue: 44/255))
//                    //    .foregroundColor(Color.black)
//                    //    .cornerRadius(5)
//                    // }
//                    // .buttonStyle(PlainButtonStyle())
//                // .padding(20)
//                 }
//                 .frame(width: 420, height: 60, alignment: .center)
//                 .background(Color.init(red: 26/255, green: 26/255, blue: 26/255).opacity(0.9))
//                 .position(x: 205, y: 30)
                
            }
            
        }.background(Color.init(red: 36/255, green: 36/255, blue: 36/255))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




extension ContentView {
    

    
    // Copy selected clipboard content.
    fileprivate func reCopy(reCopyContent: Data) {
        let board = NSPasteboard.general
        board.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        board.setData(reCopyContent, forType: NSPasteboard.PasteboardType.string)
        let read = board.pasteboardItems?.first?.string(forType: .string)
        print("Copied data >> ", read!)
    }
    
    
    // Delete the data from realm db.
    fileprivate func deleteSelectedData(contentId: String) {
        // Get Realm DB path.
        let libraryPath = NSHomeDirectory() + "/Library/Application Support"
        let filePath =  NSURL(fileURLWithPath: libraryPath + "/default.realm")
        let realm = try! Realm(fileURL: filePath as URL)
        // Set realm DB data as list
        let queryData = realm.objects(ItemEntity.self).filter("id = '\(contentId)'")
        try! realm.write {
            realm.delete(queryData)
        }
    }
    
    
    // Convert type Date() to String()
    fileprivate func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let result = formatter.string(from: date)
        return result
    }
}
