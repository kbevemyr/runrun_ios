//
//  ContentView.swift
//  RunRunApp
//
//  Created by Katrin Boberg Bevemyr on 2025-09-11.
//

import SwiftUI
import RunRunCore
import RunRuniOS

struct ContentView: View {
    @State private var workoutProgram = "P10 (x3 (x3 W70@VO2 R20) R2m@set-rest)"
    @State private var workout: Workout?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                Text("🏃‍♀️ RunRun Interval Timer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Current Program Display
                VStack(spacing: 12) {
                    Text("Current Program:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(workoutProgram)
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)
                }
                
                // Error Message
                if let error = errorMessage {
                    Text("❌ \(error)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Workout Summary (if valid)
                if let workout = workout {
                    VStack(spacing: 16) {
                        Text("Workout Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 30) {
                            // Intervals
                            VStack(spacing: 4) {
                                Text("\(workout.totals.totalIntervals)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Intervals")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            // Total Time
                            VStack(spacing: 4) {
                                Text(timeString(workout.totals.totalSeconds))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .monospacedDigit()
                                Text("Total Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Edit Program Button
                    NavigationLink(destination: EditorView(program: workoutProgram, onProgramUpdated: { newProgram in
                        workoutProgram = newProgram
                        parseWorkout()
                    })) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Program")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Start Workout Button
                    if let workout = workout {
                        NavigationLink(destination: RunView(workout: workout, onBackToStart: {
                            // This will be handled by NavigationView's back button
                        })) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Workout")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    } else {
                        Button("Start Workout") {
                            // Disabled state
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(true)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .onAppear {
                parseWorkout()
            }
        }
    }
    
    private func parseWorkout() {
        let builder = ProgramParser()
        do {
            workout = try builder.parse(workoutProgram)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            workout = nil
        }
    }
    
    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    ContentView()
}
