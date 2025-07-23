-- Count users
SELECT COUNT(*) FROM users;

-- Top domains
SELECT SPLIT_PART(email, '@', 2) AS domain, COUNT(*) AS total
FROM users
GROUP BY domain
ORDER BY total DESC;
