import SwiftUI
import ComposableArchitecture

struct AuthView: View {
    let store: StoreOf<AuthFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "airplane")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Palette.primaryRed)
                        
                        Text("Aviator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your Flight Companion")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Auth Form
                    VStack(spacing: 16) {
                        if viewStore.showingLogin {
                            LoginFormView(store: store)
                        } else {
                            RegisterFormView(store: store)
                        }
                        
                        // Toggle Auth Mode
                        Button(action: {
                            viewStore.send(.toggleAuthMode)
                        }) {
                            Text(viewStore.showingLogin ? "Don't have an account? Sign up" : "Already have an account? Sign in")
                                .foregroundColor(Theme.Palette.primaryRed)
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Error Message Popup
                    if let errorMessage = viewStore.errorMessage {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                
                                Text("Error")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                                
                                Button(action: {
                                    viewStore.send(.setError(nil))
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                }
                            }
                            
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 32)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: viewStore.errorMessage)
                    }
                }
                .background(Theme.Gradient.background)
                .navigationBarHidden(true)
            }
        }
    }
}

struct LoginFormView: View {
    let store: StoreOf<AuthFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text("Sign In")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    TextField("Enter your email", text: viewStore.binding(
                        get: \.loginEmail,
                        send: { .updateLoginEmail($0) }
                    ))
                    .textFieldStyle(AuthTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    SecureField("Enter your password", text: viewStore.binding(
                        get: \.loginPassword,
                        send: { .updateLoginPassword($0) }
                    ))
                    .textFieldStyle(AuthTextFieldStyle())
                }
                
                // Login Button
                Button(action: {
                    viewStore.send(.login(viewStore.loginEmail, viewStore.loginPassword))
                }) {
                    HStack {
                        if viewStore.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right")
                        }
                        Text("Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.Gradient.button)
                    .cornerRadius(8)
                    .shadow(color: Theme.Shadow.red, radius: 4)
                }
                .disabled(viewStore.isLoading || viewStore.loginEmail.isEmpty || viewStore.loginPassword.isEmpty)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct RegisterFormView: View {
    let store: StoreOf<AuthFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text("Sign Up")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // First Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    TextField("Enter your first name", text: viewStore.binding(
                        get: \.registerFirstName,
                        send: { .updateRegisterFirstName($0) }
                    ))
                    .textFieldStyle(AuthTextFieldStyle())
                }
                
                // Last Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    TextField("Enter your last name", text: viewStore.binding(
                        get: \.registerLastName,
                        send: { .updateRegisterLastName($0) }
                    ))
                    .textFieldStyle(AuthTextFieldStyle())
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    TextField("Enter your email", text: viewStore.binding(
                        get: \.registerEmail,
                        send: { .updateRegisterEmail($0) }
                    ))
                    .textFieldStyle(AuthTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    SecureField("Enter your password", text: viewStore.binding(
                        get: \.registerPassword,
                        send: { .updateRegisterPassword($0) }
                    ))
                    .textFieldStyle(AuthTextFieldStyle())
                }
                
                // Register Button
                Button(action: {
                    viewStore.send(.register(
                        viewStore.registerEmail,
                        viewStore.registerPassword,
                        viewStore.registerFirstName,
                        viewStore.registerLastName
                    ))
                }) {
                    HStack {
                        if viewStore.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "person.badge.plus")
                        }
                        Text("Sign Up")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.Gradient.button)
                    .cornerRadius(8)
                    .shadow(color: Theme.Shadow.red, radius: 4)
                }
                .disabled(viewStore.isLoading || viewStore.registerEmail.isEmpty || viewStore.registerPassword.isEmpty || viewStore.registerFirstName.isEmpty || viewStore.registerLastName.isEmpty)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    AuthView(store: Store(initialState: AuthFeature.State()) {
        AuthFeature()
    })
}
