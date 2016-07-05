//
//  LyrebirdDemo.swift
//  LyrebirdSynthLang
//
//  Created by Joshua Parmenter on 5/19/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Cocoa
import Lyrebird

class LyrebirdDemo: NSObject {
    
    let lyrebird: LyrebirdMain!
    var timer: LyrebirdTimer? = nil
    var graphs: LyrebirdTestGraphs = LyrebirdTestGraphs()
    
    required init(lyrebird: LyrebirdMain){
        self.lyrebird = lyrebird
        super.init()
    }
    
    func runDemo(){
        
        graphs.setupDemoGraphs()
        
        
        let impulse = graphs.graphs["impulse"]
        var impulseNote : LyrebirdNote? = LyrebirdNote(graph: impulse)
        impulseNote?.updateParameter("Freq", value: 1.0)
        
        self.timer = LyrebirdTimer()
        if let timer = self.timer {
            var counter: LyrebirdInt = 0
            /*
            self.lyrebird.addNodeToHead(noiseNote!)
            lyrebird.addNodeToHead(fmNote!)
            */
            lyrebird.addNodeToHead(impulseNote!)
            
            let block: LyrebirdTimerBlock = {(curTime: LyrebirdFloat, inc: LyrebirdInt) in
                counter = counter + 1
                print("Hello \(curTime, inc)")
                if counter == 19 {
/*                    noiseNote?.finishBlock = { _ in
                        print("Done")
                    }
                    noiseNote?.free()
                    noiseNote = nil
                    fmNote?.free()
                    fmNote = nil
 */
                    impulseNote?.free()
                    impulseNote = nil
                }
                if counter < 20 {
                    return 0.4
                }
                self.timer = nil
                
                return nil
                
            }
            timer.block = block
            let finalBlock: LyrebirdTimerFinalizerBlock = {(curTime: LyrebirdFloat) in
                    print("Final \(curTime)")
            }
            timer.finalizerBlock = finalBlock
            timer.run()
        }
    }
}
