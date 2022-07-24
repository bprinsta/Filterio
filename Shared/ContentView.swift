//
//  ContentView.swift
//  Shared
//
//  Created by Benjamin Musoke-Lubega on 7/23/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
        }
        .preferredColorScheme(.dark)
        .environment(\.sizeCategory, .accessibilityLarge)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
