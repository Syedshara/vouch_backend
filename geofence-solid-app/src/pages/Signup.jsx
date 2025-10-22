import { createSignal } from "solid-js";
import { useNavigate } from "@solidjs/router";
import { authHelpers } from "../lib/supabase";

export default function Signup() {
  const [businessName, setBusinessName] = createSignal("");
  const [email, setEmail] = createSignal("");
  const [password, setPassword] = createSignal("");
  const [confirmPassword, setConfirmPassword] = createSignal("");
  const [error, setError] = createSignal(null);
  const [isLoading, setIsLoading] = createSignal(false);
  const [success, setSuccess] = createSignal(false);
  const navigate = useNavigate();

  const handleSignup = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    if (password() !== confirmPassword()) {
      setError("Passwords do not match");
      setIsLoading(false);
      return;
    }

    if (password().length < 6) {
      setError("Password must be at least 6 characters");
      setIsLoading(false);
      return;
    }

    const { data, error: authError } = await authHelpers.signUp(
      email(),
      password(),
      businessName()
    );

    if (authError) {
      setError(authError.message);
      setIsLoading(false);
      return;
    }

    setSuccess(true);
    setTimeout(() => navigate("/login"), 3000);
  };

  return (
    <div class="auth-container">
      <div class="auth-card">
        {success() ? (
          <div class="success-container">
            <div class="success-icon">✓</div>
            <h2 class="success-title">Account Created!</h2>
            <p class="success-message">
              Please check your email to verify your account. Redirecting to
              login...
            </p>
          </div>
        ) : (
          <>
            <div class="auth-header">
              <h1 class="auth-title">Create Your Account</h1>
              <p class="auth-subtitle">
                Start managing your business with Vouch
              </p>
            </div>

            <form onSubmit={handleSignup} class="auth-form">
              <div class="form-group">
                <label for="businessName" class="form-label">
                  Business Name
                </label>
                <input
                  id="businessName"
                  type="text"
                  class="form-input"
                  placeholder="My Coffee Shop"
                  value={businessName()}
                  onInput={(e) => setBusinessName(e.target.value)}
                  required
                />
              </div>

              <div class="form-group">
                <label for="email" class="form-label">
                  Email
                </label>
                <input
                  id="email"
                  type="email"
                  class="form-input"
                  placeholder="you@business.com"
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
                  placeholder="At least 6 characters"
                  value={password()}
                  onInput={(e) => setPassword(e.target.value)}
                  required
                />
              </div>

              <div class="form-group">
                <label for="confirmPassword" class="form-label">
                  Confirm Password
                </label>
                <input
                  id="confirmPassword"
                  type="password"
                  class="form-input"
                  value={confirmPassword()}
                  onInput={(e) => setConfirmPassword(e.target.value)}
                  required
                />
              </div>

              {error() && <div class="error-message">{error()}</div>}

              <button type="submit" class="btn-primary" disabled={isLoading()}>
                {isLoading() ? "Creating account..." : "Create Account"}
              </button>

              <div class="auth-footer">
                Already have an account?{" "}
                <a href="/login" class="auth-link">
                  Sign in
                </a>
              </div>
            </form>
          </>
        )}
      </div>
    </div>
  );
}
