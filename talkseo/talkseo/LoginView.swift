//
//  LoginView.swift
//  talkseo
//
//  Created by mac28 on 10/27/25.
//

import SwiftUI

struct LoginView: View {


    @State private var id: String = ""
    @State private var pwd: String = ""


    @State private var loginUserID: Int = 0
    @State private var isSucceedLogin: Bool = false

    @State private var goToSignUp: Bool = false
    @State private var goToFindIdView: Bool = false
    @State private var goToFindPwdView: Bool = false


    @State private var idMessage: String = ""
    @State private var pwdMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // 로그인 성공 시 RootView로 이동하면서 userID 전달
                NavigationLink(
                    destination: RootView(userID: loginUserID),
                    isActive: $isSucceedLogin
                ) {
                    EmptyView()
                }

 
                NavigationLink(destination: SignUpView(), isActive: $goToSignUp) { EmptyView() }
                NavigationLink(destination: FindIdView(), isActive: $goToFindIdView) { EmptyView() }
                NavigationLink(destination: FindPwdView(), isActive: $goToFindPwdView) { EmptyView() }

                Spacer().frame(height: 40)

    
                Image("talkseo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .padding(.bottom, 10)

        
                Text("톡서와 함께 지식 키우기")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                    .padding(.bottom, 40)

                // 아이디 입력 영역
                VStack(alignment: .leading) {
                    Text("아이디")
                    TextField("아이디를 입력하세요.", text: $id)
                        .padding()
                        .background(Color(red: 249/255, green: 245/255, blue: 244/255))
                        .cornerRadius(12)

                    // 아이디 관련 에러 메시지 표시
                    Text(idMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                }

                // 비밀번호 입력 영역
                VStack(alignment: .leading) {
                    Text("비밀번호")
                    SecureField("비밀번호를 입력하세요.", text: $pwd)
                        .padding()
                        .background(Color(red: 249/255, green: 245/255, blue: 244/255))
                        .cornerRadius(12)

                    // 비밀번호 관련 에러 메시지 표시
                    Text(pwdMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                }

                // 아이디 / 비밀번호 찾기 버튼
                HStack {
                    Button("아이디 찾기") { goToFindIdView = true }
                        .foregroundColor(.gray)
                    Text("ㅣ").foregroundColor(.gray)
                    Button("비밀번호 찾기") { goToFindPwdView = true }
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)

                // 로그인 버튼
                Button(action: login) {
                    Text("로그인")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 340, minHeight: 50)
                        .background(Color(red: 30/255, green: 180/255, blue: 30/255))
                        .cornerRadius(10)
                }

                // 회원가입 버튼
                Button("회원가입") { goToSignUp = true }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 340, minHeight: 50)
                    .background(Color.gray)
                    .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            // 화면이 다시 나타날 때 로그인 상태 초기화
            isSucceedLogin = false
            loginUserID = 0
        }
    }

    // 로그인 처리 함수
    func login() {

        // 아이디 입력 여부 검사
        if id.isEmpty {
            idMessage = "아이디를 입력해주세요"
            return
        }

        // 비밀번호 입력 여부 검사
        if pwd.isEmpty {
            pwdMessage = "비밀번호를 입력해주세요"
            return
        }

        // 이전 에러 메시지 초기화
        idMessage = ""
        pwdMessage = ""

        // 로그인 요청을 보낼 서버 URL
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/login.php") else { return }

        // POST 방식으로 전달할 바디 데이터
        let body = "id=\(id)&pwd=\(pwd)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        // 서버로 로그인 요청
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }

            // 서버 응답을 문자열로 변환
            let responseStr = String(decoding: data, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            print("서버 응답:", responseStr)

    
            if let userId = Int(responseStr), userId > 0 {
                UserDefaults.standard.set(userId, forKey: "loginUserID")

                DispatchQueue.main.async {
                    // 로그인 성공 처리 및 화면 이동
                    loginUserID = userId
                    isSucceedLogin = true
                }
            } else {
                // 로그인 실패 시 에러 메시지 표시
                DispatchQueue.main.async {
                    pwdMessage = "아이디 또는 비밀번호가 올바르지 않습니다."
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView()
}
