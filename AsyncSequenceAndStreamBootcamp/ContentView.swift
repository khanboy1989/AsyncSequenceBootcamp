//
//  ContentView.swift
//  AsyncSequenceAndStreamBootcamp
//
//  Created by Serhan Khan on 17/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var values: [Int] = [] // Stores emitted values
    @State private var isStreaming = false // Tracks if streaming is active
    
    var body: some View {
        VStack {
            Text("AsyncStream Timer Example")
                .font(.title)
                .padding()
            
            // Display emitted values
            List(values, id: \.self) { value in
                Text("Value: \(value)")
            }
            
            // Start Timer Button
            Button(action: {
                startTimerStream()
            }) {
                Text(isStreaming ? "Streaming..." : "Start Timer")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isStreaming ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(isStreaming) // Disable while streaming
            
            Spacer()
        }
        .padding()
    }
    
    // AsyncStream Timer Function
    func startTimerStream() {
        self.values.removeAll() // Clear old values
        self.isStreaming = true // Mark streaming as active
        
        Task {
            for await value in makeTimerStream() {
                self.values.append(value) // Add new value to the list
            }
            isStreaming = false // Reset when streaming ends
        }
    }
    
    // Timer Stream Function
    func makeTimerStream() -> AsyncStream<Int> {
        AsyncStream { continuation in
            var count = 0
            
            let queue = DispatchQueue.global()
            let timer = DispatchSource.makeTimerSource(queue: queue)
            
            timer.schedule(deadline: .now(), repeating: 1.0)
            timer.setEventHandler {
                count += 1
                continuation.yield(count)
                
                if count == 5 {
                    continuation.finish()
                    timer.cancel() // Cancel the timer
                }
            }
            
            timer.resume() // Start the timer
            
            continuation.onTermination = { _ in
                timer.cancel() // Ensure cleanup on termination
            }
        }
    }
}

