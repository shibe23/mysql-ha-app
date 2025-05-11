import express from 'express';
import pool from './db.js';

const app = express();
app.use(express.json());

app.post('/users', async (req, res) => {
  const { email, name } = req.body;
  try {
    const [result] = await pool.execute(
      'INSERT INTO users (email, name) VALUES (?, ?)',
      [email, name]
    );
    res.status(201).json({ id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'User creation failed' });
  }
});

app.get('/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, email, name, created_at FROM users');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'User fetch failed' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
