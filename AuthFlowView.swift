import SwiftUI

enum AuthMode {
    case login
    case signup
}

struct AuthFlowView: View {
    
    @EnvironmentObject var foodController: FoodOrderController
    @State private var mode: AuthMode = .login
    @State private var showOTP: Bool = false
    
    // common fields passed to OTP
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    @State private var tempPhone: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color("pink").opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 40)
                
                VStack(spacing: 8) {
                    Text("TableTogether")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color("pink"))
                    Text("Delicious food, delivered fast.")
                        .foregroundStyle(.gray)
                }
                .padding(.bottom, 24)
                
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            mode = .login
                        } label: {
                            Text("Login")
                                .font(.headline)
                                .foregroundStyle(mode == .login ? .white : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    mode == .login ? Color("pink") : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button {
                            mode = .signup
                        } label: {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundStyle(mode == .signup ? .white : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    mode == .signup ? Color("pink") : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(8)
                    
                    if mode == .login {
                        LoginForm { name, email, phone in
                            tempName = name
                            tempEmail = email
                            tempPhone = phone
                            showOTP = true
                        }
                    } else {
                        SignupForm { name, email, phone in
                            tempName = name
                            tempEmail = email
                            tempPhone = phone
                            showOTP = true
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 6)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showOTP) {
            OTPVerificationView(
                name: tempName,
                email: tempEmail,
                phone: tempPhone
            )
            .environmentObject(foodController)
        }
    }
}

// MARK: - Login form

struct LoginForm: View {
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    
    let onContinue: (String, String, String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                TextField("Name", text: $name)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Phone number", text: $phone)
                    .keyboardType(.phonePad)
                SecureField("Password", text: $password)
            }
            .textFieldStyle(.roundedBorder)
            
            Button {
                guard !name.isEmpty, !email.isEmpty, !password.isEmpty else { return }
                onContinue(name, email, phone)
            } label: {
                Text("Login")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("pink"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.top, 8)
            .padding(.horizontal)
            
            Text("We’ll send you a one-time code to verify your login.")
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding(.horizontal)
                .padding(.bottom, 12)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Signup form

struct SignupForm: View {
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    let onContinue: (String, String, String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                TextField("Full name", text: $name)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Phone number", text: $phone)
                    .keyboardType(.phonePad)
                SecureField("Password", text: $password)
                SecureField("Confirm password", text: $confirmPassword)
            }
            .textFieldStyle(.roundedBorder)
            
            Button {
                guard !name.isEmpty,
                      !email.isEmpty,
                      !password.isEmpty,
                      password == confirmPassword else { return }
                onContinue(name, email, phone)
            } label: {
                Text("Create account")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("pink"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.top, 8)
            .padding(.horizontal)
            
            Text("We’ll send you a one-time code to verify your account.")
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding(.horizontal)
                .padding(.bottom, 12)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - OTP verification with random OTP printed in console

struct OTPVerificationView: View {
    
    @EnvironmentObject var foodController: FoodOrderController
    @Environment(\.dismiss) var dismiss
    
    let name: String
    let email: String
    let phone: String
    
    @State private var otp: String = ""
    @State private var generatedOTP: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color("pink").opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("Verify OTP")
                    .font(.title.bold())
                    .foregroundStyle(Color("pink"))
                Text("Enter the 4-digit code shown in the Xcode console.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    TextField("____", text: $otp)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    
                    Button {
                        if otp == generatedOTP {
                            // Save user info and log in
                            foodController.userName = name
                            foodController.userEmail = email
                            foodController.userPhone = phone
                            foodController.isLoggedIn = true
                            dismiss()
                        } else {
                            errorMessage = "Incorrect code. Check the Xcode console and try again."
                        }
                    } label: {
                        Text("Verify and continue")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            // Generate random 4-digit OTP (0000–9999) and print to console
            generatedOTP = String(format: "%04d", Int.random(in: 0...9999))
            print("🔐 DEMO OTP for \(email.isEmpty ? phone : email): \(generatedOTP)")
        }
    }
}

