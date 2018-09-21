CREATE KEYSPACE IF NOT EXISTS admin
    WITH REPLICATION = {
        'class' : 'SimpleStrategy',
        'replication_factor': 1
    }
    AND DURABLE_WRITES = true;
 
CREATE TABLE IF NOT EXISTS admin.keyspace_master (
    uuid uuid,
    keyspace_name text,
    application_name text,
    is_api boolean,
    password text,
    username text,
    is_aaf boolean,
    PRIMARY KEY (uuid)
);

CREATE TABLE IF NOT EXISTS admin.notification_master (
    id uuid,
    current_notifier text,
    endpoint_password blob,
    endpoint_userid text,
    notify_delete_on text,
    notify_insert_on text,
    notify_to_endpoint text,
    notify_update_on text,
    notifyon text PRIMARY KEY,
    request text
);



describe keyspace admin;
