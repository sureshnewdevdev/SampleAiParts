(function () {
  const PASSWORD = "1234";
  const form = document.getElementById("login-form");
  const feedback = document.getElementById("login-feedback");

  function showMessage(message, type) {
    feedback.textContent = message;
    feedback.className = `feedback ${type}`;
  }

  form?.addEventListener("submit", (event) => {
    event.preventDefault();
    const password = new FormData(form).get("password");

    if (password === PASSWORD) {
      sessionStorage.setItem("mfa-login", "true");
      showMessage(
        "Login successful! Continue with email verification to receive your OTP.",
        "success"
      );
    } else {
      showMessage("Incorrect password. Hint: it's 1234 for this demo.", "error");
    }
  });
})();
