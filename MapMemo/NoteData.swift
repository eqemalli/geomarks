//
//  NoteData.swift
//  MapMemo
//
//  Created by Enxhi Qemalli on 23.4.24.
//

import Foundation

class NoteData {
    static let shared = NoteData()
    
    private let userDefaults = UserDefaults.standard
    private let notesKey = "notes"
    
    func saveNotes(notes: [Note]) {
        let encodedData = try? JSONEncoder().encode(notes)
        userDefaults.set(encodedData, forKey: notesKey)
    }
    
    func loadNotes() -> [Note] {
        guard let encodedData = userDefaults.data(forKey: notesKey),
              let notes = try? JSONDecoder().decode([Note].self, from: encodedData) else {
            return []
        }
        return notes
    }
    
    func deleteNote(noteId: String) {
        var existingNotes = loadNotes()
        existingNotes.removeAll(where: { $0.id == noteId })
        saveNotes(notes: existingNotes)
    }
    
    @discardableResult
    func createNewNote(title: String, content: String, latitude: Double, longitude: Double, date: Date) -> Note {
        let noteId = UUID().uuidString
        let newNote = Note(id: noteId, title: title, content: content, latitude: latitude, longitude: longitude, date: date)
        
        var existingNotes = loadNotes()
        existingNotes.append(newNote)
        saveNotes(notes: existingNotes)
        
        return newNote
    }
    
    func editNote(noteId: String, title: String, content: String, latitude: Double, longitude: Double, date: Date) {
            var existingNotes = loadNotes()
            if let index = existingNotes.firstIndex(where: { $0.id == noteId }) {
                existingNotes[index].title = title
                existingNotes[index].content = content
                existingNotes[index].latitude = latitude
                existingNotes[index].longitude = longitude
                existingNotes[index].date = date
                saveNotes(notes: existingNotes)
            }
        }
}
