import { createSignal, Show } from "solid-js";
import { useNavigate } from "@solidjs/router";
import { authHelpers } from "../lib/supabase";
import OtpInput from "../components/OtpInput";

export default function Login() {
  const [email, setEmail] = createSignal("");
  const [password, setPassword] = createSignal("");
  const [otp, setOtp] = createSignal("");
  const [isLoading, setIsLoading] = createSignal(false);
  const [error, setError] = createSignal(null);
  const [step, setStep] = createSignal("password");

  const navigate = useNavigate();

  const handlePasswordLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    const { error: passwordError } = await authHelpers.signInWithPassword(
      email(),
      password()
    );
    if (passwordError) {
      setError(passwordError.message);
      setIsLoading(false);
    } else {
      const { error: otpSendError } = await authHelpers.sendSignInOtp(email());
      if (otpSendError) {
        setError(otpSendError.message);
        setIsLoading(false);
      } else {
        setStep("otp");
        setIsLoading(false);
      }
    }
  };

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    const { data, error: otpError } = await authHelpers.verifySignInOtp(
      email(),
      otp()
    );
    if (otpError) {
      setError(otpError.message);
      setIsLoading(false);
    } else if (data.session) {
      navigate("/");
    } else {
      setError("An unknown error occurred during OTP verification.");
      setIsLoading(false);
    }
  };

  return (
    <div class="auth-container">
      <div class="auth-card">
        <Show
          when={step() === "password"}
          fallback={
            <>
              {/* OTP View */}
              <div class="auth-header">
                <h1 class="auth-title">Check Your Email</h1>
                <p class="auth-subtitle">
                  We've sent a 6-digit code to {email()}.
                </p>
              </div>
              <form onSubmit={handleVerifyOtp} class="auth-form">
                <div class="form-group">
                  <label for="otp" class="form-label">
                    Verification Code
                  </label>
                  <OtpInput value={otp} onInput={setOtp} />
                </div>
                {error() && <div class="error-message">{error()}</div>}
                <button
                  type="submit"
                  class="btn-primary"
                  disabled={isLoading()}
                >
                  {isLoading() ? "Verifying..." : "Sign In"}
                </button>
              </form>
            </>
          }
        >
          <>
            {/* Password View */}
            <div class="auth-header">
              <h1 class="auth-title">Welcome Back</h1>
            </div>
            <form onSubmit={handlePasswordLogin} class="auth-form">
              <div class="form-group">
                <label for="email" class="form-label">
                  Email
                </label>
                <input
                  id="email"
                  type="email"
                  class="form-input"
                  value={email()}
                  onInput={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              <div class="form-group">
                <label for="password" class="form-label">
                  Password
                </label>
                <input
                  id="password"
                  type="password"
                  class="form-input"
                  value={password()}
                  onInput={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
              {error() && <div class="error-message">{error()}</div>}
              <button type="submit" class="btn-primary" disabled={isLoading()}>
                {isLoading() ? "Continuing..." : "Continue"}
              </button>

              {/* --- THIS IS THE NEW CODE --- */}
              <div class="auth-footer">
                Don't have an account?{" "}
                <a href="/signup" class="auth-link">
                  Sign Up
                </a>
              </div>
              {/* --- END OF NEW CODE --- */}
            </form>
          </>
        </Show>
      </div>
    </div>
  );
}
