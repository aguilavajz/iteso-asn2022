CREATE OR REPLACE VIEW respuesta_v
  AS SELECT s.id, jt.*
       FROM solicitudes s,
            json_table(s.respuesta, '$.Labels[*]'
                COLUMNS (
                    name        VARCHAR2(256)         PATH '$.Name',
                    confidence  number                PATH '$.Confidence'
                )
            ) jt;
