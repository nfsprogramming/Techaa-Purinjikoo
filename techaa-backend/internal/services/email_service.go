package services

import (
	"fmt"
	"net/smtp"
	"strings"

	"techaa-backend/internal/config"
	"techaa-backend/internal/logger"
)

type EmailService struct {
	cfg *config.Config
}

func NewEmailService(cfg *config.Config) *EmailService {
	return &EmailService{cfg: cfg}
}

// SendOTPEmail sends a custom branded dark AMOLED HTML verification email with 6-digit OTP
func (s *EmailService) SendOTPEmail(recipientEmail string, otpCode string, purpose string) error {
	subject := fmt.Sprintf("Your Techaa Purinjikoo Verification Code: %s", otpCode)
	if purpose == "reset_password" {
		subject = fmt.Sprintf("Reset Your Password: %s (Techaa Purinjikoo)", otpCode)
	}

	htmlBody := s.renderOTPTemplate(otpCode, purpose)

	// If no SMTP configured, log to console in dev mode
	if s.cfg.SMTPHost == "" || s.cfg.SMTPPort == "" {
		logger.Log.Info("📧 [DEV EMAIL MOCK] Custom OTP Email generated",
			"to", recipientEmail,
			"otp", otpCode,
			"purpose", purpose,
			"sender", s.cfg.SMTPSenderName,
		)
		return nil
	}

	fromHeader := fmt.Sprintf("%s <%s>", s.cfg.SMTPSenderName, s.cfg.SMTPFrom)
	headers := make(map[string]string)
	headers["From"] = fromHeader
	headers["To"] = recipientEmail
	headers["Subject"] = subject
	headers["MIME-Version"] = "1.0"
	headers["Content-Type"] = "text/html; charset=UTF-8"

	var message strings.Builder
	for k, v := range headers {
		message.WriteString(fmt.Sprintf("%s: %s\r\n", k, v))
	}
	message.WriteString("\r\n" + htmlBody)

	auth := smtp.PlainAuth("", s.cfg.SMTPUser, s.cfg.SMTPPass, s.cfg.SMTPHost)
	addr := fmt.Sprintf("%s:%s", s.cfg.SMTPHost, s.cfg.SMTPPort)

	err := smtp.SendMail(addr, auth, s.cfg.SMTPFrom, []string{recipientEmail}, []byte(message.String()))
	if err != nil {
		logger.Log.Error("Failed to send SMTP email", "error", err, "recipient", recipientEmail)
		return err
	}

	logger.Log.Info("Custom branded OTP email sent successfully", "to", recipientEmail)
	return nil
}

func (s *EmailService) renderOTPTemplate(otpCode string, purpose string) string {
	headerTitle := "Secure Login Code"
	actionText := "sign in to your Techaa Purinjikoo account via email"
	if purpose == "reset_password" {
		headerTitle = "Password Reset Code"
		actionText = "reset the password for your Techaa Purinjikoo account"
	} else if purpose == "verification" {
		headerTitle = "Secure Verification Code"
		actionText = "verify your email for your Techaa Purinjikoo account"
	}

	// Format code with spaces for beautiful display like "2 9 7 8 8 0"
	var formattedCode strings.Builder
	for i, r := range otpCode {
		if i > 0 {
			formattedCode.WriteString(" ")
		}
		formattedCode.WriteRune(r)
	}

	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>%s</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #000000;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      color: #FFFFFF;
      -webkit-font-smoothing: antialiased;
    }
    .wrapper {
      width: 100%%;
      table-layout: fixed;
      background-color: #000000;
      padding: 48px 16px;
    }
    .card {
      max-width: 480px;
      margin: 0 auto;
      background: #0A0A0F;
      border: 1.5px solid rgba(225, 29, 72, 0.35);
      border-radius: 24px;
      overflow: hidden;
      box-shadow: 0 24px 60px rgba(0, 0, 0, 0.9), 0 0 40px rgba(225, 29, 72, 0.15);
    }
    .header-banner {
      background: linear-gradient(180deg, #1A050A 0%%, #0A0A0F 100%%);
      padding: 40px 24px 20px 24px;
      text-align: center;
      border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    }
    .logo-img {
      width: 68px;
      height: 68px;
      border-radius: 18px;
      border: 2px solid #E11D48;
      display: block;
      margin: 0 auto 16px auto;
      box-shadow: 0 0 25px rgba(225, 29, 72, 0.5);
    }
    .header-title {
      font-size: 24px;
      font-weight: 800;
      color: #FFFFFF;
      margin: 0;
      letter-spacing: -0.5px;
    }
    .content-body {
      padding: 32px 32px 36px 32px;
      color: #CBD5E1;
      font-size: 14.5px;
      line-height: 1.6;
      text-align: left;
    }
    .greeting {
      font-size: 16px;
      font-weight: 700;
      color: #FFFFFF;
      margin-bottom: 12px;
    }
    .message-text {
      margin: 0 0 26px 0;
      color: #94A3B8;
    }
    .highlight {
      color: #FFFFFF;
      font-weight: 600;
    }
    .otp-box {
      background: #140508;
      border: 2px dashed #E11D48;
      border-radius: 16px;
      padding: 22px 16px;
      text-align: center;
      margin: 0 0 14px 0;
      box-shadow: inset 0 0 20px rgba(225, 29, 72, 0.15);
    }
    .otp-digits {
      font-size: 38px;
      font-weight: 900;
      color: #FF2E54;
      font-family: 'SF Pro Display', -apple-system, BlinkMacSystemFont, 'Courier New', Courier, monospace;
      letter-spacing: 10px;
      margin: 0;
      text-shadow: 0 0 20px rgba(255, 46, 84, 0.5);
    }
    .expiry-note {
      font-size: 12.5px;
      color: #FDA4AF;
      font-weight: 500;
      text-align: center;
      margin: 0 0 26px 0;
    }
    .divider {
      height: 1px;
      background: rgba(255, 255, 255, 0.08);
      margin: 24px 0;
    }
    .security-note {
      font-size: 12.5px;
      color: #64748B;
      margin: 0 0 20px 0;
      line-height: 1.5;
    }
    .signature {
      font-size: 13.5px;
      color: #94A3B8;
      line-height: 1.6;
    }
    .team-name {
      font-weight: 700;
      color: #FFFFFF;
    }
    .brand-sub {
      color: #E11D48;
      font-size: 12px;
      font-weight: 600;
      margin-top: 4px;
    }
    .dots {
      color: #334155;
      letter-spacing: 2px;
      margin-top: 14px;
      font-size: 14px;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="card">
      <div class="header-banner">
        <img src="https://ztjzwplikwhdnwmvrnej.supabase.co/storage/v1/object/public/Logo/logo.png" class="logo-img" alt="Techaa Purinjikoo" />
        <h1 class="header-title">%s</h1>
      </div>
      
      <div class="content-body">
        <div class="greeting">Vanakkam & Hello,</div>
        <div class="message-text">
          You recently requested to %s. Please use the secure 6-digit verification code below:
        </div>

        <div class="otp-box">
          <div class="otp-digits">%s</div>
        </div>

        <div class="expiry-note">⏱️ Expires in <strong style="color: #FF2E54;">5 minutes</strong></div>

        <div class="divider"></div>

        <div class="security-note">
          If you did not request this code, you can safely ignore this email.
        </div>

        <div class="signature">
          Best regards,<br>
          <span class="team-name">The Techaa Purinjikoo Team</span>
          <div class="brand-sub">☕ Tech-ah friend solra maathiri purinjikalam!</div>
          <div class="dots">• • •</div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>`, headerTitle, headerTitle, actionText, formattedCode.String())
}
