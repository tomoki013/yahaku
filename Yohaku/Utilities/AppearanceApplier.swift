import SwiftUI

// 外観設定をUIWindowに直接適用する。
// ウィンドウ単位なのでシートや確認ダイアログも含めて即座に切り替わり、
// 「システム」に戻したときも正しくシステム設定へ追従する。
struct AppearanceApplier: UIViewRepresentable {
    let mode: AppearanceMode

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let style = mode.uiStyle
        DispatchQueue.main.async {
            uiView.window?.overrideUserInterfaceStyle = style
        }
    }
}
