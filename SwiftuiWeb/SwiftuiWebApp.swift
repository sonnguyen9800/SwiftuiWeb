//
//  SwiftuiWebApp.swift
//  SwiftuiWeb
//
//  Created by Son, Nguyen Hoang on 1/8/21.
//

import SwiftUI

@main
struct SwiftuiWebApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
