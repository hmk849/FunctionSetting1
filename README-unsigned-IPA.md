# Function setting — unsigned IPA

1. 将此项目文件上传/覆盖到 GitHub 仓库根目录（保留 `.github/workflows/ios-unsigned-ipa.yml`）。
2. 在 GitHub 仓库打开 Actions，选择 `Build unsigned iOS IPA`，点击 `Run workflow`。
3. 成功后打开该次运行页面，在 Artifacts 下载 `FunctionSetting-unsigned-IPA`，解压即可得到 `.ipa`。

此 IPA 未签名，不能直接安装；需要之后用个人签名工具签名。

注意：当前 Swift 项目说明其开关只保存 App 内部设置，不会实际修改 iOS 系统。
