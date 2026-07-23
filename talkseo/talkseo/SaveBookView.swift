import SwiftUI

struct SessionDetailResponse: Codable {
    let sessions: [SessionDetail]
}

struct SessionDetail: Codable {
    let session_date: String
    let reading_time: Int
    let current_page: Int
    let total_pages: Int
    let title: String
    let cover_image_url: String
}

struct SaveBookView: View {
    var sessionID: Int
    var userBookID: Int      

    @State private var endPage = ""
    @State private var isSaved = false

    @State private var readingTime = 0
    @State private var totalPages = 0
    @State private var sessionDate = ""
    @State private var bookTitle = ""
    @State private var coverImageURL = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("독서 완료!")
                .font(.largeTitle.bold())

            Text("마지막 페이지 번호를 입력해주세요.")
                .foregroundColor(.gray)

            TextField("마지막 페이지", text: $endPage)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 30, weight: .bold))
                .padding(.horizontal, 50)

            Button("저장") {
                saveEndPage()
            }
            .font(.title3.bold())
            .foregroundColor(.green)
        }
        .padding()
        .navigationDestination(isPresented: $isSaved) {
            ResultBookView(
                bookTitle: bookTitle,
                coverImageURL: coverImageURL,
                sessionDate: sessionDate,
                readingTime: readingTime,
                endPage: Int(endPage) ?? 0,
                totalPages: totalPages,
                userBookID: userBookID
            )
        }
    }

    func saveEndPage() {
        guard let end = Int(endPage) else { return }

        let url = URL(string:
            "http://124.56.5.77/talkseo/ip02/save_session.php?session_id=\(sessionID)&end_page=\(end)"
        )!

        URLSession.shared.dataTask(with: url) { _, _, _ in
            fetchSessionDetail()
        }.resume()
    }

    func fetchSessionDetail() {
        let url = URL(string:
            "http://124.56.5.77/talkseo/ip02/get_session.php?session_id=\(sessionID)"
        )!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(SessionDetailResponse.self, from: data),
                  let s = decoded.sessions.first else { return }

            DispatchQueue.main.async {
                bookTitle = s.title
                coverImageURL = s.cover_image_url
                sessionDate = s.session_date
                readingTime = s.reading_time
                totalPages = s.total_pages
                isSaved = true
            }
        }.resume()
    }
}

#Preview {
    NavigationStack {
        SaveBookView(sessionID: 1, userBookID: 3)
    }
}
