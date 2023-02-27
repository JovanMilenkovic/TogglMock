//
//  ActivitiesView.swift
//  TogglMock
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import SwiftUI

struct ActivitiesView: View {
    @ObservedObject var store: ActivitiesViewStore

    var body: some View {
        ActivitiesContentView(
            activities: store.activities,
            update: { activity, description in
                Task { await store.update(activity: activity, newDescription: description) }
            },
            delete: { indexes in
                Task { await store.delete(at: indexes) }
            }
        )
        .task { await store.load() }
        .alert(
            "Error",
            isPresented: .init(get: { store.error != nil }, set: { _ in store.error = nil }),
            actions: { EmptyView() },
            message: { Text("Something went wrong") }
        )
    }
}

private struct ActivitiesContentView: View {
    let activities: [Activity]
    var update: (Activity, String) -> Void
    var delete: (IndexSet) -> Void

    var body: some View {
        List {
            ForEach(activities) { activity in
                activityView(activity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(8)
            }
            .onDelete(perform: delete)
            .listRowInsets(EdgeInsets.init(top: 4, leading: 0, bottom: 4, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    func activityView(_ activity: Activity) -> some View {
        HStack {
            if let description = activity.description {
                Text(description)
            } else {
                DescriptionInputView { description in self.update(activity, description) }
            }

            VStack(alignment: .trailing, spacing: 0) {
                Text(DateFormatter.dateTimeFormatter.string(from: activity.date))
                    .font(.system(size: 10))
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Spacer()

                Text(DateFormatter.secondsFormatter.string(from: activity.duration) ?? "")
            }
        }
    }
}

private struct DescriptionInputView: View {
    @FocusState var isFocused
    @State private var text = ""

    let onUpdate: (String) -> Void

    var body: some View {
        TextField("Add description", text: $text)
            .focused($isFocused)
            .onChange(of: isFocused) { [isFocused] newValue in
                guard isFocused, !newValue else { return }
                onUpdate(text)
            }
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesContentView(
            activities: [
                Activity(id: UUID(), description: nil, duration: 3, date: Date()),
                Activity(id: UUID(), description: "short and simple", duration: 3, date: Date(timeIntervalSinceNow: -200)),
                Activity(id: UUID(), description: "long description long description long description long description long description long description ", duration: 3, date: Date(timeIntervalSinceNow: 200)),
            ],
            update: { _, _ in },
            delete: { _ in }
        )
    }
}
