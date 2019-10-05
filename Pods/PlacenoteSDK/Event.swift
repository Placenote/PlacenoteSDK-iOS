//
//  Event.swift
//  PlacenoteSDK
//
//  Created by Yan Ma on 2019-10-04
//  Author: Colin Eberhardt Credit: https://blog.scottlogic.com/2015/02/05/swift-events.html
//

import Foundation

public protocol Disposable {
  func dispose()
}

public class Event<T> {
  
  public typealias EventHandler = (T) -> ()
  
  private var eventHandlers = [Invocable]()
  
  private class EventHandlerWrapper<T: AnyObject, U>
  : Invocable, Disposable {
    weak var target: T?
    let handler: (T) -> (U) -> ()
    let event: Event<U>
    
    init(target: T?, handler: @escaping (T) -> (U) -> (), event: Event<U>) {
      self.target = target
      self.handler = handler
      self.event = event;
    }
    
    func invoke(data: Any) -> () {
      if let t = target {
        handler(t)(data as! U)
      }
    }
    
    func dispose() {
      event.eventHandlers =
        event.eventHandlers.filter { $0 !== self }
    }
  }
  
  
  public func raise(data: T) {
    for handler in self.eventHandlers {
      handler.invoke(data: data)
    }
  }
  
  public func addHandler<U: AnyObject>(target: U,
                                       handler: @escaping (U) -> EventHandler) -> Disposable {
    let wrapper = EventHandlerWrapper(target: target,
                                      handler: handler,
                                      event: self)
    eventHandlers.append(wrapper)
    return wrapper
  }
}

private protocol Invocable: class {
  func invoke(data: Any)
}
