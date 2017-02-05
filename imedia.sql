-- import dataset

COPY public.listens FROM '/Applications/listens.tsv' DELIMITER E'\t'

COPY public.users FROM '/Applications/users.csv' DELIMITER ','

COPY public.artists FROM '/Applications/artists.tsv' DELIMITER E'\t'

-- count all users
SELECT count(*)
    FROM public.users 
    
-- count active users
SELECT count( DISTINCT profile_id)
    FROM public.listens 
    
-- count average age of active users
SELECT AVG (U.age)
FROM public.listens AS L, public.users AS U 
WHERE L.profile_id = U.profile_id AND U.age <> 0

-- count average age of inactive users
SELECT AVG (U.age)
FROM public.users AS U
WHERE U.profile_id NOT IN(SELECT L.profile_id
                    FROM public.listens AS L
                    WHERE L.profile_id = U.profile_id) and U.age <> 0
                    
-- SELECT AR.genre, U.gender, U.age
-- FROM public.listens AS L, public.users AS U, public.artists AS AR
-- WHERE L.profile_id = U.profile_id AND L.artist_seed = AR.artist_id AND U.age <> 0

-- top 10 genre among female
CREATE TABLE FG (genre,num) AS (SELECT AR.genre, count(*)
FROM public.listens AS L, public.users AS U, public.artists AS AR
WHERE L.profile_id = U.profile_id AND L.artist_seed = AR.artist_id
      AND U.age <> 0 AND U.gender='FEMALE' AND AR.genre <> 'NA'
Group by AR.genre
ORDER BY count(*) DESC
LIMIT 10)

COPY FG TO '/tmp/fg.csv' DELIMITER ',' CSV HEADER;

-- top 10 genre among male
CREATE TABLE MG (genre,num) AS (SELECT AR.genre, count(*)
FROM public.listens AS L, public.users AS U, public.artists AS AR
WHERE L.profile_id = U.profile_id AND L.artist_seed = AR.artist_id
      AND U.age <> 0 AND U.gender='MALE' AND AR.genre <> 'NA'
Group by AR.genre
ORDER BY count(*) DESC
LIMIT 10)

COPY MG TO '/tmp/mg.csv' DELIMITER ',' CSV HEADER;

-- top 10 genre among different age ranges with age interval of 20
CREATE TABLE AG (genre,age20,age40,age60,age80,age100) AS
SELECT AR.genre, count(*) filter (where U.age<20) as "0<=age<20" ,
        count(*) filter (where U.age>=20 and U.age<40) as "20=<age<40",
        count(*) filter (where U.age>=40 and U.age<60) as "40=<age<60",
        count(*) filter (where U.age>=60 and U.age<80) as "60=<age<80",
        count(*) filter (where U.age>=80 and U.age<100) as "80=<age<100"
FROM public.listens AS L, public.users AS U, public.artists AS AR
WHERE L.profile_id = U.profile_id AND L.artist_seed = AR.artist_id
      AND U.age <> 0 AND AR.genre <> 'NA'
Group by AR.genre
Order by count(*)
LIMIT 10

-- top 10 genre between 20<=age<40 separate between female and male
CREATE TABLE AGE20 (genre,FEMALE,MALE) AS
SELECT AR.genre, count(*) filter (where U.gender='FEMALE') as "FEMALE" ,
    count(*) filter (where U.gender='MALE') as "MALE" 
FROM public.listens AS L, public.users AS U, public.artists AS AR
WHERE L.profile_id = U.profile_id AND L.artist_seed = AR.artist_id
      AND AR.genre <> 'NA' AND U.gender <> 'NA' and U.age>=20 and U.age<40
Group by AR.genre
Order by count(*) DESC
LIMIT 10

COPY AGE20 TO '/tmp/age20.csv' DELIMITER ',' CSV HEADER;