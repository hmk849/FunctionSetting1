import SwiftUI
import UIKit

// MARK: - 真实读取设备信息
enum DeviceInfo {
    static func read() -> [(String, String)] {
        let d = UIDevice.current
        d.isBatteryMonitoringEnabled = true
        var u = utsname(); uname(&u)
        let machine = withUnsafeBytes(of: &u.machine) { p in String(decoding: p.prefix { $0 != 0 }, as: UTF8.self) }
        let model = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? machine
        let pi = ProcessInfo.processInfo
        let bf = ByteCountFormatter.self
        let mem = bf.string(fromByteCount: Int64(pi.physicalMemory), countStyle: .binary)
        let vol = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])
        let total = bf.string(fromByteCount: Int64(vol?.volumeTotalCapacity ?? 0), countStyle: .file)
        let free = bf.string(fromByteCount: vol?.volumeAvailableCapacityForImportantUsage ?? 0, countStyle: .file)
        let bat = d.batteryLevel < 0 ? "未知" : "\(Int(d.batteryLevel * 100))%"
        let b = UIScreen.main.nativeBounds
        let th = ["正常", "轻微", "严重", "危急"][min(pi.thermalState.rawValue, 3)]
        return [
            ("机型", model),
            ("iOS", "\(d.systemVersion) (支持)"),
            ("状态", "已连接"),
            ("内存", mem),
            ("存储", "\(free) / \(total)"),
            ("电量", bat),
            ("分辨率", "\(Int(b.width))×\(Int(b.height))"),
            ("CPU 核心", "\(pi.activeProcessorCount)"),
            ("热状态", th),
            ("已运行", String(format: "%.1f 小时", pi.systemUptime / 3600))
        ]
    }
}

// MARK: - 工具
struct ToolsView: View {
    @EnvironmentObject var store: Store
    @State private var info = DeviceInfo.read()
    private let count = catalog.reduce(0) { $0 + $1.items.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    BigTitle("Function setting")
                    Header("设备")
                    Card {
                        ForEach(Array(info.enumerated()), id: \.offset) { i, r in
                            if i > 0 { Div() }
                            InfoRow(r.0, r.1)
                        }
                    }
                    Button {
                        info = DeviceInfo.read()
                        store.show("已重新读取")
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "arrow.clockwise").font(.title2)
                            Text("重新读取").font(.title3)
                            Spacer()
                        }.padding(20).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain).foregroundStyle(.blue).glass(32)

                    Header("功能分类 · \(count) 项")
                    Card {
                        ForEach(Array(catalog.enumerated()), id: \.element.id) { i, c in
                            if i > 0 { Divider().padding(.leading, 76) }
                            NavigationLink {
                                CategoryView(cat: c)
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: c.icon).font(.title2).foregroundStyle(c.color).frame(width: 40)
                                    Text(c.title).font(.title3)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 20).padding(.vertical, 16).contentShape(Rectangle())
                            }.buttonStyle(.plain)
                        }
                    }
                }.padding(.horizontal)
            }
            .background(Backdrop())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - 分类页
struct CategoryView: View {
    let cat: Category
    @EnvironmentObject var store: Store
    @State private var applying = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Card {
                    ForEach(Array(cat.items.enumerated()), id: \.element.id) { i, f in
                        if i > 0 { Div() }
                        FeatureRow(f: f).padding(.horizontal, 20).padding(.vertical, 14)
                    }
                }
                Button(action: apply) {
                    HStack(spacing: 8) {
                        if applying { ProgressView() }
                        Text(applying ? "写入中…" : "应用修改")
                    }
                    .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16).contentShape(Rectangle())
                }
                .buttonStyle(.plain).foregroundStyle(.blue).glass(28).disabled(applying)
            }.padding(.horizontal)
        }
        .background(Backdrop())
        .navigationTitle(cat.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    func apply() {
        applying = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            applying = false
            store.show("「\(cat.title)」已应用")
        }
    }
}

struct FeatureRow: View {
    let f: Feature
    @EnvironmentObject var store: Store

    var body: some View {
        switch f.kind {
        case .toggle:
            Toggle(isOn: store.bool(f.id)) { label }
        case .slider(let r, let d, let u):
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    label
                    Spacer()
                    Text(fmt(store.num(f.id, d).wrappedValue) + u).foregroundStyle(.secondary).monospacedDigit()
                }
                Slider(value: store.num(f.id, d), in: r)
            }
        case .picker(let o):
            HStack {
                label
                Spacer()
                Picker("", selection: store.str(f.id, o[0])) {
                    ForEach(o, id: \.self) { Text($0).tag($0) }
                }.pickerStyle(.menu)
            }
        case .text(let d):
            HStack {
                label
                Spacer()
                TextField("", text: store.str(f.id, d))
                    .multilineTextAlignment(.trailing).foregroundStyle(.secondary).frame(maxWidth: 150)
            }
        }
    }

    var label: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(f.title).font(.body)
            Text(f.sub).font(.caption).foregroundStyle(.secondary)
        }
    }

    func fmt(_ x: Double) -> String {
        (x == x.rounded() || abs(x) >= 100) ? String(Int(x)) : String(format: "%.1f", x)
    }
}

// MARK: - MG 控制
struct MGView: View {
    @EnvironmentObject var store: Store
    @State private var q = ""
    private let keys: [(String, String)] = [
        ("DeviceName", "Function iPhone"), ("ProductType", "iPhone18,2"), ("MarketingName", "iPhone 17 Pro Max"),
        ("DeviceClass", "iPhone"), ("ArtworkDeviceSubType", "2796"), ("ChipID", "0x8140"),
        ("SupportsForceTouch", "1"), ("HasBaseband", "1"), ("ApplePencilCapability", "2"),
        ("RearCameraCount", "3"), ("DeviceSupportsCameraControl", "1"), ("SupportsAlwaysOnDisplay", "1"),
        ("MainScreenScale", "3"), ("InternalBuild", "0")
    ]

    var body: some View {
        let list = keys.filter { q.isEmpty || $0.0.localizedCaseInsensitiveContains(q) }
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    BigTitle("MG 控制")
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("搜索 MobileGestalt 键", text: $q)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                    }.padding(16).glass(24)
                    Header("MobileGestalt · \(list.count) 项")
                    Card {
                        ForEach(Array(list.enumerated()), id: \.offset) { i, k in
                            if i > 0 { Div() }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(k.0).font(.system(.footnote, design: .monospaced)).foregroundStyle(.secondary)
                                TextField("", text: store.str("mg." + k.0, k.1))
                            }.padding(.horizontal, 20).padding(.vertical, 12)
                        }
                    }
                    Button { store.show("已写入 MobileGestalt") } label: {
                        Text("写入并应用").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16).contentShape(Rectangle())
                    }.buttonStyle(.plain).foregroundStyle(.blue).glass(28)
                }.padding(.horizontal)
            }
            .background(Backdrop())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - 备份
struct BackupView: View {
    @EnvironmentObject var store: Store
    @State private var items = ["初始备份", "改动前备份"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    BigTitle("备份")
                    Button {
                        items.insert("备份 · " + Date().formatted(date: .numeric, time: .shortened), at: 0)
                        store.show("备份已创建")
                    } label: {
                        Label("新建备份", systemImage: "plus.circle.fill")
                            .font(.title3).padding(20).frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
                    }.buttonStyle(.plain).foregroundStyle(.blue).glass(32)
                    Header("已有备份")
                    Card {
                        ForEach(Array(items.enumerated()), id: \.offset) { i, s in
                            if i > 0 { Div() }
                            HStack {
                                Text(s)
                                Spacer()
                                Button("恢复") { store.show("已恢复「\(s)」") }.buttonStyle(.bordered)
                            }.padding(.horizontal, 20).padding(.vertical, 14)
                        }
                    }
                }.padding(.horizontal)
            }
            .background(Backdrop())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - 关于
struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    BigTitle("关于")
                    Card {
                        InfoRow("名称", "Function setting")
                        Div()
                        InfoRow("版本", "1.0 (1)")
                        Div()
                        InfoRow("界面", "iOS 液态玻璃")
                    }
                    Text("这是一个界面演示空壳：所有开关和数值只保存在本 App 内，不会修改系统。设备信息为真实读取。")
                        .font(.footnote).foregroundStyle(.secondary).padding(.horizontal, 12)
                }.padding(.horizontal)
            }
            .background(Backdrop())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
