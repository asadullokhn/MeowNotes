import SwiftUI

// The circular "x" remove control used across the care sheets. One definition
// for every call site — pass `size` to match the row it sits in.
struct RemoveCircleButton: View {
    var size: CGFloat = 32
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(.backgroundPredefined))
                Image(systemName: "xmark")
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(Color(.xIcon).opacity(0.5))
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove")
    }
}

#Preview {
    HStack(spacing: 16) {
        RemoveCircleButton(size: 26) {}
        RemoveCircleButton(size: 32) {}
        RemoveCircleButton(size: 40) {}
    }
    .padding()
    .background(Color("AppBg"))
}
