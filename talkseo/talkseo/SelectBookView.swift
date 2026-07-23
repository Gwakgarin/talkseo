//
//  SelectBookView.swift
//  talkseo
//
//  Created by 곽가린 on 11/3/25.
//

import SwiftUI


struct SelectBookView: View {

    let userBookID: Int
    @State private var sessions: [BookSession] = []
    

    @State private var navigateToTimer = false
    @State private var newSessionID: Int?
    
    @State private var isCompleted: Bool = false

    @State private var showSmallMenu = false
    @State private var showDeletePopup = false


    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {

                            // 상단 네비게이션 바
                            HStack {
                                Image(systemName: "chevron.left")
                                    .onTapGesture { dismiss() }

                                Spacer()

                                Text(sessions.first?.title ?? "")
                                    .font(.headline)

                                Spacer()

                                Image(systemName: "ellipsis")
                                    .onTapGesture {
                                        withAnimation {
                                            showSmallMenu.toggle()
                                        }
                                    }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)

                            // 책 정보 및 누적 독서 시간 영역
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {

                                    Text("누적 시간")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    // 타이머 시작 버튼 또는 완독 체크 표시
                                    HStack(spacing: 10) {
                                        if isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .resizable()
                                                .frame(width: 36, height: 36)
                                                .foregroundColor(.yellow)
                                        } else {
                                            Button(action: {
                                                startNewSession()
                                            }) {
                                                Image(systemName: "play.circle.fill")
                                                    .resizable()
                                                    .frame(width: 36, height: 36)
                                                    .foregroundColor(.green)
                                            }
                                            .buttonStyle(.plain)
                                        }

                                        // 서버에서 계산된 누적 독서 시간 표시
                                        Text(formatTime(totalSeconds: sessions.first?.total_reading_time ?? "0"))
                                            .font(.system(size: 34, weight: .bold))
                                    }

                                    // 현재 페이지 / 전체 페이지 표시
                                    Text("페이지 \(sessions.first?.current_page ?? "0") / \(sessions.first?.total_pages ?? "0")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    // 독서 기간 표시
                                    let start = sessions.first?.start_date ?? ""
                                    let end = (sessions.first?.end_date?.isEmpty == false)
                                        ? sessions.first!.end_date!
                                        : (isCompleted ? completedDateText() : "진행중")

                                    Text("독서기간 \(formatDate(start)) ~ \(end)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                // 책 커버 이미지 표시
                                if let url = URL(string: sessions.first?.cover_image_url ?? ""),
                                   !url.absoluteString.isEmpty {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .scaledToFit()
                                    .frame(width: 110, height: 150)
                                    .cornerRadius(8)
                                } else {
                                    Image("book_cover")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 110, height: 150)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)

                            // 독서 세션 목록 영역
                            if sessions.isEmpty || sessions.allSatisfy({ Int($0.reading_time) ?? 0 == 0 }) {
                                // 독서 기록이 없는 경우
                                Text("아직 독서 기록이 없습니다.")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .padding(.top, 40)
                            } else {
                                // 타이머 실행 단위의 독서 세션 리스트
                                VStack(spacing: 10) {
                                    ForEach(sessions) { session in
                                        NavigationLink(destination: DetailBookView(session: session)) {
                                            SessionRowView(
                                                date: formatDate(session.session_date),
                                                pages: "\(session.end_page)/\(session.total_pages)",
                                                time: formatTime(totalSeconds: session.reading_time)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }

                            Spacer()
                        }
                    }
                }

                // 우측 상단 메뉴
                if showSmallMenu {
                    VStack {
                        HStack {
                            Spacer()

                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation {
                                        showSmallMenu = false
                                        showDeletePopup = true
                                    }
                                }) {
                                    Text("삭제하기")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 100)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
                            .padding(.trailing, 22)
                            .padding(.top, 50)
                        }
                        Spacer()
                    }
                    .transition(.opacity)
                }

                // 전체 기록 삭제 확인 팝업
                if showDeletePopup {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Text("기록 삭제")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        Text("‘\(sessions.first?.title ?? "")’ 의\n전체 타이머 기록이 삭제됩니다.\n그래도 삭제하시겠습니까?")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)

                        Button(action: {
                            deleteAllRecords()
                        }) {
                            Text("삭제")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.vertical, 10)
                        }

                        Spacer().frame(height: 10)

                    }
                    .frame(width: 300, height: 260)
                    .background(Color.white)
                    .cornerRadius(20)
                }
            }
        }
        // 타이머 화면으로 이동
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToTimer) {
            if let id = newSessionID {
                BookTimerView(
                    sessionID: id,
                    bookTitle: sessions.first?.title ?? "",
                    coverImageURL: sessions.first?.cover_image_url ?? "",
                    userBookID: userBookID
                )
            }
        }
        // 화면 진입 시 서버에서 세션 데이터 로드
        .onAppear {
            loadBookData()
        }
    }

    // 해당 책의 모든 독서 기록 삭제
    func deleteAllRecords() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/delete_book_all.php?user_book_id=\(userBookID)") else { return }

        URLSession.shared.dataTask(with: url) { _, _, _ in
            DispatchQueue.main.async {
                showDeletePopup = false
                dismiss()
            }
        }.resume()
    }

    // 타이머 시작 → 새로운 독서 세션 생성
    func startNewSession() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/start_session.php?user_book_id=\(userBookID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            if let id = Int(String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)) {
                DispatchQueue.main.async {
                    newSessionID = id
                    navigateToTimer = true
                    loadBookData()
                }
            }
        }.resume()
    }

    // 선택한 책의 BookSession 데이터 서버에서 로드
    func loadBookData() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/reading_select_book.php?user_book_id=\(userBookID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(SessionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.sessions = decoded.sessions
                    checkCompletion()
                }
            } catch {
                print("Decoding Error:", error)
            }
        }.resume()
    }

    // 완독 여부 체크
    func checkCompletion() {
        guard let first = sessions.first else { return }

        if first.current_page == first.total_pages {
            isCompleted = true

            if (first.end_date ?? "").isEmpty {
                updateCompletionDate()
            }
        }
    }

    // 완독 날짜 서버에 업데이트
    func updateCompletionDate() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/complete_book.php?user_book_id=\(userBookID)") else { return }
        URLSession.shared.dataTask(with: url) { _, _, _ in }.resume()
    }

    // 현재 날짜를 완독 시점 텍스트로 반환
    func completedDateText() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd(E) HH:mm"
        f.locale = Locale(identifier: "ko_KR")
        return f.string(from: Date())
    }

    // 초 단위 시간을 시:분:초 형식으로 변환
    func formatTime(totalSeconds: String) -> String {
        guard let sec = Int(totalSeconds) else { return "00:00:00" }
        let h = sec / 3600
        let m = (sec % 3600) / 60
        let s = sec % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    // 서버 날짜 문자열을 사용자 표시용 포맷으로 변환
    func formatDate(_ str: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: str) {
            formatter.dateFormat = "yyyy.MM.dd(E) HH:mm"
            return formatter.string(from: date)
        }
        return str
    }
}

// 서버 응답 모델
struct SessionResponse: Codable {
    let sessions: [BookSession]
}

// 독서 세션 데이터 모델
struct BookSession: Codable, Identifiable {
    let session_id: Int
    var id: String { session_date }

    let title: String
    let cover_image_url: String
    let total_pages: String
    let current_page: String
    let start_date: String?
    let end_date: String?
    let total_reading_time: String
    let session_date: String
    var reading_time: String
    let start_page: String
    var end_page: String
}

// 세션 한 줄 UI
struct SessionRowView: View {
    let date: String
    let pages: String
    let time: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(date)
                    .font(.headline)
                Text(pages)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(time)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    SelectBookView(userBookID: 1)
}
