//
//  ContentView.swift
//  WordScramble
//
//  Created by Jordi Rivera Lizarralde on 7/7/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    // Properties to control the alert
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    // Property for score
    @State private var score = 0

    var body: some View {
        NavigationView {
            VStack {
                // Ask user to enter a word
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    // Make text field more appealing
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    // Do not autocapitalize word
                    .autocapitalization(.none)
                    .padding()
                // List of words
                List(usedWords, id: \.self) {
                    // Add lenght near the word with SF symbol
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Points: \(score)")
            }
            // Put rootWord as title of navigaiton bar
            .navigationBarTitle(rootWord)
            // Start Game
            .onAppear(perform: startGame)
            // Add button so user can get another word
            .navigationBarItems(trailing:
                // Calling function when using button
                Button(action: startGame) {
                    Text("Another Word")
                }
            )
            // Show alert
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    
    // Function that will:
    // 1) Lowercase newWord and remove any whitespace
    // 2) Check that it has at least 1 character otherwise exit
    // 3) Insert that word at position 0 in the usedWords array
    // 4) Set newWord back to be an empty string
    func addNewWord() {
        // 1)
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // 2)
        guard answer.count > 0 else {
            return
        }
        // Unwrapping with guard to check validity of word
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            // Substract points from user's score due to invalid word
            score -= answer.count
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            // Substract points from user's score due to invalid word
            score -= answer.count
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            // Substract points from user's score due to invalid word
            score -= answer.count
            return
        }
        // 3)
        usedWords.insert(answer, at: 0)
        
        // Modify user's score
        score += answer.count
        
        // 4)
        newWord = ""
    }
    
    // Function that will:
    // 1) Find start.txt in our bundle
    // 2) Load it into a string
    // 3) Split that string into array of strings, with each element being one word
    // 4) Pick one random word from there to be assigned to rootWord, or use a sensible default if the array is empty.
    func startGame() {
        // 1)
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2)
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3)
                let allwords = startWords.components(separatedBy: "\n")
                // 4)
                rootWord = allwords.randomElement() ?? "silkworm"
                usedWords = [String]()
                score = 0
                return
            }
        }
        // Throw error if file was not in bundle
        fatalError("Could not load start.txt from bundle.")
    }
    // Function that checks that the word hasn’t been used already
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    // Function that checks whether a random word can be made out of the letters from the rootWord
    func isPossible(word: String) -> Bool {
        // Create a variable copy of the root word
        var tempWord = rootWord
        
        // Loop over each letter of the user’s input word to see if that letter exists in our copy
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                // Remove letter from the copy so it can’t be used twice
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        // Check length of word
        if word.count < 3 {
            return false
        }
        // Check that word is not the original word
        if word == rootWord {
            return false
        }
        // Make an instance of UITextChecker, which is responsible for scanning strings for misspelled words.
        let checker = UITextChecker()
        
        // Create an NSRange to scan the entire length of our string
        let range = NSRange(location: 0, length: word.utf16.count)
        
        // Call rangeOfMisspelledWord() on our text checker so that it looks for wrong words
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        // If the word was OK the location for that range will be the special value NSNotFound.
        return misspelledRange.location == NSNotFound
    }
    // Function that sets the title and message based on the parameters it receives, then flips the showingError Boolean to true
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
