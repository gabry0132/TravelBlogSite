const sgMail = require('@sendgrid/mail');

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

const sendEmail = (recipient, subject, text) => {
    const msg = {
        to: recipient,
        from: 'blogsite.renraku@gmail.com', // Make sure this is a verified email in SendGrid
        subject: subject,
        text: text,
    };

    console.log("Sending email to:", recipient); // Log recipient for debugging
    console.log("Subject:", subject); // Log subject for debugging

    sgMail
        .send(msg)
        .then(() => {
            console.log('Email sent successfully');
        })
        .catch((error) => {
            console.error('Error sending email:', error);
        });
};

const [,, recipient, subject, text] = process.argv;

if (!recipient || !subject || !text) {
    console.log("Missing parameters!");
} else {
    sendEmail(recipient, subject, text);
}
