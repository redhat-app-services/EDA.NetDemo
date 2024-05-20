CREATE DATABASE kafka_events;
GO
USE kafka_events;
GO
CREATE TABLE kafka_events.dbo.event_info (
    event_id INT PRIMARY KEY IDENTITY (1, 1),
    content_type VARCHAR (50) NOT NULL,
    data VARCHAR (600) NOT NULL
);
