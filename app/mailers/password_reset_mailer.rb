class PasswordResetMailer < ApplicationMailer
    def password_reset(user)
        mail(
            to: user.email,
            subject: "Time for a new password!"
        )
    end
end
