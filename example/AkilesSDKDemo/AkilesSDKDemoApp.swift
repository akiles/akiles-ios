//
//  AkilesSDKDemoApp.swift
//  AkilesSDKDemo
//
//  Created by Ulf Lilleengen on 30/05/2025.
//

import SwiftUI
import AkilesSDK

@available(iOS 14.0, *)
@main
struct AkilesSDKDemoApp: App {
    let akiles = Akiles()
    var body: some Scene {
        WindowGroup {
            ContentView(akiles: akiles)
        }
    }
}
