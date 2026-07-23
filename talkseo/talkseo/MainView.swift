//
//  SelectBookView.swift
//  talkseo
//
//  Created by 곽가린 on 11/3/25.
//

import SwiftUI

struct MainView: View {


    let userID: Int
    @State private var todayBooks: [TodayBookSession] = []

    @State private var goToSearchBook = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // 상단 영역: 오늘 날짜 + 오늘 총 독서 시간
            VStack(spacing: 5) {
                Text(getTodayDate())
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // 오늘 독서 시간을 초 단위로 계산한 뒤 시:분:초 형태로 변환해 표시
                Text(formatTime(totalSeconds: totalReadingTime()))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.top, 40)
            
            Divider()


            ScrollView {
                VStack(spacing: 12) {
                    
                    // 오늘 읽은 책 목록
                    ForEach(todayBooks) { book in
                        NavigationLink(
                          
                            destination: SelectBookView(
                                userBookID: Int(book.user_book_id) ?? 0
                            )
                        ) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)

                         
                                Text(book.title)
                                    .font(.headline)

                                Spacer()

                 
                                Text(formatTime(totalSeconds: book.today_total_time))
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 2)
                        }
                        .buttonStyle(.plain)
                    }

                    // 도서 추가 버튼
                    Button {
                        goToSearchBook = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.gray)
                            Text("도서 추가")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 2)
                    }
                    .padding(.top, 10)

                    // 도서 검색 화면으로 이동
                    NavigationLink(
                        destination: SearchBookView(userID: userID),
                        isActive: $goToSearchBook
                    ) {
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }

        .onAppear {
            loadTodayBooks()
        }

        .toolbar(.hidden, for: .navigationBar)
        .background(Color(.systemGroupedBackground))
    }
    
    // 오늘 독서 현황을 서버에서 받아오는 함수
    func loadTodayBooks() {

        // 로그인한 사용자 ID를 쿼리 파라미터로 전달
        guard let url = URL(
            string: "http://124.56.5.77/talkseo/ip02/reading_today.php?user_id=\(userID)"
        ) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                // 서버 JSON 응답을 TodayBookResponse 모델로 디코딩
                let decoded = try JSONDecoder().decode(
                    TodayBookResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    // 디코딩된 오늘 독서 데이터 저장
                    todayBooks = decoded.today_books
                }
            } catch {
                // 디코딩 실패 시 에러 출력
                print("디코딩 에러:", error)
                if let str = String(data: data, encoding: .utf8) {
                    print("서버 응답:", str)
                }
            }
        }.resume()
    }
    
    // 날짜 형식 변환 
    func getTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd(E)"
        return formatter.string(from: Date())
    }
    
    // 총 독서 시간
      func totalReadingTime() -> String {
          let total = todayBooks.reduce(0) {
              $0 + (Int($1.today_total_time) ?? 0)
          }
          return String(total)
      }
    
    // 시간 형식 변환
    func formatTime(totalSeconds: String) -> String {
            guard let sec = Int(totalSeconds) else {
                return "00:00:00"
            }
            let h = sec / 3600
            let m = (sec % 3600) / 60
            let s = sec % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
}

// 서버 응답 전체 구조
struct TodayBookResponse: Codable {
    let today_books: [TodayBookSession]
}

// 오늘 독서 현황 한 권당 데이터 모델
struct TodayBookSession: Codable, Identifiable {
    // user_book_id를 고유 식별자로 사용
    var id: String { user_book_id }

    // 사용자가 읽고 있는 책의 고유 ID
    let user_book_id: String

    // 책 제목
    let title: String

    // 해당 책의 오늘 독서 시간 (초 단위, 문자열)
    let today_total_time: String
}


#Preview {
    MainView(userID: 1)
}
