const express = require('express');
const cors = require('cors'); // Cross-Origin Resource Sharing
const { exec } = require('child_process');
const path = require('path');
const app = express();
const port = 3000;

// Allow requests from localhost:8080
app.use(cors({
    origin: 'http://localhost:8080',
    methods: ['GET', 'POST'],
}));

app.use(express.json()); // Parse JSON data
app.use(express.static(path.join(__dirname, 'public'))); // Resolves pathing issues

// Endpoint 1: Email Sending
app.post('/send-email', (req, res) => {
    const { recipient, subject, text } = req.body;

    if (!recipient || !subject || !text) {
        return res.status(400).send('Missing email data!');
    }

    const sendEmailScriptPath = path.join(__dirname, 'sendEmail.js');
    const command = `node "${sendEmailScriptPath}" "${recipient}" "${subject}" "${text}"`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error.message}`);
            return res.status(500).send('Failed to send email.');
        }

        if (stderr) {
            console.error(`Stderr: ${stderr}`);
            return res.status(500).send('Error in email script.');
        }

        console.log(`Output: ${stdout}`);
        res.send('Email sent successfully!');
    });
});

// Endpoint 2: Like Registration Query Execution
app.post('/run-query', (req, res) => {
    const query = req.body.query;

    if (!query) {
        return res.status(400).send({ error: "Query is required" });
    }

    const registerLikePath = path.join(__dirname, 'registerLike.js');
    const command = `node "${registerLikePath}" "${query}"`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error.message}`);
            return res.status(500).send({ error: error.message });
        }
        if (stderr) {
            console.error(`Stderr: ${stderr}`);
            return res.status(500).send({ error: stderr });
        }
        console.log(`Output:\n${stdout}`);
        res.send({ output: stdout });
    });
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
