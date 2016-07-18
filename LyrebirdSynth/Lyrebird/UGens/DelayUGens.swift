//
//  DelayUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 7/16/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public enum DelayInterpolationType {
    case None, Linear, Cubic
}

public class DelayLine: LyrebirdUGen {
    private var buffer: [LyrebirdFloat]
    private let bufferSize: LyrebirdInt // should be a power of 2
    private let mask: LyrebirdInt
    private var readHead: LyrebirdFloat = 0.0
    private var writeHead: LyrebirdInt = 0
    public var interpolation: DelayInterpolationType
    public var delayTime: LyrebirdValidUGenInput
    private var lastDelayTime: LyrebirdFloat = 0.0
    public var input: LyrebirdValidUGenInput
    
    
    public required init(rate: LyrebirdUGenRate,  input: LyrebirdValidUGenInput, delayTime: LyrebirdValidUGenInput, maxDelayTime: LyrebirdFloat = 1.0, interpolation: DelayInterpolationType = .None) {
        self.input = input
        self.delayTime = delayTime
        self.interpolation = interpolation
        self.bufferSize = LyrebirdInt(nextPowerOfTwo(LyrebirdInt(ceil(LyrebirdEngine.engine.sampleRate * maxDelayTime))))
        self.mask = bufferSize - 1
        self.buffer = [LyrebirdFloat](count: bufferSize, repeatedValue: 0.0)
        super.init(rate: rate)
        self.writeHead = LyrebirdInt(LyrebirdEngine.engine.sampleRate * delayTime.floatValue(graph))
        self.lastDelayTime = self.delayTime.floatValue(graph)
    }
    
    public override final func next(numSamples: LyrebirdInt) -> Bool {
        var success = super.next(numSamples)
        if(success){
            switch self.interpolation {
            case .Linear:
                success = nextLinear(numSamples)
                break
                
            case .None:
                success = nextNone(numSamples)
                break
                
            case .Cubic:
                success = nextCubic(numSamples)
                break
            }
            while readHead > LyrebirdFloat(mask) {
                readHead = readHead - LyrebirdFloat(bufferSize)
            }
            if writeHead > mask {
                writeHead = writeHead & mask
            }
        }
        return success
    }
    
    private final func nextNone(numSamples: LyrebirdInt) -> Bool{
        let inputSamples = self.input.calculatedSamples(graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * LyrebirdEngine.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead) & mask
            samples[sampleIdx] = buffer[iReadHead]
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    private final func nextLinear(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = self.input.calculatedSamples(graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * LyrebirdEngine.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead)
            let bufferIdxPct: LyrebirdFloat = readHead - fReadHead
            let bufferIdx: LyrebirdInt = iReadHead & mask
            let bufferIdxP1: LyrebirdInt = (iReadHead + 1) & mask
            samples[sampleIdx] = linearInterp(buffer[bufferIdx], x2: buffer[bufferIdxP1], pct: bufferIdxPct)
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    private final func nextCubic(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = self.input.calculatedSamples(graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * LyrebirdEngine.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead)
            let bufferIdxPct: LyrebirdFloat = readHead - fReadHead
            let bufferIdx: LyrebirdInt = iReadHead & mask
            let bufferIdxM1: LyrebirdInt = (iReadHead - 1) & mask
            let bufferIdxP1: LyrebirdInt = (iReadHead + 1) & mask
            let bufferIdxP2: LyrebirdInt = (iReadHead + 2) & mask
            samples[sampleIdx] = cubicInterp(buffer[bufferIdxM1], y0: buffer[bufferIdx], y1: buffer[bufferIdxP1], y2: buffer[bufferIdxP2], pct: bufferIdxPct)
            samples[sampleIdx] = linearInterp(buffer[bufferIdx], x2: buffer[bufferIdxP1], pct: bufferIdxPct)
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
}
