//
//  Event.swift
//  PlacenoteSDK
//
//  Created by Yan Ma on 2019-10-04
//  Author: Colin Eberhardt Credit: https://blog.scottlogic.com/2015/02/05/swift-events.html
//

import Foundation

/// An interface to be implemented by Event class to enable cleanup via dispose function.
public protocol Disposable {
  /// Implement this function to cleanup the object that inherits this protocol
  func dispose()
}

/// A class that implements event pattern that enables signalling of an event occurs.
public class Event<T> {
  /// Alias for a closure that takes the event data payload type and do something with it
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
  
  /**
   Raise an signal to the list of handlers added to this event.

   - Parameter data: payload to send to the handlers via this signal
   */
  public func raise(data: T) {
    for handler in self.eventHandlers {
      handler.invoke(data: data)
    }
  }
  
  /**
   Add a listener to handle the signal raised by an Event object

   - Parameter target: object reference that subscribe to the event
   - Parameter handler: the handler to handle the event
   */
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
