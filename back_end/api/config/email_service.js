const nodemailer = require('nodemailer');

class EmailService {
    constructor() {
        this.transporter = nodemailer.createTransport({
            host: process.env.SMTP_HOST,
            port: process.env.SMTP_PORT,
            secure: process.env.SMTP_SECURE === 'true',
            auth: {
                user: process.env.SMTP_USER,
                pass: process.env.SMTP_PASSWORD,
            },
        });

        this.transporter.verify(function (error, success) {
            if (error) {
                console.log('SMTP Verify Error:', error);
            } else {
                console.log('Server is ready to take our messages');
            }
        });
    }

    async sendNewPasswordEmail(email, newPassword) {
        const mailOptions = {
            from: `"${process.env.EMAIL_FROM_NAME}" <${process.env.EMAIL_FROM_ADDRESS}>`,
            to: email,
            subject: 'Your New Password',
            html: `
                <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                    <h2 style="color: #333; text-align: center;">Your New Password</h2>
                    <p>Here is your new password to login to your account:</p>
                    <div style="text-align: center; margin: 30px 0;">
                        <p style="font-size: 24px; font-weight: bold; color: #4CAF50;">
                            ${newPassword}
                        </p>
                    </div>
                    <p>Please use this password to login to your account. We recommend changing your password after logging in.</p>
                    <hr style="border: 1px solid #eee; margin: 20px 0;">
                    <p style="color: #666; font-size: 12px; text-align: center;">
                        For security reasons, please change this password immediately after logging in.
                    </p>
                </div>
            `
        };

        try {
            await this.transporter.sendMail(mailOptions);
            console.log(mailOptions);
            console.log('Email sent successfully');
            return { success: true, message: 'New password email sent successfully' };
        } catch (error) {
            console.error('Send Email Error:', {
                error: error.message,
                stack: error.stack,
                code: error.code
            });
            throw new Error(`Failed to send new password email: ${error.message}`);
        }
    }
}

const emailService = new EmailService();
module.exports = emailService;
