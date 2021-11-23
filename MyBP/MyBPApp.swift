//
//  MyBPApp.swift
//  MyBP
//
//  Created by Faiz Luqman on 23/11/2021.
//

import SwiftUI

@main
struct MyBPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
