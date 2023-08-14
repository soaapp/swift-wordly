//
//  ContentView.swift
//  Wordly
//
//  Created by Jay on 2023-08-09.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var results = [DictionaryWord]()
    
    var body: some View {
        VStack {
            Text("Wordly - Get a new word daily!")
            List(results) { item in
                VStack(alignment: .leading) {
                    Text(item.word).font(.headline)
                    ForEach(item.phonetics) { phone in    // <--- here
                        if phone.text != nil {
                            Text(phone.text!)
                        }
                    }
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    let freeDictionaryURL = "https://api.dictionaryapi.dev/api/v2/entries/en/hello"
    
    func loadData() async {
        guard let url = URL(string: freeDictionaryURL) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // --- here
            let decoded: [DictionaryWord] = try JSONDecoder().decode([DictionaryWord].self, from: data)
            results = decoded
        } catch {
            print(error)  // <--- important
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DictionaryWord: Identifiable, Codable {    // <--- here
    let id = UUID()
    
    let word: String
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    let license: License
    let sourceUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case word, phonetics, meanings, license, sourceUrls
    }
}

struct License: Codable {
    let name: String
    let url: String
}

struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]
    let synonyms, antonyms: [String]?
}

struct Definition: Codable {
    let definition: String
    let synonyms, antonyms: [String]?
    let example: String?
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
