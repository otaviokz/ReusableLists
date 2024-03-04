//
//  ReusableListsWidget.swift
//  ReusableListsWidget
//
//  Created by Otávio Zabaleta on 04/03/2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), lists: getLists())
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), lists: getLists())
        completion(entry)
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [SimpleEntry(date: .now, lists: getLists())], policy: .after(.now.addingTimeInterval(60 * 5)))
        completion(timeline)
    }
    
    @MainActor private func getLists() -> [ToDoList] {
        guard let modelContainer = try? ModelContainer(for: ToDoList.self) else {
            return []
        }
        let descriptor = FetchDescriptor<ToDoList>()
        let lists = try? modelContainer.mainContext.fetch(descriptor)
        return lists ?? []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let lists: [ToDoList]
}

struct ReusableListsWidgetEntryView : View {
    static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Reusable Lists")
                .padding(.bottom, 16)
            
            HStack {
                Text("\(entry.lists.count)")
                Text("Lists")
                Spacer()
            }
            .padding(.horizontal, 8)
            
            HStack(spacing: 0) {
                Gauge(value: entry.lists.averageCompletion, in: 0...100) {
                    Text("\(Self.numberFormatter.string(from: NSNumber(value: entry.lists.averageCompletion)) ?? "0")%")
                        .font(.body)
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .scaleEffect(CGSize(width: 0.5, height: 0.5))
                .tint(.cyan)
                .padding(.leading, -12)
                Text("Completion")
                    .font(.footnote)
                Spacer()
            }
//            .padding(.horizontal, 8)
            
//            Text(entry.date, style: .time)

//            Text("Emoji:")
//            Text(entry.emoji)
        }
    }
}

private extension Array where Element == ToDoList {
    var averageCompletion: Double {
        let totalCompletion: Double = reduce(0.0) {
            $0 + $1.completion
        }
        return (totalCompletion / Double(count)) * 100
    }
}

struct ReusableListsWidget: Widget {
    let kind: String = "ReusableListsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ReusableListsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ReusableListsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
    
}

#Preview(as: .systemSmall) {
    ReusableListsWidget()
} timeline: {
    SimpleEntry(date: .now, lists: [])
    SimpleEntry(date: .now, lists: [])
}
