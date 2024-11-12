# drop table hashtag_follow;
#  drop table hashtags;
#  drop table follows;
#  drop table comment_likes;
#  drop table post_likes;
#  drop table comments;
#  drop table videos;
#   drop table photos;
#  drop table post;
#  drop table users;
#  drop table post_tags;
#  drop table login;
#  drop table location;

lst = ['drop table hashtag_follow;', 'drop table hashtags;', 'drop table follows;', 'drop table comment_likes;', 'drop table post_likes;', 'drop table comments;', 'drop table videos;', 'drop table photos;', 'drop table post;', 'drop table users;', 'drop table post_tags;', 'drop table login;', 'drop table location;']
with open('drop.sql', 'w') as f:
    for i in lst:
        f.write(i.strip(';')+" cascade constraints;\n")
    f.write("clear screen;")