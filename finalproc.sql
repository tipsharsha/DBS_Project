--Create a new user

CREATE OR REPLACE PROCEDURE create_new_user(
    name_in IN VARCHAR2,
    email_in IN VARCHAR2,
    bio_in IN VARCHAR2,
    password_in IN VARCHAR2,
    user_id_out OUT NUMBER
)
IS
    user_id NUMBER;
BEGIN
    INSERT INTO users(username, bio, email, passkey)
    VALUES (name_in, bio_in, email_in, password_in)
    RETURNING user_id INTO user_id;

    INSERT INTO login(user_id)
    VALUES (user_id);
    
    DBMS_OUTPUT.PUT_LINE('User Created with ID: ' || user_id);

    user_id_out := user_id;

    COMMIT;
END;
/


-- procedure to create a new login

CREATE OR REPLACE PROCEDURE create_new_login(
    email_in IN VARCHAR2,
    password_in IN VARCHAR2,
    user_id_out OUT NUMBER
)
IS
    user_id_int NUMBER;
BEGIN
    SELECT user_id INTO user_id_int
    FROM users
    WHERE email = email_in AND passkey = password_in;

    INSERT INTO login(user_id)
    VALUES(user_id_int)
    RETURNING user_id INTO user_id_out;
END;
/


-- Retrieve all posts for a userfeed

CREATE OR REPLACE PROCEDURE show_user_feed (
    user_id_in IN NUMBER,
    posts_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN posts_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        JOIN follows f ON u.user_id = f.followee_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        WHERE f.follower_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at,
                 ph.photo_url, v.video_url, u.username, u.profile_photo_url
        ORDER BY p.created_at DESC;
END;
/


--Procedure to show feed with his/her followed hashtags

CREATE OR REPLACE PROCEDURE show_user_feed_with_followed_hashtags(
    user_id_in IN NUMBER,
    page_size IN NUMBER DEFAULT 10,
    page_number IN NUMBER DEFAULT 1,
    feed_cursor OUT SYS_REFCURSOR
)
IS
    offset_rows NUMBER;
BEGIN
    offset_rows := (page_number - 1) * page_size;

    OPEN feed_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        JOIN post_tags pt ON p.post_id = pt.post_id
        JOIN hashtag_follow hf ON pt.hashtag_id = hf.hashtag_id
        WHERE hf.user_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at, ph.photo_url, v.video_url, u.username, u.profile_photo_url
        ORDER BY p.created_at DESC
        OFFSET offset_rows ROWS FETCH NEXT page_size ROWS ONLY;
END;
/


--Retrieve all posts in user followed hashtags

CREATE OR REPLACE PROCEDURE retrieve_posts_by_followed_hashtags (
    user_id_in IN NUMBER,
    posts_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN posts_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        JOIN post_tags pt ON p.post_id = pt.post_id
        JOIN hashtag_follow hf ON pt.hashtag_id = hf.hashtag_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        WHERE hf.user_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at,
                 ph.photo_url, v.video_url, u.username, u.profile_photo_url
        ORDER BY p.created_at DESC;
END;
/


--POST DETAILS WITH COMMENTS
--Retreive details of post

CREATE OR REPLACE PROCEDURE show_post_details (
    post_id_in IN NUMBER,
    post_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN post_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        WHERE p.post_id = post_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at,
                 ph.photo_url, v.video_url, u.username, u.profile_photo_url;
END;
/


-- Retrieve all comments for a post with likes

CREATE OR REPLACE PROCEDURE show_comments_for_post (
    post_id_in IN NUMBER,
    comments_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN comments_cursor FOR
        SELECT c.comment_id, c.comment_text, c.created_at,
               u.user_id, u.username, u.profile_photo_url,
               COUNT(cl.user_id) AS likes
        FROM comments c
        JOIN users u ON c.user_id = u.user_id
        LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id
        WHERE c.post_id = post_id_in
        GROUP BY c.comment_id, c.comment_text, c.created_at,
                 u.user_id, u.username, u.profile_photo_url
        ORDER BY c.created_at DESC;
END;
/


--PROCEDURE TO like a post

CREATE OR REPLACE PROCEDURE like_post(
    post_id_in IN NUMBER,
    user_id_in IN NUMBER   
)
IS
    like_id NUMBER;
BEGIN
    INSERT INTO post_likes(user_id, post_id)
    VALUES(user_id_in, post_id_in)
    RETURNING user_id INTO like_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Post Liked with ID: ' || like_id);
END;
/


-- Procedure to show unlike on a post

CREATE OR REPLACE PROCEDURE unlike_post(
    post_id_in IN NUMBER,
    user_id_in IN NUMBER
)
IS
BEGIN
    DELETE FROM post_likes
    WHERE user_id = user_id_in AND post_id = post_id_in;
    
    COMMIT;
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No like found for the specified user and post.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Like Removed');
    END IF;
END;
/


-- Procedure to show create a new like on a comment

CREATE OR REPLACE PROCEDURE like_comment(
    user_id_in IN NUMBER,
    comment_id_in IN NUMBER
)
IS
    like_id NUMBER;
BEGIN
    INSERT INTO comment_likes(user_id, comment_id)
    VALUES(user_id_in, comment_id_in)
    RETURNING user_id INTO like_id;

    DBMS_OUTPUT.PUT_LINE('Comment Liked with ID: ' || like_id);
END;
/


-- Retrieve all hashtags for a post
CREATE OR REPLACE PROCEDURE show_hashtags_for_post (
    post_id_in IN NUMBER,
    hashtags_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN hashtags_cursor FOR
        SELECT h.hashtag_id, h.hashtag_name
        FROM hashtags h
        JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
        WHERE pt.post_id = post_id_in;
END;
/


--Procedure to show add a comment to a post

CREATE OR REPLACE PROCEDURE add_comment_to_post(
    post_id_in IN NUMBER,
    user_id_in IN NUMBER,    
    comment_text_in IN VARCHAR2,
    comments_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    INSERT INTO comments(comment_text, post_id, user_id)
    VALUES(comment_text_in, post_id_in, user_id_in);


    DBMS_OUTPUT.PUT_LINE('Comment Added to Post');
END;


--PROFILE PAGE 
--procedure to get user details

CREATE OR REPLACE PROCEDURE show_user_info(
    user_id_in IN NUMBER,
    user_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN user_cursor FOR
        SELECT user_id,username,profile_photo_url,bio,created_at,email
        FROM users
        WHERE user_id = user_id_in;
END;
/


-- show user posts 

CREATE OR REPLACE PROCEDURE show_user_posts(
    user_id_in IN NUMBER,
    post_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN post_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        WHERE p.user_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at, ph.photo_url, v.video_url, u.username, u.profile_photo_url;
END;
/


-- Procedure to show user his/her followers

CREATE OR REPLACE PROCEDURE show_user_followers(
    user_id_in IN NUMBER,
    followers_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN followers_cursor FOR
        SELECT u.user_id AS follower_id, u.username, u.profile_photo_url, u.created_at
        FROM users u
        WHERE u.user_id IN (
            SELECT f.follower_id
            FROM follows f
            WHERE f.followee_id = user_id_in
        );
END;
/


-- Procedure to show user his/her followees

CREATE OR REPLACE PROCEDURE show_user_followees(
    user_id_in IN NUMBER,
    followees_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN followees_cursor FOR
        SELECT u.user_id AS followee_id, u.username, u.profile_photo_url, u.created_at
        FROM users u
        WHERE u.user_id IN (
            SELECT f.followee_id
            FROM follows f
            WHERE f.follower_id = user_id_in
        );
END;
/


-- Procedure to get post details

CREATE OR REPLACE PROCEDURE get_post_details(
    post_details_cursor OUT SYS_REFCURSOR
) 
IS
BEGIN
    OPEN post_details_cursor FOR
        SELECT 
            p.post_id,
            p.caption,
            p.created_at,
            ph.photo_url,
            v.video_url,
            COUNT(pl.user_id) AS like_count,
            u.username,
            u.profile_photo_url
        FROM 
            post p
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        JOIN users u ON pl.user_id = u.user_id
        GROUP BY 
            p.post_id, p.caption, p.created_at, ph.photo_url, v.video_url, u.username, u.profile_photo_url;
END;
/


--procedure to show user liked post

CREATE OR REPLACE PROCEDURE show_user_liked_posts(
    user_id_in IN NUMBER,
    likedposts_cursor OUT SYS_REFCURSOR
) 
IS
BEGIN
    OPEN likedposts_cursor FOR
        SELECT 
            p.post_id,
            p.caption,
            p.created_at,
            ph.photo_url,
            v.video_url,    
            (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.post_id) AS like_count,
            u.username,
            u.profile_photo_url
        FROM 
            post p
            JOIN post_likes pl ON p.post_id = pl.post_id
            JOIN users u ON p.user_id = u.user_id
            LEFT JOIN photos ph ON p.post_id = ph.post_id
            LEFT JOIN videos v ON p.post_id = v.post_id
        WHERE 
            pl.user_id = user_id_in;

END;
/


--Procedure to show user his/her followed hashtags

CREATE OR REPLACE PROCEDURE show_user_followed_hashtags(
    user_id_in IN NUMBER,
    hashtag_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN hashtag_cursor FOR
        SELECT h.hashtag_id, h.hashtag_name, h.created_at
        FROM hashtags h
        JOIN hashtag_follow hf ON h.hashtag_id = hf.hashtag_id
        WHERE hf.user_id = user_id_in;
END;
/

--Procedure to create a new post

CREATE OR REPLACE PROCEDURE create_new_post(
    user_id_in IN NUMBER,
    caption_in IN VARCHAR2,
    postid_out OUT NUMBER
)
IS
    post_id NUMBER;
BEGIN
    INSERT INTO post(user_id, caption)
    VALUES(user_id_in, caption_in)
    RETURNING post_id INTO postid_out;

    DBMS_OUTPUT.PUT_LINE('Post Created with ID: ' || postid_out);
END;
/

--Procedure to show add a video to a post

CREATE OR REPLACE PROCEDURE add_video_to_post(
    post_id_in IN NUMBER,
    video_url_in IN VARCHAR2
)
IS
    video_id NUMBER;
BEGIN
    INSERT INTO videos(video_url, post_id)
    VALUES(video_url_in, post_id_in)
    RETURNING video_id INTO video_id;

    DBMS_OUTPUT.PUT_LINE('Video Added with ID: ' || video_id);
END;
/

--Procedure to show add a photo to a post

CREATE OR REPLACE PROCEDURE add_photo_to_post(
    post_id_in IN NUMBER,
    photo_url_in IN VARCHAR2
)
IS
    photo_id NUMBER;
BEGIN
    INSERT INTO photos(photo_url, post_id)
    VALUES(photo_url_in, post_id_in)
    RETURNING photo_id INTO photo_id;

    DBMS_OUTPUT.PUT_LINE('Photo Added with ID: ' || photo_id);
END;
/


--Procedure to show add a location to a post

CREATE OR REPLACE PROCEDURE add_location_to_post(
    post_id_in IN NUMBER,
    location_in IN VARCHAR2
)
IS
BEGIN
    INSERT INTO location(location_name, post_id)
    VALUES(location_in, post_id_in);

    DBMS_OUTPUT.PUT_LINE('Location Added to Post');
END;
/
--users page
-- SHOW_USERS_NOT_FOLLOWED
CREATE OR REPLACE PROCEDURE show_users_not_followed(
    user_id_in IN NUMBER,
    users_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN users_cursor FOR
        SELECT u.user_id, u.username, u.profile_photo_url, u.bio, u.created_at,u.email
        FROM users u
        WHERE u.user_id NOT IN (
            SELECT f.followee_id
            FROM follows f
            WHERE f.follower_id = user_id_in
        );
END;
/

--follow a user
CREATE OR REPLACE PROCEDURE follow_user(
    follower_id_in IN NUMBER,
    followee_id_in IN NUMBER
)
IS
    follow_id NUMBER;
BEGIN
    INSERT INTO follows(follower_id, followee_id)
    VALUES(follower_id_in, followee_id_in)
    RETURNING follow_id INTO follow_id;

    DBMS_OUTPUT.PUT_LINE('User Followed with ID: ' || follow_id);
END;
/

--EXPLORE HASHTAGS PAGE
--Procedure to show user his/her not followed hashtags

CREATE OR REPLACE PROCEDURE show_user_not_followed_hashtags(
    user_id_in IN NUMBER,
    hashtag_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
   OPEN hashtag_cursor  FOR
        SELECT h.hashtag_id, h.hashtag_name, h.created_at
        FROM hashtags h
        WHERE h.hashtag_id NOT IN (
            SELECT hf.hashtag_id
            FROM hashtag_follow hf
            WHERE hf.user_id = user_id_in
        );

END;
/


--Prodecure for user to follow a hashtag

CREATE OR REPLACE PROCEDURE follow_hashtag(
    user_id_in IN NUMBER,
    hashtag_id_in IN NUMBER
)
IS
    follow_id NUMBER;
BEGIN
    INSERT INTO hashtag_follow(user_id, hashtag_id)
    VALUES(user_id_in, hashtag_id_in)
    RETURNING user_id INTO follow_id;

    DBMS_OUTPUT.PUT_LINE('Hashtag Followed with ID: ' || follow_id);
END;
/


-- Show all posts having a particular selected hashtag

CREATE OR REPLACE PROCEDURE show_posts_for_hashtag(
    hashtag_id_in IN NUMBER,
    posts_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN posts_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        JOIN post_tags pt ON p.post_id = pt.post_id
        WHERE pt.hashtag_id = hashtag_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at, ph.photo_url, v.video_url, u.username, u.profile_photo_url;
END;
/


-- Procedure to update user details for a already created user

CREATE OR REPLACE PROCEDURE update_user_profile(
    user_id_in IN NUMBER,
    username_in IN VARCHAR2,
    bio_in IN VARCHAR2
)
IS
BEGIN
    UPDATE users
    SET username = username_in, bio = bio_in
    WHERE user_id = user_id_in;

    COMMIT;
END;
/


-- Procedure to add hashtags to post

CREATE OR REPLACE PROCEDURE add_hashtag_to_post(
    post_id_in IN NUMBER,
    hashtag_name_in IN VARCHAR2
) AS
BEGIN
    INSERT INTO post_tags (post_id, hashtag_id)
    SELECT post_id_in, hashtag_id
    FROM hashtags
    WHERE hashtag_name = hashtag_name_in;
END;
/




clear screen;