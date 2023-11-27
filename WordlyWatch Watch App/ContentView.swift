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
                    Text(item.word)
                        .font(.title)
                        .foregroundColor(Color("mainPurple"))
                    
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
            .onAppear {
                // Fetch data when the view is loaded
                loadData()
            }
        }
    }
    
    func loadData() {
        if check() {
            wordOfDay = Lorem.realWord
        } else {
            wordOfDay = "hello"
            print(wordOfDay)
        }
        
        if let url = URL(string: "\(freeDictionaryURL)\(wordOfDay)") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decoded = try JSONDecoder().decode([DictionaryWord].self, from: data)
                        DispatchQueue.main.async {
                            self.results = decoded
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
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
