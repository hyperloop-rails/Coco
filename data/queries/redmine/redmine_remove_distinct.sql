SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.status = $1 AND (members.project_id = 1) AND users.status = $2 AND users.status = $3 AND users.type IN ($4, $5) ORDER BY users.type DESC, users.firstname, users.lastname, users.id
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (LOWER(email_addresses.address) IN ('testuser@example.org'))
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 5)
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND (LOWER(email_addresses.address) IN ('dlopper@somenet.foo')) ORDER BY users.id ASC LIMIT $3
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.status = $1 AND (members.project_id = 1) AND users.status = $2 AND users.status = $3 AND users.type IN ($4, $5) LIMIT $6
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 4)
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.status = $1 AND (members.project_id = 1) AND users.status = $2 AND users.status = $3 AND users.type IN ($4, $5)
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND (LOWER(email_addresses.address) IN ('foo@bar.net')) ORDER BY users.id ASC LIMIT $3
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 3)
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 1)
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (LOWER(email_addresses.address) IN ('r@mycompanyname.com'))
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 2)
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND (LOWER(email_addresses.address) IN ('jdoe@example.net')) ORDER BY users.id ASC LIMIT $3
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.status = $1 AND (members.project_id = 1) AND users.status = $2 AND users.type IN ($3, $4) LIMIT $5
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND (LOWER(email_addresses.address) IN ('jsmith@somenet.foo')) ORDER BY users.id ASC LIMIT $3
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (LOWER(email_addresses.address) IN ('redmine@somenet.foo','dlopper@somenet.foo'))
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 50) ORDER BY users.firstname, users.lastname, users.id
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 6)
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 8) ORDER BY users.firstname, users.lastname, users.id
SELECT DISTINCT users.* FROM users INNER JOIN members ON members.user_id = users.id WHERE users.type IN ($1, $2) AND users.status = $3 AND (members.project_id = 2) ORDER BY users.firstname, users.lastname, users.id
SELECT DISTINCT users.* FROM users INNER JOIN email_addresses ON email_addresses.user_id = users.id WHERE users.type IN ($1, $2) AND (LOWER(email_addresses.address) IN ('foo@example.com')) ORDER BY users.id ASC LIMIT $3