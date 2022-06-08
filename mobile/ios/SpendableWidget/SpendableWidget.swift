//
//  SpendableWidget.swift
//  SpendableWidget
//
//  Created by Michael St Clair on 12/2/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    createEntry(configuration: ConfigurationIntent())
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    completion(createEntry(configuration: configuration))
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let entries: [SimpleEntry] = [createEntry(configuration: configuration)]
    
    let timeline = Timeline(entries: entries, policy: .never)
    completion(timeline)
  }
  
  func createEntry(configuration: ConfigurationIntent) -> SimpleEntry {
    let spendable = UserDefaults(suiteName: "group.fiftysevenmedia")!.string(forKey: "spendable")
    return SimpleEntry(date: Date(), configuration: configuration, spendable: spendable ?? "$0.00")
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let spendable: String
}

struct SpendableWidgetEntryView : View {
  var entry: Provider.Entry
  
  var body: some View {
    ZStack {
      Color(red: 0, green: 116 / 255, blue: 217 / 255).edgesIgnoringSafeArea(.all)
      
      VStack{
        Text(entry.spendable)
          .font(.title)
          .minimumScaleFactor(0.2)
          .scaledToFit()
        Text("Spendable").font(.footnote)
      }
      .foregroundColor(.white)
      .padding()
    }
  }
}

@main
struct SpendableWidget: Widget {
  let kind: String = "SpendableWidget"
  
  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
      SpendableWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Spendable")
  }
}

struct SpendableWidget_Previews: PreviewProvider {
  static var previews: some View {
    SpendableWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), spendable: "$1,000,000.00"))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
