//
//  ContentView.swift
//  Wordly
//
//  Created by Jay on 2023-08-09.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    // State variable to hold the fetched dictionary results
    @State private var results = [DictionaryWord]()
    
    var body: some View {
        VStack {
            VStack{
                // Application title and description
                Text("Wordly")
                    .fontDesign(.rounded)
                    .font(.title)
                Text("Get a new word everyday!")
            }
            .foregroundColor(.purple)
            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            
            // List view to display dictionary results
            List(results) { item in
                VStack(alignment: .leading) {
                    Text(item.word).font(.headline)
                        .foregroundColor(.purple)
                    
                    // Display phonetics information
                    ForEach(item.phonetics) { phone in
                        if phone.text != nil && phone.sourceURL != nil {
                            Text(phone.text!)
//                            Text(phone.sourceURL!)
                        }
                    }
                    // Display meanings information
                    ForEach(item.meanings) { means in
                        ForEach(means.definitions) { def in
                            Text(def.definition)
                        }
                        // Display part of speech if available
                        if means.partOfSpeech != nil {
                            Text(means.partOfSpeech)
                        }
                    }
                }
            }
        }
        .task {
            // Fetch data when the view is loaded
            await loadData()
        }
    }
    
    // Default word of the day testing purposes
    let wordOfDay = "funny"
    // API URL for fetching dictionary data
    var freeDictionaryURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    
    // Function to fetch data from the dictionary API
    func loadData() async {
        let url = URL(string: "\(freeDictionaryURL)\(wordOfDay)")!
        do {
            // Fetch data from the API
            let (data, _) = try await URLSession.shared.data(from: url)
            // Decode the JSON data into an array of DictionaryWord objects
            let decoded: [DictionaryWord] = try JSONDecoder().decode([DictionaryWord].self, from: data)
            // Update the results state variable
            results = decoded
        } catch {
            print(error)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Model structure for a dictionary word
struct DictionaryWord: Identifiable, Codable {    // <--- here
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

struct Phonetic: Identifiable, Codable {    // <--- here
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
