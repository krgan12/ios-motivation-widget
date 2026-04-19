//
//  QuotesWidget.swift
//  QuotesWidget
//
//  Created by Keagan Rodrigues on 2026-04-04.
//

import WidgetKit
import SwiftUI

struct RandomQuoteEntry: TimelineEntry {
    let date: Date
    let randomQuote: RandomQuote
}

struct RandomQuoteProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> RandomQuoteEntry {
        RandomQuoteEntry(date: Date(), randomQuote: RandomQuote(id: 0, quote: "Loading..."))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RandomQuoteEntry) -> Void) {
        let entry = RandomQuoteEntry(date: Date(), randomQuote: RandomQuote(id: 0, quote: "Stay motivated."))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RandomQuoteEntry>) -> Void) {
        guard let url = URL(string: "https://server-x0p7.onrender.com/quotes") else {
            fallbackTimeline(completion: completion)
            return
        }
        
        URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let data = data {
                do {
                    let quotes = try JSONDecoder().decode([RandomQuote].self, from: data)
                    
                    let random = quotes.randomElement() ?? RandomQuote(id: 0, quote: "No quotes available.")
                    
                    let entry = RandomQuoteEntry(date: Date(), randomQuote: random)
                    
                    let nextUpdate = Date().addingTimeInterval(86400)
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                    
                    completion(timeline)
                }
                catch {
                    fallbackTimeline(completion: completion)
                }
            }
            else {
                fallbackTimeline(completion: completion)
            }
        }
        .resume()
    }
    
    func fallbackTimeline(completion: @escaping (Timeline<RandomQuoteEntry>) -> Void) {
        let fallbackQuote = RandomQuote(id: 0, quote: "Stay strong, Keep moving forward.")
        
        let entry = RandomQuoteEntry(date: Date(), randomQuote: fallbackQuote)
        
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(86400)))
        
        completion(timeline)
    }
}

struct RandomQuoteWidgetEntryView: View {
    var entry: RandomQuoteProvider.Entry
    
    @ViewBuilder
    var body: some View {
        
        let content = VStack {
            Text("Quote of the day: ")
                .font(.system(size: 15))
                .bold()
            Text(entry.randomQuote.quote)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
//                .padding(4)
        }
        
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            content.containerBackground(for: .widget) {
                Color.clear
            }
        }
        else {
            content.background(Color.clear)
        }
    }
}


struct RandomQuoteWidget: Widget {
    
    let kind: String = "RandomQuoteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomQuoteProvider()) {
            entry in
            
            let base = RandomQuoteWidgetEntryView(entry: entry)
            
            if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
                base.containerBackground(for: .widget) {
                    Color.clear
                }
            }
            else {
                base.background(Color.clear)
            }
        }
        
        .configurationDisplayName("Random Quote of the day")
        .description("Get some motivation in your life!")
        
        #if os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium])
        #elseif os(macOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        #endif
    }
}
