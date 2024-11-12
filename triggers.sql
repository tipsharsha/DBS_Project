CREATE TABLE action_log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procedure_name VARCHAR2(50),
    user_id NUMBER,
    action VARCHAR2(50),
    details VARCHAR2(500)
);


CREATE OR REPLACE TRIGGER trg_create_new_user
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('create_new_user', :NEW.user_id, 'Insert', 'New user created with email: ' || :NEW.email);
    
    DBMS_OUTPUT.PUT_LINE('Log: New user created with ID ' || :NEW.user_id || ' and email ' || :NEW.email);
END;
/

CREATE OR REPLACE TRIGGER trg_create_new_post
AFTER INSERT ON post
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('create_new_post', :NEW.user_id, 'Insert', 'New post created with caption: ' || :NEW.caption);
    
    DBMS_OUTPUT.PUT_LINE('Log: New post created by user ID ' || :NEW.user_id || ' with caption "' || :NEW.caption || '"');
END;
/

CREATE OR REPLACE TRIGGER trg_like_post
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('like_post', :NEW.user_id, 'Like', 'User liked post with ID: ' || :NEW.post_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ID ' || :NEW.user_id || ' liked post ID ' || :NEW.post_id);
END;
/

CREATE OR REPLACE TRIGGER trg_unlike_post
AFTER DELETE ON post_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('unlike_post', :OLD.user_id, 'Unlike', 'User unliked post with ID: ' || :OLD.post_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ID ' || :OLD.user_id || ' unliked post ID ' || :OLD.post_id);
END;
/

CREATE OR REPLACE TRIGGER trg_follow_hashtag
AFTER INSERT ON hashtag_follow
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('follow_hashtag', :NEW.user_id, 'Follow', 'User followed hashtag with ID: ' || :NEW.hashtag_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ID ' || :NEW.user_id || ' followed hashtag ID ' || :NEW.hashtag_id);
END;
/

CREATE OR REPLACE TRIGGER trg_add_comment_to_post
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('add_comment_to_post', :NEW.user_id, 'Comment', 'User commented on post ID: ' || :NEW.post_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ID ' || :NEW.user_id || ' commented on post ID ' || :NEW.post_id);
END;
/

CREATE OR REPLACE TRIGGER trg_update_user_profile
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('update_user_profile', :NEW.user_id, 'Update', 'User profile updated with new username: ' || :NEW.username);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ID ' || :NEW.user_id || ' updated profile with new username: ' || :NEW.username);
END;
/

CREATE OR REPLACE TRIGGER limit_comments_on_post
BEFORE INSERT ON comments
FOR EACH ROW
DECLARE
    comment_count NUMBER;
    max_comments CONSTANT NUMBER := 100; -- Set maximum number of comments per post
BEGIN
    -- Count the existing comments for the post
    SELECT COUNT(*)
    INTO comment_count
    FROM comments
    WHERE post_id = :NEW.post_id;

    -- Check if the comment count exceeds the limit
    IF comment_count >= max_comments THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot add more comments to this post, the limit has been reached.');
    END IF;
END;


CREATE OR REPLACE TRIGGER trg_delete_user
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_user', :OLD.user_id, 'Delete', 'User account deleted');
    
    DBMS_OUTPUT.PUT_LINE('Log: User ID ' || :OLD.user_id || ' account deleted');
END;
/

CREATE OR REPLACE TRIGGER trg_delete_post
AFTER DELETE ON post
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_post', :OLD.user_id, 'Delete', 'Post deleted with ID: ' || :OLD.post_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: Post ID ' || :OLD.post_id || ' deleted');
END;
/

CREATE OR REPLACE TRIGGER trg_delete_comment
AFTER DELETE ON comments
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_comment', :OLD.user_id, 'Delete', 'Comment deleted with ID: ' || :OLD.comment_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: Comment ID ' || :OLD.comment_id || ' deleted');
END;
/

CREATE OR REPLACE TRIGGER trg_delete_hashtag_follow
AFTER DELETE ON hashtag_follow
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_hashtag_follow', :OLD.user_id, 'Delete', 'User unfollowed hashtag with ID: ' || :OLD.hashtag_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ID ' || :OLD.user_id || ' unfollowed hashtag ID ' || :OLD.hashtag_id);
END;
/

CREATE OR REPLACE TRIGGER trg_delete_post_tag
AFTER DELETE ON post_tags
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('delete_post_tag', :OLD.post_id, 'Delete', 'Tag removed from post with ID: ' || :OLD.post_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: Tag removed from post ID ' || :OLD.post_id);
END;

-- Trigger to log when a user follows another user
CREATE OR REPLACE TRIGGER trg_follow_user
AFTER INSERT ON follows
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('follow_user', :NEW.follower_id, 'Follow', 'User ' || :NEW.follower_id || ' followed user ' || :NEW.followee_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :NEW.follower_id || ' followed user ' || :NEW.followee_id);
END;

-- Trigger to log when a user unfollows another user
CREATE OR REPLACE TRIGGER trg_unfollow_user
AFTER DELETE ON follows
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('unfollow_user', :OLD.follower_id, 'Unfollow', 'User ' || :OLD.follower_id || ' unfollowed user ' || :OLD.followee_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :OLD.follower_id || ' unfollowed user ' || :OLD.followee_id);
END;
/

-- Trigger to log when a user likes a comment
CREATE OR REPLACE TRIGGER trg_like_comment
AFTER INSERT ON comment_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('like_comment', :NEW.user_id, 'Like', 'User ' || :NEW.user_id || ' liked comment ' || :NEW.comment_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :NEW.user_id || ' liked comment ' || :NEW.comment_id);
END;
/

-- Trigger to log when a user unlikes a comment
CREATE OR REPLACE TRIGGER trg_unlike_comment
AFTER DELETE ON comment_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('unlike_comment', :OLD.user_id, 'Unlike', 'User ' || :OLD.user_id || ' unliked comment ' || :OLD.comment_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :OLD.user_id || ' unliked comment ' || :OLD.comment_id);
END;
/

-- Trigger to log when a user likes a post
CREATE OR REPLACE TRIGGER trg_like_post
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('like_post', :NEW.user_id, 'Like', 'User ' || :NEW.user_id || ' liked post ' || :NEW.post_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :NEW.user_id || ' liked post ' || :NEW.post_id);
END;
/

-- Trigger to log when a user unlikes a post
CREATE OR REPLACE TRIGGER trg_unlike_post
AFTER DELETE ON post_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('unlike_post', :OLD.user_id, 'Unlike', 'User ' || :OLD.user_id || ' unliked post ' || :OLD.post_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :OLD.user_id || ' unliked post ' || :OLD.post_id);
END;
/

-- Trigger to log when a user adds a tag to a post
CREATE OR REPLACE TRIGGER trg_add_tag_to_post
AFTER INSERT ON post_tags
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('add_tag_to_post', :NEW.post_id, 'Add Tag', 'User ' || :NEW.post_id || ' added tag ' || :NEW.hashtag_id || ' to post');
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :NEW.post_id || ' added tag ' || :NEW.hashtag_id || ' to post');
END;
/

-- Trigger to log when a user removes a tag from a post
CREATE OR REPLACE TRIGGER trg_remove_tag_from_post
AFTER DELETE ON post_tags
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('remove_tag_from_post', :OLD.post_id, 'Remove Tag', 'User ' || :OLD.post_id || ' removed tag ' || :OLD.hashtag_id || ' from post');
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :OLD.post_id || ' removed tag ' || :OLD.hashtag_id || ' from post');
END;
/

-- Trigger to log when a user likes a comment
CREATE OR REPLACE TRIGGER trg_like_comment
AFTER INSERT ON comment_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('like_comment', :NEW.user_id, 'Like', 'User ' || :NEW.user_id || ' liked comment ' || :NEW.comment_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :NEW.user_id || ' liked comment ' || :NEW.comment_id);
END;
/

-- Trigger to log when a user unlikes a comment
CREATE OR REPLACE TRIGGER trg_unlike_comment
AFTER DELETE ON comment_likes
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('unlike_comment', :OLD.user_id, 'Unlike', 'User ' || :OLD.user_id || ' unliked comment ' || :OLD.comment_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :OLD.user_id || ' unliked comment ' || :OLD.comment_id);
END;
/

-- Trigger to log when a user follows a hashtag
CREATE OR REPLACE TRIGGER trg_follow_hashtag
AFTER INSERT ON hashtag_follow
FOR EACH ROW
BEGIN
    INSERT INTO action_log(procedure_name, user_id, action, details)
    VALUES ('follow_hashtag', :NEW.user_id, 'Follow', 'User ' || :NEW.user_id || ' followed hashtag ' || :NEW.hashtag_id);
    
    DBMS_OUTPUT.PUT_LINE('Log: User ' || :NEW.user_id || ' followed hashtag ' || :NEW.hashtag_id);
END;
/