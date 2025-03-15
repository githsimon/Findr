//
//  ToastView.swift
//  FindrIOS
//
//  Created on 2025/3/15.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSuccess ? Color.green : Color.red)
                .opacity(0.9)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let isSuccess: Bool
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    ToastView(message: message, isSuccess: isSuccess)
                        .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isShowing)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, isSuccess: Bool = true, duration: Double = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, isSuccess: isSuccess, duration: duration))
    }
}

#Preview {
    VStack {
        Text("Hello, World!")
    }
    .modifier(ToastModifier(isShowing: .constant(true), message: "保存成功！", isSuccess: true, duration: 2.0))
}
