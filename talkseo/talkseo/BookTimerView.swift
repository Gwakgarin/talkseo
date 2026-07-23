import SwiftUI

struct BookTimerView: View {
    var sessionID: Int
    var bookTitle: String
    var coverImageURL: String
    var userBookID: Int    

    @State private var elapsedTime: Int = 0
    @State private var isRunning = true
    @State private var timer: Timer?
    @State private var goToSave: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text(currentDateString())
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(bookTitle)
                    .font(.title2.bold())
                    .padding(.top, 5)

                if let url = URL(string: coverImageURL), !url.absoluteString.isEmpty {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .scaledToFit()
                    .frame(width: 180, height: 260)
                    .cornerRadius(12)
                }

                Text("현재 집중 시간")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(formatTime(elapsedTime))
                    .font(.system(size: 38, weight: .bold))

                HStack(spacing: 40) {
                    Button {
                        endSession()
                    } label: {
                        Text("종료")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Color.red)
                            .clipShape(Circle())
                    }

                    Button {
                        toggleTimer()
                    } label: {
                        Text(isRunning ? "중단" : "재개")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(isRunning ? Color.gray : Color.green)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 30)

                Spacer()
            }
            .padding()
            .onAppear { startTimer() }
            .onDisappear { timer?.invalidate() }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goToSave) {
                SaveBookView(sessionID: sessionID, userBookID: userBookID)   // ⭐ 전달
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if isRunning { elapsedTime += 1 }
        }
    }

    func toggleTimer() {
        isRunning.toggle()
    }

    func endSession() {
        timer?.invalidate()
        isRunning = false
        goToSave = true

        let url = URL(string:
            "http://124.56.5.77/talkseo/ip02/end_session.php?session_id=\(sessionID)&reading_time=\(elapsedTime)"
        )!
        URLSession.shared.dataTask(with: url).resume()
    }

    func formatTime(_ sec: Int) -> String {
        let h = sec / 3600
        let m = (sec % 3600) / 60
        let s = sec % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    func currentDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd(E)"
        f.locale = Locale(identifier: "ko_KR")
        return f.string(from: Date())
    }
}

#Preview {
    BookTimerView(
        sessionID: 1,
        bookTitle: "사서함 110호의 우편물",
        coverImageURL: "https://image.yes24.com/goods/110832417/XL",
        userBookID: 3
    )
}
