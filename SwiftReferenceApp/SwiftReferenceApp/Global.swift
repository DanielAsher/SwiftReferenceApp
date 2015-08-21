//
//  Global.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import Foundation
import SwiftyStateMachine

extension GraphableStateMachineSchema { 
    func saveSchema(path: String) -> String? 
    { 
        var err: NSError?
        if self.DOTDigraph.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: &err) && err == nil
        {
            return path
        }
        else 
        {
            return nil
        }
    }
}


