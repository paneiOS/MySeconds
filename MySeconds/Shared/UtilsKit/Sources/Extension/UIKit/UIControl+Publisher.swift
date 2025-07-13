//
//  UIControl+Publisher.swift
//  UtilsKit
//
//  Created by 이정환 on 4/24/25.
//

import Combine
import UIKit

public extension UIControl {
    func publisher(for events: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        EventPublisher(control: self, events: events)
            .eraseToAnyPublisher()
    }
}

private struct EventPublisher: Publisher {
    typealias Output = UIControl
    typealias Failure = Never

    let control: UIControl
    let events: UIControl.Event

    func receive<S>(subscriber: S) where S: Subscriber, S.Input == UIControl, S.Failure == Never {
        let subscription = EventSubscription(subscriber: subscriber, control: control, events: events)
        subscriber.receive(subscription: subscription)
    }
}

private final class EventSubscription<S: Subscriber>: Subscription where S.Input == UIControl, S.Failure == Never {
    private var subscriber: S?
    private weak var control: UIControl?
    let events: UIControl.Event

    init(subscriber: S, control: UIControl, events: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        self.events = events
        control.addTarget(self, action: #selector(self.handleEvent), for: events)
    }

    func request(_: Subscribers.Demand) {}

    func cancel() {
        self.control?.removeTarget(self, action: #selector(self.handleEvent), for: self.events)
        self.subscriber = nil
    }

    @objc private func handleEvent() {
        guard let control else { return }
        _ = self.subscriber?.receive(control)
    }
}
