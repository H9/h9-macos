//
//  H9App.swift
//  H9
//
//  Created by bhua on 2/22/24.
//

import SwiftUI

@available(macOS 13.0, *)
@main
struct H9App: App {
		@State private var activeWindow: NSWindow? = nil
		@State private var accessibilityGranted = false
	
		init() {
			 let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
			 let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
			 
			 if accessibilityEnabled == true {
					print("Accessibility is enabled")
					accessibilityGranted = true
					print(accessibilityGranted)
			 } else {
					 print("Accessibility is not enabled. Please enable it in System Preferences")
			 }
		}

		var body: some Scene {
				MenuBarExtra("App Menu Bar Extra", image: "trayicon") {
					Button("Settings") {
						showWindow(Settings(accessibilityGranted: accessibilityGranted), width: 900, height: 600)
					}
					.keyboardShortcut("s")
					Divider()
					Button("Quit") {
							NSApplication.shared.terminate(nil)
					}
					.keyboardShortcut("q")
				}.menuBarExtraStyle(.menu)
		}

		private func showWindow<T: View>(_ view: T, width: CGFloat, height: CGFloat) {
			if let existingWindow = activeWindow, existingWindow.title == "\(T.self)" {
					existingWindow.makeKeyAndOrderFront(nil)
					return
			}

			activeWindow?.close()

			let hostingController = NSHostingController(rootView: view)
			let window = NSWindow(contentViewController: hostingController)
			window.title = "\(T.self)"
			window.setContentSize(NSSize(width: width, height: height))

			// Set the window style
			window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
			window.titlebarAppearsTransparent = true
			window.titleVisibility = .hidden
			
			window.level = .floating
			window.makeKeyAndOrderFront(nil)
			window.center()
			activeWindow = window
		}
}

struct Settings: View {
			@State private var isLaunchAtLoginChecked: Bool = false
			
			@State private var isEditingShortcut = false
			@State private var newShortcut = ""
			@AppStorage("h9commandshortcut") private var savedShortcut = ""
	
			var accessibilityGranted: Bool
	
			var body: some View {
					VStack(alignment: .leading, spacing: 20) {
						HStack {
							VStack (spacing: -5) {
								Text("H9")
										.font(.title2)
										.fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
										.frame(maxWidth: .infinity, alignment: .trailing)
								Text("v1.0.240301")
										.font(.system(size: 10))
										.foregroundColor(.gray)
										.frame(maxWidth: .infinity, alignment: .trailing)
							}.padding(.trailing, -5)
							
							Image("logoinview")
									.resizable()
									.frame(width: 32, height: 32)
									.padding(.trailing)
						}
							
							GroupBox(label: Text("Window Positions").font(.title3).fontWeight(.bold).padding(.bottom, 5)) {
								VStack {
										HStack {
												ButtonView(label: "Center", keyCombination: "⌃⌥⌘C")
												ButtonView(label: "Fullscreen", keyCombination: "⌃⌥⌘F")
												ButtonView(label: "Next Display", keyCombination: "⌃⌥⌘→")
												ButtonView(label: "Previous Display", keyCombination: "⌃⌥⌘←")
										}
										HStack {
												ButtonView(label: "Left Half", keyCombination: "⌃⌥⌘←")
												ButtonView(label: "Right Half", keyCombination: "⌃⌥⌘→")
												ButtonView(label: "Top Half", keyCombination: "⌃⌥⌘↑")
												ButtonView(label: "Bottom Half", keyCombination: "⌃⌥⌘↓")
										}
										HStack {
												ButtonView(label: "Upper Left", keyCombination: "⇧⌥⌘←")
												ButtonView(label: "Upper Right", keyCombination: "⇧⌥⌘→")
												ButtonView(label: "Lower Left", keyCombination: "⇧⌥⌘↓←")
												ButtonView(label: "Lower Right", keyCombination: "⇧⌥⌘↓→")
										}
										HStack {
												ButtonView(label: "Make Larger", keyCombination: "⇧⌥⌘+")
												ButtonView(label: "Make Smaller", keyCombination: "⇧⌥⌘-")
												ButtonView(label: "Undo", keyCombination: "⌃⌘Z")
												ButtonView(label: "Redo", keyCombination: "⌃⌥⌘Z")
										}
									
									Divider().padding()
									
									HStack {
										VStack {
											Text("⌃").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
											Text("Control")
										}
										VStack {
											Text("⌥").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
											Text("Option")
										}.padding(.horizontal, 20)
										VStack {
											Text("⌘").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
											Text("Command")
										}.padding(.trailing, 20)
										VStack {
											Text("⇧").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
											Text("Shift")
										}
									}
									
								}
								.padding()
							}
							.padding()
													
							HStack {
									Toggle(isOn: $isLaunchAtLoginChecked) {
											Text("Launch H9 at login")
									}
									
									if accessibilityGranted {
											Text("Accessibility permission granted!")
													.padding()
									} else {
											Button(action: {
												openAccessibilitySettings()
											}) {
												Text("* Needs Accessibility Permission").foregroundColor(.red)
											}
											.padding()
									}
									Spacer()
												
									Text("Copyright &copy; 2024 Bin Hua")
											.font(.system(size: 10))
											.foregroundColor(.gray)
											.frame(alignment: .trailing)
							}
							.padding(.horizontal)
					}
					.padding()
			}
	
			private func openAccessibilitySettings() {
					#if os(macOS)
					guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
					#else
					guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
					#endif
					NSWorkspace.shared.open(url)
			}
}

struct ButtonView: View {
		var label: String
		var keyCombination: String

		var body: some View {
				HStack {
					
					Text(label)
							 .font(.system(size: 11))
							 .padding(.leading, 10)
						
					Spacer()
					
						Text(keyCombination)
								.font(.system(size: 13, weight: .bold))
								.padding(.horizontal, 4)
								.padding(.vertical, 3)

						
				}
				.padding(.horizontal)
		}
}
