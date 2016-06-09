//
//  LyrebirdListStream.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/7/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//


public class LyrebirdStream {
    var finished: Bool = false
    
    public func reset() {
        finished = false
    }
}


public class LyrebirdListStream : LyrebirdStream {
    let list: [LyrebirdNumber]
    private (set) public var offset: LyrebirdInt
    private let listSize: LyrebirdInt
    private let initialOffset: LyrebirdInt
    
    public override func reset(){
        super.reset()
        offset = initialOffset
    }
    
    public init(list: [LyrebirdNumber] = [], offset: LyrebirdInt = 0){
        self.list = list
        self.offset = offset
        self.initialOffset = offset
        self.listSize = list.count
        super.init()
    }
    /*
    public override convenience init(){
        self.init(list: [], offset: 0)
    }
    */
    public func next() -> LyrebirdNumber? {
        if offset >= listSize {
            finished = true
            return nil
        }
        let returnValue = list[offset]
        offset = (offset + 1)
        return returnValue
    }
}

public class Sequence : LyrebirdListStream {
    
}

public class LyrebirdRepeatableListStream : LyrebirdListStream {
    let repeats: LyrebirdInt
    private var repetition: LyrebirdInt = 0
    
    public init(list: [LyrebirdNumber] = [], repeats: LyrebirdInt = 0, offset: LyrebirdInt = 0){
        self.repeats = repeats
        super.init(list: list, offset: offset)
    }
    
    public override func reset(){
        super.reset()
        repetition = 0
    }
    
    public override func next() -> LyrebirdNumber? {
        guard !finished else {
            return nil
        }
        if repetition > repeats {
            finished = true
            return nil
        }
        let returnValue = list[offset]
        offset = (offset + 1) % listSize
        if offset == initialOffset {
            repetition = repetition + 1
        }
        return returnValue
    }
}

public class LoopingSequence : LyrebirdRepeatableListStream {
    
}
