import SwiftUI

struct CCSkeletonView: View {
    @State private var phase: CGFloat = -1
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        GeometryReader { geo in
            ZStack {
                theme.surface
                theme.background
                    .mask(
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.clear, .white.opacity(0.4), .clear],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .offset(x: phase * geo.size.width)
                    )
            }
            .cornerRadius(8)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        }
    }
}

// MARK: - Preset skeleton shapes
struct CCSkeletonCard: View {
    var body: some View {
        VStack(spacing: 8) {
            CCSkeletonView().frame(height: 16).cornerRadius(4)
            CCSkeletonView().frame(height: 12).cornerRadius(4)
            CCSkeletonView().frame(height: 12).cornerRadius(4).padding(.trailing, 60)
        }
    }
}

struct CCSkeletonCircle: View {
    var size: CGFloat = 56
    var body: some View {
        CCSkeletonView().frame(width: size, height: size).clipShape(Circle())
    }
}

struct CCSkeletonGrid: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<10, id: \.self) { _ in
                VStack(spacing: 6) {
                    CCSkeletonCircle(size: 44)
                    CCSkeletonView().frame(height: 10).frame(width: 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
    }
}

struct CCSkeletonList: View {
    var count: Int = 4
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                HStack(spacing: 12) {
                    CCSkeletonCircle(size: 44)
                    VStack(alignment: .leading, spacing: 6) {
                        CCSkeletonView().frame(height: 14).frame(width: 120)
                        CCSkeletonView().frame(height: 12).padding(.trailing, 40)
                    }
                }
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(theme.radiusMD)
            }
        }
    }
}
