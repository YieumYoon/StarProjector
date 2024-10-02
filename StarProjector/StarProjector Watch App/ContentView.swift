import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var offset: CGFloat = 0
    @State private var isScrolling = false
    @State private var timer: Timer?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            StarField(offset: offset, size: geometry.size)
        }
        .edgesIgnoringSafeArea(.all)
        .focusable()
        .focused($isFocused)
        .digitalCrownRotation($offset, from: 0, through: 1000, by: 1, sensitivity: .high, isContinuous: true, isHapticFeedbackEnabled: true)
        .onChange(of: offset) { _, _ in
            isScrolling = true
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                withAnimation(.easeInOut(duration: 5.0)) {
                    isScrolling = false
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}

struct Star: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
}

struct StarField: View {
    let offset: CGFloat
    let size: CGSize
    let starCount = 100
    
    @State private var stars: [Star] = []
    
    init(offset: CGFloat, size: CGSize) {
        self.offset = offset
        self.size = size
        _stars = State(initialValue: Self.generateStars(count: starCount, in: size))
    }
    
    var body: some View {
        Canvas { context, size in
            for star in stars {
                let yPosition = (star.y + offset).truncatingRemainder(dividingBy: size.height)
                context.fill(Path(ellipseIn: CGRect(x: star.x, y: yPosition, width: star.size, height: star.size)), with: .color(.white))
            }
        }
        .background(Color.black)
    }
    
    static func generateStars(count: Int, in size: CGSize) -> [Star] {
        (0..<count).map { _ in
            Star(x: CGFloat.random(in: 0...size.width),
                 y: CGFloat.random(in: 0...size.height),
                 size: CGFloat.random(in: 1...3))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
