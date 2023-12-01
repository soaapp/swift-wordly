//
//  ContentView.swift
//  WordlyWatch Watch App
//
//  Created by Jay Jahanzad on 2023-11-27.
//

import SwiftUI
import Foundation
import LoremSwiftum

struct ContentView: View {
    @State private var results = [DictionaryWord]()
    @State private var wordOfDay = "swift"
    let freeDictionaryURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    
    var body: some View {
        NavigationView {
            VStack{
                // Application title and description
                Text("Wordly")
                    .font(.custom("Flavors-Regular", size: 50))
            }
            .foregroundColor(Color("mainPurple"))
            
            List(results) { item in
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.word)
                            .font(.largeTitle)
                            .foregroundColor(Color("mainPurple"))
                        Button {
                            refresh()
                            print("Refresh button clicked")
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color("mainPurple"))
                        }
                    }
                    
                    ForEach(item.phonetics) { phone in
                        if phone.text != nil && phone.sourceURL != nil {
                            Text(phone.text!)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                    }
                    
                    ForEach(item.meanings) { means in
                        ForEach(means.definitions) { def in
                            Text("‣  " + def.definition)
                            Spacer()
                        }
                        if means.partOfSpeech != nil {
                            Text(means.partOfSpeech)
                                .fontWeight(.bold)
                            Divider()
                        }
                    }
                }
            }
            .task {
                // Fetch data when the view is loaded
                refresh()
            }
        }
    }
    
    func refresh() {
        print("Refreshing data...")
        
        Task {
            await loadData()
            print("Word refreshed")
        }
    }
    
    // Function to fetch data from the dictionary API
    func loadData() async {
        
        if check() {
            // update wordOfDay from custom extension of the LoremSwiftum package. Package is local.
            // TODO: Find a way to test in sim daily update.
            wordOfDay = Lorem.realWord
        } else {
            // TODO: Remove wordOfDay setter here. USED FOR TESTING ONLY
            wordOfDay = Lorem.realWord
            print(wordOfDay)
        }
        
        print("Word refreshed")
        print(wordOfDay)
        
        let url = URL(string: "\(freeDictionaryURL)\(wordOfDay)")!
        do {
            // Fetch data from the API
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Try to decode the JSON data into an array of DictionaryWord objects
                do {
                    let decoded: [DictionaryWord] = try JSONDecoder().decode([DictionaryWord].self, from: data)
                    
                    if !decoded.isEmpty {
                        // Update the results state variable
                        results = decoded
                    } else {
                        // Handle when DictionaryAPI doesn't have any details about word
                        print("Invalid data received from API. Trying another word.")
                        await loadData()
                    }
                } catch let decodingError {
                    // Handle decoding error
                    print("Decoding error: \(decodingError)")
                    
                    // Try to decode the JSON data into an error response
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        // Check if the error response indicates "No Definitions Found"
                        if errorResponse.title == "No Definitions Found" {
                            print("No definitions found for the word. Using another word.")
                            await loadData()
                        }
                    }
                }
            } else {
                print("Error in API response. Refreshing word.")
                await loadData()
            }
            
        } catch {
            print("Error: \(error)")
            await loadData()
        }
    }
    
    func check() -> Bool {
        if let referenceDate = UserDefaults.standard.object(forKey: "reference") as? Date {
            if !Calendar.current.isDateInToday(referenceDate) {
                UserDefaults.standard.set(Date(), forKey: "reference")
                return true
            }
        } else {
            UserDefaults.standard.set(Date(), forKey: "reference")
            return true
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Model structure for a dictionary word
struct DictionaryWord: Identifiable, Codable {
    let id = UUID()
    
    var word: String
    var phonetics: [Phonetic]
    var meanings: [Meaning]
    var license: License
    var sourceUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case word, phonetics, meanings, license, sourceUrls
    }
}

struct License: Identifiable, Codable {
    let id = UUID()
    let name: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
}

struct Meaning: Identifiable, Codable {
    let id = UUID()
    
    let partOfSpeech: String
    let definitions: [Definition]
    let synonyms, antonyms: [String]?
    
    enum CodingKeys: String, CodingKey {
        case partOfSpeech, definitions, synonyms, antonyms
    }
}

struct Definition: Identifiable, Codable {
    let id = UUID()
    
    let definition: String
    let synonyms, antonyms: [String]?
    let example: String?
    
    enum CodingKeys: String, CodingKey {
        case definition, example, synonyms, antonyms
    }
}

struct Phonetic: Identifiable, Codable {
    let id = UUID()
    
    let audio: String
    let sourceURL: String?
    let license: License?
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case audio
        case sourceURL = "sourceUrl"
        case license, text
    }
}

struct ErrorResponse: Decodable {
    let title: String
    let message: String
    let resolution: String
}
