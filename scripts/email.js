(function () {
  const EXPECTED_EMAIL = "abc@gmail.com";
  const form = document.getElementById("email-form");
  const feedback = document.getElementById("email-feedback");

  function showMessage(message, type) {
    feedback.innerHTML = message;
    feedback.className = `feedback ${type}`;
  }

  function generateOtp() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  form?.addEventListener("submit", (event) => {
    event.preventDefault();
    const email = new FormData(form).get("email");

    if (typeof email === "string" && email.trim().toLowerCase() === EXPECTED_EMAIL) {
      const otp = generateOtp();
      sessionStorage.setItem("mfa-email", "true");
      sessionStorage.setItem("mfa-otp", otp);

      showMessage(
        `Email confirmed!<br />A demo OTP <strong>${otp}</strong> has been generated for testing. Proceed to the OTP page to finish the flow.`,
        "success"
      );
    } else {
      showMessage(
        "That email doesn't match our demo record. Please use <strong>abc@gmail.com</strong>.",
        "error"
      );
    }
  });
})();
