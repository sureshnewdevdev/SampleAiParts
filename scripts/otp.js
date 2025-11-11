(function () {
  const form = document.getElementById("otp-form");
  const feedback = document.getElementById("otp-feedback");

  function showMessage(message, type) {
    feedback.textContent = message;
    feedback.className = `feedback ${type}`;
  }

  const otp = sessionStorage.getItem("mfa-otp");

  if (!otp) {
    showMessage(
      "No OTP found. Please verify your email first to generate a code.",
      "error"
    );
  }

  form?.addEventListener("submit", (event) => {
    event.preventDefault();
    const enteredOtp = new FormData(form).get("otp");

    if (enteredOtp === otp) {
      sessionStorage.setItem("mfa-otp-verified", "true");
      showMessage("OTP verified! You have completed the MFA flow.", "success");
    } else {
      showMessage("That code doesn't match. Check the email page for the latest OTP.", "error");
    }
  });
})();
