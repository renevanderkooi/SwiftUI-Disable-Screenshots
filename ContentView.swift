//
//  ContentView.swift
//  DisableScreenshot
//
//  Created by Rene van der Kooi.
//


import SwiftUI
import UIKit


struct ContentView: View {
    var body: some View {
        MyScreen()
    }
}

struct MyScreen: View {
    @State private var secure = true
    
    var body: some View {
        ZStack {
            ScreenshotBlockedNoticeView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            SecureView(isSecureTextEntry: $secure) {
                VStack {
                    Toggle("Prevent screenshots", isOn: $secure).padding()
                    
                    if (secure) {
                        Text("Protected screen")
                            .font(.largeTitle)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                    } else {
                        Text("Unprotected screen")
                            .font(.largeTitle)

                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 60))
                    }
                    
                    Button("Do something") {
                        print("Tapped")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct ScreenshotBlockedNoticeView: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.blue.opacity(0.12))
                    .frame(width: 110, height: 110)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 12) {
                Text("Screenshots Disabled")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)

                Text("For your privacy and security, screenshots and screen recordings are disabled on this screen.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "eye.slash.fill")
                        .foregroundStyle(.blue)

                    Text("Sensitive information is protected")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)

                    Spacer()
                }

                HStack(spacing: 12) {
                    Image(systemName: "video.slash.fill")
                        .foregroundStyle(.blue)

                    Text("Screen recording is also restricted")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)

                    Spacer()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
            )
            .padding(.horizontal, 24)

            Spacer()

            Text("You can continue using the app normally.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct SecureView<Content: View>: UIViewRepresentable {
    @Binding var isSecureTextEntry: Bool
    private let content: Content

    init(
        isSecureTextEntry: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self._isSecureTextEntry = isSecureTextEntry
        self.content = content()
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let secureField = UITextField()
        secureField.backgroundColor = .clear
        secureField.borderStyle = .none
        secureField.isSecureTextEntry = isSecureTextEntry
        secureField.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(secureField)

        NSLayoutConstraint.activate([
            secureField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            secureField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            secureField.topAnchor.constraint(equalTo: container.topAnchor),
            secureField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let secureCanvas = secureField.subviews.first ?? secureField

        let hosting = UIHostingController(rootView: content)
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        secureCanvas.addSubview(hosting.view)

        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: secureCanvas.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: secureCanvas.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: secureCanvas.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: secureCanvas.bottomAnchor)
        ])

        context.coordinator.secureField = secureField
        context.coordinator.hostingController = hosting

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.secureField?.isSecureTextEntry = isSecureTextEntry
        context.coordinator.hostingController?.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var secureField: UITextField?
        var hostingController: UIHostingController<Content>?
    }
}

#Preview {
    ContentView()
}
