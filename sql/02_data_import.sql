-- The reviews source contains duplicate review_id values for different orders.
-- The pair is unique, so retain every source record with a composite key.
ALTER TABLE order_reviews
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (review_id, order_id);

TRUNCATE TABLE order_reviews;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_mysql.tsv'
INTO TABLE order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
);
