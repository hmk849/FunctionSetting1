import SwiftUI

@main
struct FunctionSettingApp: App {
    @StateObject private var store = Store()
    var body: some Scene {
        WindowGroup { RootView().environmentObject(store) }
    }
}

final class Store: ObservableObject {
    @Published var v: [String: String] = (UserDefaults.standard.dictionary(forKey: "fs.v") as? [String: String]) ?? [:] {
        didSet { UserDefaults.standard.set(v, forKey: "fs.v") }
    }
    @Published var toast: String?

    func bool(_ k: String) -> Binding<Bool> { Binding(get: { self.v[k] == "1" }, set: { self.v[k] = $0 ? "1" : "0" }) }
    func num(_ k: String, _ d: Double) -> Binding<Double> { Binding(get: { Double(self.v[k] ?? "") ?? d }, set: { self.v[k] = String($0) }) }
    func str(_ k: String, _ d: String) -> Binding<String> { Binding(get: { self.v[k] ?? d }, set: { self.v[k] = $0 }) }

    func show(_ t: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.easeInOut) { toast = t }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { withAnimation(.easeInOut) { self.toast = nil } }
    }
}

// MARK: - 液态玻璃（iOS 26+ 用系统 glassEffect，旧系统退回材质）
extension View {
    @ViewBuilder func glass(_ r: CGFloat = 28) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: r))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: r, style: .continuous))
        }
        #else
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: r, style: .continuous))
        #endif
    }
}

struct Backdrop: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            Circle().fill(Color.blue.opacity(0.18)).frame(width: 320, height: 320).blur(radius: 70).offset(x: 140, y: -260)
            Circle().fill(Color.pink.opacity(0.14)).frame(width: 300, height: 300).blur(radius: 70).offset(x: -150, y: 120)
        }.ignoresSafeArea()
    }
}

struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ c: () -> Content) { content = c() }
    var body: some View { VStack(spacing: 0) { content }.glass(32) }
}

struct Header: View {
    let t: String
    init(_ t: String) { self.t = t }
    var body: some View { Text(t).font(.title3.weight(.semibold)).foregroundStyle(.secondary).padding(.leading, 12).padding(.top, 14) }
}

struct BigTitle: View {
    let t: String
    init(_ t: String) { self.t = t }
    var body: some View { Text(t).font(.system(size: 40, weight: .heavy)).padding(.top, 28).padding(.leading, 6).padding(.bottom, 8) }
}

struct Div: View { var body: some View { Divider().padding(.horizontal, 20) } }

struct InfoRow: View {
    let a: String, b: String
    init(_ a: String, _ b: String) { self.a = a; self.b = b }
    var body: some View {
        HStack { Text(a); Spacer(); Text(b).foregroundStyle(.secondary).multilineTextAlignment(.trailing) }
            .font(.system(size: 18)).padding(.horizontal, 20).padding(.vertical, 16)
    }
}

struct RootView: View {
    @EnvironmentObject var store: Store
    var body: some View {
        TabView {
            ToolsView().tabItem { Label("工具", systemImage: "square.grid.2x2.fill") }
            MGView().tabItem { Label("MG 控制", systemImage: "slider.horizontal.3") }
            BackupView().tabItem { Label("备份", systemImage: "clock.arrow.circlepath") }
            AboutView().tabItem { Label("关于", systemImage: "info.circle.fill") }
        }
        .overlay(alignment: .top) {
            if let t = store.toast {
                Text(t).font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .glass(24).padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
