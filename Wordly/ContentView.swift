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
                        .foregroundColor(.blue)
                    ForEach(item.phonetics) { phone in
                        if phone.text != nil && phone.sourceURL != nil {
                            Text(phone.text!)
                            Text(phone.sourceURL!)
                        }
                    }
                    ForEach(item.meanings) { means in
                        if means.partOfSpeech != nil {
                            Text(means.partOfSpeech!)
                        }
                    }
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    let freeDictionaryURL = "https://api.dictionaryapi.dev/api/v2/entries/en/funny"
    
    func loadData() async {
        guard let url = URL(string: freeDictionaryURL) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded: [DictionaryWord] = try JSONDecoder().decode([DictionaryWord].self, from: data)
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
