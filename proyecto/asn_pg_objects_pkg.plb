create or replace package body asn_pg_objects_pkg as

    procedure upload_file (
        p_email in varchar2,
        p_file in varchar2
    ) as
        l_request_url varchar2(32767);
        l_content_length number;
        l_response clob;
        l_timestamp timestamp := systimestamp;
        upload_failed_exception exception;
    begin
        for file in (
            select * from apex_application_temp_files
            where name = p_file
        ) loop
            l_request_url := 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/id5bhhnsvcbs/b/standard_vinny_dev/o/' || apex_util.url_encode(file.filename);

            apex_web_service.g_request_headers(1).name := 'Content-Type';
            apex_web_service.g_request_headers(1).value := file.mime_type;
            l_response  := apex_web_service.make_rest_request(
                            p_url => l_request_url
                            ,p_http_method => 'PUT'
                            ,p_body_blob => file.blob_content
                            ,p_credential_static_id => 'OCI_API_ACCESS'
            );

            if apex_web_service.g_status_code != 200 then
                raise upload_failed_exception;
            else
                insert into solicitudes
                values (SOL_ID_SEQ.nextval,file.filename,p_email,null,l_timestamp,l_timestamp);
            end if;
        end loop;
    end upload_file;

    function get_lambda return varchar2
    is
        l_request_url varchar2(32767);
        l_response clob;
        upload_failed_exception exception;
    begin
        l_request_url := 'https://powqxloccw6v7p6b7ja54yjely0uxpqr.lambda-url.us-east-2.on.aws/';

        --apex_web_service.g_request_headers(1).name := 'Content-Type';
        --apex_web_service.g_request_headers(1).value := file.mime_type;
        l_response  := apex_web_service.make_rest_request(
                        p_url => l_request_url
                        ,p_http_method => 'GET'
        );

        if apex_web_service.g_status_code != 200 then
            raise upload_failed_exception;
        else
            apex_debug.log_message(
                  p_message => l_response
                , p_enabled => true
                , p_level => 1
            );
        end if;

        return null;

    end get_lambda;
end;
/

show errors;
/
