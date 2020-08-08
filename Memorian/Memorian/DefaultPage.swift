//
//  DefaultPage.swift
//  Memorian
//
//  Created by Che Blankenship on 8/5/20.
//  Copyright © 2020 Che Blankenship. All rights reserved.
//

import SwiftUI

// Instructions
struct Instructions: Identifiable {
    var id: Int
    var script: String
    var img: String
}



struct DefaultPage: View {
    
    let instructionList = [
        Instructions(id: 1, script: "Open 'System Perference'.", img: "system_preference_icon"),
        Instructions(id: 2, script: "Go to 'Security & Privacy'.", img: "security_privacy_icon"),
        Instructions(id: 3, script: "Choose 'Privacy'.", img: "privacy_location_icon"),
        Instructions(id: 4, script: "Choose 'Accesibility' from the list. Add Memorian to the list.", img: "accesibility_icon"),
        Instructions(id: 5, script: "Click the lock icon located at bottom left, and unlock with your password.", img: "keylock_icon"),
        Instructions(id: 6, script: "Click the '+' icon to add Memorian. Make sure the checkbox is selected.", img: "plus_sign_icon"),
        Instructions(id: 7, script: "Lock the settings by clicking the lock icon.", img: "keylock_icon"),
        Instructions(id: 8, script: "Restart the app by closing it and opening it.", img: "close_btn_icon")
    ]
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    Spacer(minLength: 20) // Extra space between header and first row.
                    VStack{
                        Text("⚠️ This app requires keyboard access to detect keyboard shortcuts such as ⌘+C and ⌘+X.\nYou can click the button below to go to the instruction website. See the steps of how to enable the accessibility for Memorian.")
                        .foregroundColor(Color.init(red: 250/255, green: 248/255, blue: 247/255))
                        .frame(width: 370, height: 100, alignment: .center)
                        .background(Color.init(red: 177/255, green: 40/255, blue: 47/255))
                        .cornerRadius(5)
                        .padding(.bottom)
                        
                        Button(action: {
                            self.openUrl()
                        }) {
                            Text("Go to instruction page")
                            .foregroundColor(Color.init(red: 250/255, green: 248/255, blue: 247/255))
                            .frame(width: 300, height: 30, alignment: .center)
                            .background(Color.init(red: 9/255, green: 132/255, blue: 255/255))
                            .cornerRadius(5)
                            .padding(.bottom)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
//                        ForEach(instructionList) { step in
//                            VStack{
//                                Text("Step \(String(step.id))")
//                                .foregroundColor(Color.init(red: 250/255, green: 248/255, blue: 247/255))
//                                .frame(width: 370, height: 40, alignment: .center)
//                                .background(Color.init(red: 36/255, green: 36/255, blue: 36/255))
//                                .cornerRadius(5)
//                                .padding(.bottom, 2)
//
//                                Text("\(String(step.script))")
//                                .foregroundColor(Color.init(red: 250/255, green: 248/255, blue: 247/255))
//                                .frame(width: 370, height: 40, alignment: .center)
//                                .background(Color.init(red: 46/255, green: 46/255, blue: 46/255))
//                                .cornerRadius(5)
//
//                                Image("\(String(step.img))")
//
//                            }
//                            .frame(width: 380, height: 200, alignment: .center)
//                            .background(Color.init(red: 50/255, green: 50/255, blue: 50/255))
//                            .cornerRadius(10)
//                            .padding()
//
//                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }.background(Color.init(red: 36/255, green: 36/255, blue: 36/255))
    }
}

struct DefaultPage_Previews: PreviewProvider {
    static var previews: some View {
        DefaultPage()
    }
}


extension DefaultPage {
    
    // Redirect the user to Customer support page. Web page that shows how to allow accessibility.
    func openUrl() {
        let url = URL(string: "http://memorian_support.surge.sh/")!
        if NSWorkspace.shared.open(url) {
            print("Learn more page is launched.")
            print("default browser was successfully opened")

        }
    }

}
