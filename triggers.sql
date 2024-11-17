CREATE OR REPLACE TRIGGER trg_create_new_user
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('create_new_user', :NEW.user_id, 'Insert', 'New user created with email: ' || :NEW.email);

    DBMS_OUTPUT.PUT_LINE('New user created with email: ' || :NEW.email);
END;
/

CREATE OR REPLACE TRIGGER trg_create_new_post
AFTER INSERT ON post
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('create_new_post', :NEW.user_id, 'Insert', 'New post created with caption: ' || NVL(:NEW.caption, 'No caption'));

    DBMS_OUTPUT.PUT_LINE('New post created with caption: ' || NVL(:NEW.caption, 'No caption'));
END;
/

CREATE OR REPLACE TRIGGER trg_like_post
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('like_post', :NEW.user_id, 'Like', 'User liked post with ID: ' || :NEW.post_id);

    DBMS_OUTPUT.PUT_LINE('User liked post with ID: ' || :NEW.post_id);
END;
/

CREATE OR REPLACE TRIGGER trg_unlike_post
AFTER DELETE ON post_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('unlike_post', :OLD.user_id, 'Unlike', 'User unliked post with ID: ' || :OLD.post_id);

    DBMS_OUTPUT.PUT_LINE('User unliked post with ID: ' || :OLD.post_id);
END;
/

CREATE OR REPLACE TRIGGER trg_follow_hashtag
AFTER INSERT ON hashtag_follow
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('follow_hashtag', :NEW.user_id, 'Follow', 'User followed hashtag with ID: ' || :NEW.hashtag_id);

    DBMS_OUTPUT.PUT_LINE('User followed hashtag with ID: ' || :NEW.hashtag_id);

END;
/

CREATE OR REPLACE TRIGGER trg_add_comment_to_post
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('add_comment_to_post', :NEW.user_id, 'Comment', 'User commented on post ID: ' || :NEW.post_id);

    DBMS_OUTPUT.PUT_LINE('User commented on post ID: ' || :NEW.post_id);
END;
/

CREATE OR REPLACE TRIGGER trg_update_user_profile
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    IF :NEW.username != :OLD.username THEN
        INSERT INTO action_log(procedure_name, user_id, action, details)
        VALUES ('update_user_profile', :NEW.user_id, 'Update', 'User profile updated with new username: ' || :NEW.username);

        DBMS_OUTPUT.PUT_LINE('User profile updated with new username: ' || :NEW.username);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_delete_user
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_user', :OLD.user_id, 'Delete', 'User account deleted');

    DBMS_OUTPUT.PUT_LINE('User account deleted');
END;
/

CREATE OR REPLACE TRIGGER trg_delete_post
AFTER DELETE ON post
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_post', :OLD.user_id, 'Delete', 'Post deleted with ID: ' || :OLD.post_id);

    DBMS_OUTPUT.PUT_LINE('Post deleted with ID: ' || :OLD.post_id);
END;
/

CREATE OR REPLACE TRIGGER trg_delete_comment
AFTER DELETE ON comments
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_comment', :OLD.user_id, 'Delete', 'Comment deleted with ID: ' || :OLD.comment_id);

    DBMS_OUTPUT.PUT_LINE('Comment deleted with ID: ' || :OLD.comment_id);
END;
/

CREATE OR REPLACE TRIGGER trg_delete_hashtag_follow
AFTER DELETE ON hashtag_follow
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_hashtag_follow', :OLD.user_id, 'Delete', 'User unfollowed hashtag with ID: ' || :OLD.hashtag_id);

    DBMS_OUTPUT.PUT_LINE('User unfollowed hashtag with ID: ' || :OLD.hashtag_id);
END;
/

CREATE OR REPLACE TRIGGER trg_follow_user
AFTER INSERT ON follows
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('follow_user', :NEW.follower_id, 'Follow', 'User ' || :NEW.follower_id || ' followed user ' || :NEW.followee_id);

    DBMS_OUTPUT.PUT_LINE('User ' || :NEW.follower_id || ' followed user ' || :NEW.followee_id);
END;
/

CREATE OR REPLACE TRIGGER trg_unfollow_user
AFTER DELETE ON follows
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('unfollow_user', :OLD.follower_id, 'Unfollow', 'User ' || :OLD.follower_id || ' unfollowed user ' || :OLD.followee_id);

    DBMS_OUTPUT.PUT_LINE('User ' || :OLD.follower_id || ' unfollowed user ' || :OLD.followee_id);
END;
/

CREATE OR REPLACE TRIGGER limit_comments_on_post
BEFORE INSERT ON comments
FOR EACH ROW
DECLARE
    comment_count NUMBER;
    max_comments CONSTANT NUMBER := 100; -- Set maximum number of comments per post
BEGIN
    SELECT COUNT(*)
    INTO comment_count
    FROM comments
    WHERE post_id = :NEW.post_id;

    IF comment_count >= max_comments THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot add more comments to this post, the limit has been reached.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER set_random_profile_photo
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF :NEW.profile_photo_url IS NULL THEN
        :NEW.profile_photo_url := 'https://picsum.photos/100?' || TRUNC(DBMS_RANDOM.VALUE(1, 1000000));

        DBMS_OUTPUT.PUT_LINE('Random profile photo set for user with email: ' || :NEW.email);
    END IF;
END;
/
