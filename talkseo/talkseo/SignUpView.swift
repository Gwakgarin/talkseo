import SwiftUI

struct SignUpView: View {

    // 입력 값
    @State private var id = ""
    @State private var pwd = ""
    @State private var pwd2 = ""
    @State private var user_name = ""
    @State private var email = ""
    @State private var phonenum = ""

    // 상태
    @State private var message = ""
    @State private var isSignUpComplete = false
    @State private var userID: Int? = nil   // 회원가입 후 받은 user_id

    var body: some View {
        VStack(spacing: 20) {

            NavigationLink(
                destination: ProfileView(userID: userID ?? 0),
                isActive: $isSignUpComplete
            ) {
                EmptyView()
            }

            VStack(alignment: .leading) {
                Text("아이디")
                TextField("ID를 입력해주세요.", text: $id)
            }

            VStack(alignment: .leading) {
                Text("비밀번호")
                SecureField("비밀번호를 입력해주세요.", text: $pwd)
            }

            VStack(alignment: .leading) {
                Text("비밀번호 확인")
                SecureField("비밀번호를 다시 입력해주세요.", text: $pwd2)
            }

            VStack(alignment: .leading) {
                Text("이름")
                TextField("ex) 홍길동", text: $user_name)
            }

            VStack(alignment: .leading) {
                Text("이메일")
                TextField("ex) example@gmail.com", text: $email)
            }

            VStack(alignment: .leading) {
                Text("전화번호")
                TextField("ex) 010-0000-0000", text: $phonenum)
            }

            // 회원가입 버튼
            Button {
                hideKeyboard()
                checkAndSignUp()
            } label: {
                Text("회원가입")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color(red: 30/255, green: 180/255, blue: 30/255))
                    .cornerRadius(8)
            }

            Text(message)
                .foregroundColor(.red)
        }
        .padding(40)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .navigationTitle("회원가입")
    }

    // 입력값 검증 + 서버 요청
    func checkAndSignUp() {

        if id.count < 4 {
            message = "ID는 4글자 이상이어야 합니다."
            return
        }

        if pwd.count < 4 {
            message = "비밀번호는 4글자 이상이어야 합니다."
            return
        }

        if pwd != pwd2 {
            message = "비밀번호가 일치하지 않습니다."
            return
        }

        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/signup.php") else {
            message = "서버 연결 오류"
            return
        }

        let body =
        "id=\(id)&pwd=\(pwd)&user_name=\(user_name)&email=\(email)&phonenum=\(phonenum)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }
            let response = String(decoding: data, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)

          
            if let uid = Int(response), uid > 0 {
                DispatchQueue.main.async {
                    self.userID = uid
                    UserDefaults.standard.set(uid, forKey: "user_id")
                    isSignUpComplete = true
                }
            } else {
                DispatchQueue.main.async {
                    message = "회원가입 실패"
                }
            }
        }.resume()
    }

    // 키보드 내리기
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
