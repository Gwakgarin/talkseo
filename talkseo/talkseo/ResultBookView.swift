import SwiftUI

struct ResultBookView: View {
    var bookTitle: String
    var coverImageURL: String
    var sessionDate: String
    var readingTime: Int
    var endPage: Int
    var totalPages: Int
    var userBookID: Int     

    @State private var goBack = false

    var body: some View {
            VStack {

                NavigationLink(
                    destination: SelectBookView(userBookID: userBookID),
                    isActive: $goBack
                ) { EmptyView() }

                ScrollView {
                    VStack(spacing: 20) {
                        Text(sessionDate)
                            .foregroundColor(.gray)

                        Text(bookTitle)
                            .font(.title.bold())

                        if let url = URL(string: coverImageURL) {
                            AsyncImage(url: url) { img in
                                img.resizable()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .scaledToFit()
                            .frame(width: 200, height: 300)
                            .cornerRadius(12)
                        }

                        VStack {
                            Text("집중 시간")
                            Text(formatTime(readingTime))
                                .font(.system(size: 36, weight: .bold))
                        }

                        VStack {
                            Text("페이지")
                            Text("\(endPage)/\(totalPages)")
                                .font(.system(size: 36, weight: .bold))
                        }
                    }
                    .padding()
                }

                Button {
                    goBack = true
                } label: {
                    Text("확인")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    func formatTime(_ sec: Int) -> String {
        let h = sec / 3600, m = (sec % 3600) / 60, s = sec % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

#Preview {
    ResultBookView(
        bookTitle: "사서함 110호의 우편물",
        coverImageURL: "https://image.yes24.com/goods/110832417/XL",
        sessionDate: "2025.09.30",
        readingTime: 1200,
        endPage: 90,
        totalPages: 300,
        userBookID: 1
    )
}
