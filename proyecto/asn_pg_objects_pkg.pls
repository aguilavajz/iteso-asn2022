create or replace package asn_pg_objects_pkg as

    procedure upload_file (
        p_email in varchar2,
        p_file in varchar2
    );

    function get_lambda return varchar2;

end;
/

show errors;
/
