const express = require('express');
const path = require('path');

const app = express();
const port = 3000;

// Using the express.static middleware to serve static files from the /dist directory
app.use(express.static(path.join(__dirname, 'dist')));

// Route to serve the index.html file when accessing the root path
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// Running the Express server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}/`);
});