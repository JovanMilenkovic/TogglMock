//
//  ActivityCreationView.swift
//  TogglMock
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import SwiftUI
import Combine

struct ActivityCreationView: View {
    @ObservedObject var store: ActivityCreationViewStore

    var body: some View {
        ActivityCreationContentView(
            description: $store.description,
            time: store.time,
            playAction: store.toggleTimer
        )
    }
}

private struct ActivityCreationContentView: View {
    @Binding var description: String
    @FocusState private var isFocused

    let time: String?
    var playAction: () -> Void

    var body: some View {
        VStack {
            time.map(Text.init)?.font(.title)

            HStack {
                inputField
                playButton
            }
        }
    }

    private var inputField: some View {
        TextField("I'm working on...", text: $description)
            .focused($isFocused)
            .padding()
            .overlay(Capsule().stroke())
    }

    private var playButton: some View {
        Button(action: {
            isFocused = false
            playAction()
        }) {
            Image(systemName: time == nil ? "play.circle" : "stop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 40)
                .foregroundColor(.pink)
        }
    }
}

struct ActivityCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCreationContentView(description: .constant(""), time: "0:00:00", playAction: {})
        ActivityCreationContentView(description: .constant(""), time: nil, playAction: {})
    }
}
