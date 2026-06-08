import SwiftUI

struct CCProfileView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 52)).foregroundColor(Color(hex: "5A7A8A"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("安静的云雀").font(.system(size: 20, weight: .semibold))
                        Text("已陪伴你 23 天").font(.system(size: 14)).foregroundColor(.secondary)
                    }
                }.padding(.vertical, 8)
            }

            Section {
                Button(action: { coordinator.navigate(to: .vipCenter) }) {
                    Label("会员中心", systemImage: "crown.fill").foregroundColor(Color(hex: "8B6F47"))
                }
            }

            Section {
                Button(action: { coordinator.navigate(to: .settings) }) {
                    Label("设置", systemImage: "gearshape.fill").foregroundColor(.primary)
                }
            }

            Section {
                Button(role: .destructive, action: { coordinator.isLoggedIn = false }) {
                    HStack { Spacer(); Text("退出登录"); Spacer() }
                }
            }
        }
        .navigationTitle("我的")
    }
}
