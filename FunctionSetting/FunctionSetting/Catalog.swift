import SwiftUI

enum Kind { case toggle, slider(ClosedRange<Double>, Double, String), picker([String]), text(String) }

struct Feature: Identifiable {
    let id: String, title: String, sub: String, kind: Kind
}

struct Category: Identifiable {
    let id: String, title: String, icon: String, color: Color, items: [Feature]
}

private func T(_ i: String, _ t: String, _ s: String) -> Feature { Feature(id: i, title: t, sub: s, kind: .toggle) }
private func S(_ i: String, _ t: String, _ s: String, _ r: ClosedRange<Double>, _ d: Double, _ u: String = "") -> Feature { Feature(id: i, title: t, sub: s, kind: .slider(r, d, u)) }
private func P(_ i: String, _ t: String, _ s: String, _ o: [String]) -> Feature { Feature(id: i, title: t, sub: s, kind: .picker(o)) }
private func X(_ i: String, _ t: String, _ s: String, _ d: String) -> Feature { Feature(id: i, title: t, sub: s, kind: .text(d)) }

let catalog: [Category] = [
    Category(id: "display", title: "显示", icon: "display", color: .blue, items: [
        T("d1", "状态栏显示秒数", "在时间后追加秒"),
        S("d2", "灵动岛尺寸", "缩放系统灵动岛", 0.5...2, 1, "×"),
        P("d3", "屏幕刷新率", "强制指定刷新率", ["60 Hz", "120 Hz", "144 Hz", "240 Hz"]),
        S("d4", "峰值亮度", "HDR 峰值亮度上限", 800...4000, 2000, " nit"),
        T("d5", "常亮显示", "所有机型启用 AOD"),
        X("d6", "状态栏运营商文字", "自定义信号旁文字", "5G-A"),
        S("d7", "液态玻璃折射强度", "全局玻璃材质", 0...100, 60, "%")]),
    Category(id: "device", title: "设备", icon: "iphone", color: .indigo, items: [
        P("v1", "机型伪装", "设置里显示的机型", ["iPhone 17 Pro Max", "iPhone Air", "iPhone 17", "iPhone Fold"]),
        X("v2", "设备名称", "关于本机中的名称", "Function iPhone"),
        X("v3", "电池循环次数", "显示的循环次数", "1"),
        S("v4", "电池健康度", "最大容量显示", 80...100, 100, "%"),
        T("v5", "充电功率显示", "充电时显示实时瓦数"),
        T("v6", "相机控制键", "为所有机型启用"),
        S("v7", "触感强度", "Taptic 全局增益", 0...200, 100, "%"),
        X("v8", "序列号", "自定义序列号显示", "F2LX7Q9K1M")]),
    Category(id: "ipad", title: "iPad", icon: "ipad", color: .cyan, items: [
        T("p1", "台前调度", "iPhone 也能用"),
        T("p2", "窗口化 App", "自由缩放窗口"),
        T("p3", "外接显示器扩展", "USB-C 扩展桌面"),
        P("p4", "Dock 样式", "底部 Dock 外观", ["经典", "悬浮", "隐藏"]),
        T("p5", "菜单栏", "App 顶部菜单栏"),
        T("p6", "Apple Pencil Pro", "解锁悬停与挤压")]),
    Category(id: "ai", title: "智能", icon: "sparkles", color: .blue, items: [
        T("i1", "Apple 智能", "绕过机型限制"),
        T("i2", "Siri 彩虹边框", "屏幕边缘流光"),
        T("i3", "实时翻译", "通话与信息"),
        T("i4", "写作工具", "全局文本改写"),
        T("i5", "图乐园", "本地图像生成"),
        P("i6", "端侧模型规格", "本地模型大小", ["3B", "8B", "13B", "70B"]),
        T("i7", "屏幕识别", "Siri 读懂屏幕")]),
    Category(id: "adv", title: "高级", icon: "wrench.and.screwdriver", color: .gray, items: [
        T("a1", "写入前自动备份", "防止变砖"),
        T("a2", "写入全部 CacheExtra", "覆盖所有键"),
        T("a3", "解除帧率上限", "游戏全速"),
        T("a4", "开发者模式", "显示调试菜单"),
        P("a5", "日志级别", "系统日志详细度", ["关闭", "错误", "警告", "调试"]),
        T("a6", "重启 SpringBoard", "应用后自动重启")]),
    Category(id: "lab", title: "实验室", icon: "flask.fill", color: .purple, items: [
        T("l1", "反重力图标", "主屏图标悬浮漂移"),
        T("l2", "屏幕呼吸灯", "息屏时边缘呼吸"),
        T("l3", "锁屏猫咪巡逻", "小猫在锁屏上走动"),
        T("l4", "充电边缘光效", "充电时屏幕边缘发光"),
        T("l5", "解锁粒子特效", "解锁瞬间粒子散开"),
        P("l6", "触摸涟漪颜色", "点击屏幕的涟漪", ["无", "蓝", "粉", "彩虹"]),
        S("l7", "锁屏时钟字重", "时钟粗细", 100...900, 400),
        S("l8", "时间偏移", "系统时间偏移", -24...24, 0, " 小时"),
        S("l9", "App 图标圆角", "主屏图标形状", 0...50, 22, "%"),
        X("l10", "状态栏表情", "时间旁显示表情", "😺")]),
    Category(id: "sound", title: "声音与触感", icon: "speaker.wave.3.fill", color: .pink, items: [
        T("s1", "相机快门声", "强制开启快门声"),
        T("s2", "截屏音效", "截图时播放"),
        P("s3", "充电提示音", "连接电源的声音", ["默认", "水滴", "叮咚", "无"]),
        T("s4", "键盘触感", "输入时震动"),
        S("s5", "音量上限", "系统最大音量", 0...200, 100, "%"),
        T("s6", "锁屏音效", "锁定/解锁声")]),
    Category(id: "cam", title: "相机", icon: "camera.fill", color: .orange, items: [
        T("c1", "4K 120 帧", "解锁高帧率视频"),
        T("c2", "全机型 ProRAW", "解锁 ProRAW 拍摄"),
        S("c3", "最大变焦", "数码变焦上限", 1...100, 10, "×"),
        X("c4", "相机水印", "照片底部文字", "Shot on iPhone"),
        T("c5", "无声连拍", "关闭连拍声")]),
    Category(id: "net", title: "网络", icon: "antenna.radiowaves.left.and.right", color: .green, items: [
        T("n1", "5G-A 图标", "状态栏显示 5G-A"),
        T("n2", "Wi-Fi 7", "强制启用"),
        S("n3", "热点连接数", "个人热点上限", 1...50, 5),
        T("n4", "实时网速", "状态栏显示速率"),
        T("n5", "解除限速", "蜂窝数据不限速")])
]
