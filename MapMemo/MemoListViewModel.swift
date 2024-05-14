//
//  MemoListViewModel.swift
//  MapMemo
//
//  Created by Enxhi Qemalli on 23.4.24.
//

import Foundation

class MemoListViewModel {
    private var notes: [Note] = []

    var noteCount: Int {
        return notes.count
    }

    func loadNotes() -> [Note] {
        notes = NoteData.shared.loadNotes()
       return notes
    }

}
