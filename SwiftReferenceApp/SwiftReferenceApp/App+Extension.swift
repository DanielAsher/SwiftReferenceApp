//
//  App+Extension.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import SwiftyStateMachine

extension App 
{
    // Helper functions
    func handleEvent(event: AppEvent) { 
        machine.handleEvent(event) 
    }

    public func set(user: User) -> Bool 
    {
        self.user = user
        
        machine.addDidTransitionCallback { oldState, event, newState, app in 
           self.user[event] 
        }
        return true
    }
    
    public var state : AppState {
        return machine.state
    }
}

infix operator <- { associativity left precedence 90}

public func <- (lhs: App, rhs: AppEvent) -> App {
    lhs.machine.handleEvent(rhs)
    return lhs
}

// Tuple equality operators
public func == <T:Equatable, U: Equatable> 
    (tuple1:(T,U),tuple2:(T,U)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}

public func == <T:Equatable, U: Equatable, V: Equatable> 
    (tuple1:(T,U, V), tuple2:(T, U, V)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1) && (tuple1.2 == tuple2.2)
}

public func == <T:Equatable, U: Equatable, V: Equatable, W: Equatable> (
    tuple1:(T,U,V,W), tuple2:(T,U,V,W)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1) && (tuple1.2 == tuple2.2) && (tuple1.3 == tuple2.3)
}













// FIXME: No protocol extensions until swift 2.0. 
/*
protocol DOTLabelableEquality : DOTLabelable {
    func ==(lhs: Self, rhs: Self) -> Bool 
}

extension DOTLabelableEquality {
    public func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.DOTLabel == rhs.DOTLabel
    } 
}

extension DOTLabelableEquality : Equatable {} 
*/


// MARK: CombinedComparable
enum ComparisonOrdering: Int {
    case Ascending = 1
    case Descending = -1
    case Same = 0
}

infix operator <=> { precedence 130 }
protocol CombinedComparable: Comparable, Equatable {
    func <=>(lhs: Self, rhs: Self) -> ComparisonOrdering
}

func <<T: CombinedComparable>(lhs: T, rhs: T) -> Bool {
    return (lhs <=> rhs) == .Ascending
}

func ==<T: CombinedComparable>(lhs: T, rhs: T) -> Bool {
    return (lhs <=> rhs) == .Same
}


