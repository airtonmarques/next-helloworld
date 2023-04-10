CREATE OR REPLACE FUNCTION alt_send_msg_mala(cod_mala         NUMBER,
                                             venvioteste      NUMBER,
                                             cod_cad_usu      NUMBER DEFAULT NULL,
                                             cod_tipo_cad_usu NUMBER DEFAULT NULL)
  RETURN VARCHAR2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  vcodtipmsg     alt_mala.cod_tipo_msg%type;
  vretmsg        sys_send_msg.retorno_msg%type;
  keyrow         NUMBER;
  vnomtipmsg     td_sys_tipo_msg.nome_tipo_msg%type;
  vcodcad        alt_cad.cod_cad%type;
  vcodtipocad     alt_cad.cod_tipo_cad%type;
  vnomeresp      alt_cad.nome_cad%type;
  vnomerespm     alt_cad.nome_cad%type;
  vtratamento    alt_cad.cod_tratamento%type;
  vtipopessoa    alt_cad.cod_tipo_pessoa%type;
  vdtnascimento  alt_cad.dt_nasc_cad%type;
  vnumerotelef   VARCHAR2(20);
  vemail         alt_cad_mail.mail_cad_mail%type;
  vuf            td_alt_uf.cod_uf%type;
  vnumcontrato   alt_prop.cod_cont%type;
  vdiavctcont    alt_cont.dia_venc_cont%type;
  vnomeoperadora alt_cad.nome_cad%type;
  vnomeentidade  alt_cad.nome_cad%type;
  vcodprop       alt_prop_dep.cod_prop%type;
  vcodcaddep     alt_cad.cod_cad%type;
  vnomecaddep    alt_cad.nome_cad%type;
  vcodpropdep    alt_prop_dep.cod_prop_dep%type;

  vcorpomsg sys_send_msg.mensagem_msg%type;
  vtitmsg   sys_send_msg.titulo_msg%type;
  vcodmsg   sys_send_msg.cod_sts_msg%type;

  vretorno sys_send_msg.retorno_msg%type;

  raltmala alt_mala%ROWTYPE;

  cbeneficiarios SYS_REFCURSOR;
  vcorpomsgrow   sys_send_msg.mensagem_msg%type;
  benvioteste    BOOLEAN := venvioteste = 1;
  vdestmsg       sys_send_msg.destino_msg%type;
  nfila          sys_send_msg.cod_fila_msg%type;
  ncount         NUMBER := 0;
  rSysSendMsg    sys_send_msg%rowtype;
  sTags          CLOB;
  sTxtMsg1       CLOB;
  sTxtMsg2       CLOB;
  sCampoImgMsg   CLOB;
  
  vcampoextra1 varchar2(4000);
  vcampoextra2 varchar2(4000);
  vcampoextra3 varchar2(4000);
  vcampoextra4 varchar2(4000);
  vcampoextra5 varchar2(4000);
  vanexo_msg   varchar2(4000);

BEGIN
  raltmala.cod_mala := cod_mala;

  SELECT * INTO raltmala FROM alt_mala WHERE cod_mala = raltmala.cod_mala;

  IF TRUNC(raltmala.dt_mala) < TRUNC(SYSDATE) THEN
    COMMIT;
    RETURN sys_return_error('Data limite da mala excedida.');
  END IF;

  IF NOT benvioteste AND raltmala.COD_STS_MALA IN (1, 2) THEN
    vretorno := 'Mala Direta pendente de aprovação';
    RAISE NO_DATA_FOUND;
  END IF;

  IF raltmala.cod_html_modelo IS NULL THEN
    vretorno := 'Modelo da Mensagem não pode ser nulo';
    RAISE NO_DATA_FOUND;
  END IF;

  --Valida o Tipo da Mensagem
  SELECT cod_tipo_msg, nome_tipo_msg
    INTO vcodtipmsg, vnomtipmsg
    FROM td_sys_tipo_msg
   WHERE cod_tipo_msg = raltmala.cod_tipo_msg;

  IF vcodtipmsg = 2 and raltmala.destino_msg_teste is not null THEN
    IF LENGTH(raltmala.destino_msg_teste) > 11 OR
       LENGTH(raltmala.destino_msg_teste) < 10 THEN
      commit;
      RETURN sys_return_error('Telefone invalido');
    END IF;
  
    BEGIN
      raltmala.destino_msg_teste := TO_NUMBER(55 ||
                                              raltmala.destino_msg_teste);
    EXCEPTION
      WHEN VALUE_ERROR THEN
        vretorno := 'Telefone invalido: informe somente números.';
        RAISE NO_DATA_FOUND;
    END;
  END IF;

  alt_mala_tst_filtro_pcd(cod_mala     => raltmala.cod_mala,
                          tipoquery    => 1,
                          qtde_max     => -1,
                          msgerror     => vretorno,
                          cursorreturn => cbeneficiarios);

  if vretorno is not null and vretorno != ' ' then
    RAISE NO_DATA_FOUND;
  end if;

  IF raltmala.cod_html_modelo != 28 THEN
  
    IF raltmala.txt_msg_1 IS NOT NULL THEN
      sTxtMsg1 := raltmala.txt_msg_1;
    END IF;
  
    IF vcodtipmsg = 1 THEN
      IF raltmala.txt_msg_2 IS NOT NULL THEN
        sTxtMsg2 := raltmala.txt_msg_2;
      END IF;
    
      IF alt_get_link_anexo_fnc('ALT_MALA', '0', raltmala.cod_mala) IS NOT NULL THEN
        sCampoImgMsg := '<TABLE align="center">
                        <img src ="' ||
                        alt_get_link_anexo_fnc('ALT_MALA',
                                               '0',
                                               raltmala.cod_mala) ||
                        '" vspace="10px" hspace="15px" border="10px" align="center"/>
                        </TABLE>';
      END IF;
    END IF;
  ELSE
    sTxtMsg1 := raltmala.txt_msg_1;
  END IF;

  SELECT titulo_html_modelo
    INTO vtitmsg
    FROM sys_html_modelo shm, sys_html_padrao c_shp, sys_html_padrao r_shp
   WHERE shm.cod_html_modelo = raltmala.cod_html_modelo
     AND shm.cod_cabecalho_html_padrao = c_shp.cod_html_padrao(+)
     AND shm.cod_rodape_html_padrao = r_shp.cod_html_padrao(+);

  SELECT cod_sts_msg, nome_sts_msg
    INTO vcodmsg, vretmsg
    FROM td_sys_sts_msg
   WHERE cod_sts_msg = 1;

  LOOP
    FETCH cbeneficiarios
      INTO keyrow,
           vcodtipocad,
           vcodcad,
           vnomeresp,
           vnomerespm,
           vtratamento,
           vtipopessoa,
           vdtnascimento,
           vnumerotelef,
           vemail,
           vuf,
           vnumcontrato,
           vnomeoperadora,
           vcodprop,
           vcodcaddep,
           vnomecaddep,
           vcodpropdep,
           vdiavctcont,
           vnomeentidade,
           vcampoextra1,
           vcampoextra2,
           vcampoextra3,
           vcampoextra4,
           vcampoextra5,
           vanexo_msg;
  
    EXIT WHEN cbeneficiarios%NOTFOUND;
    ncount := ncount + 1;
  
    IF benvioteste THEN
    
      vcodcad := cod_cad_usu;
      vcodtipocad := cod_tipo_cad_usu;
    
      IF vcodtipmsg = 1 THEN
        vdestmsg := sys_get_mail_fnc(codtipocad => cod_tipo_cad_usu,
                                     codcad     => cod_cad_usu);
      ELSIF vcodtipmsg = 2 THEN
        vdestmsg := alt_get_tel_fnc(icodtipotel => 4,
                                    itipodado   => 0,
                                    icodtipocad => cod_tipo_cad_usu,
                                    icodcad     => cod_cad_usu,
                                    iformat     => 0);
      END IF;
    
      nfila := 0;
    ELSE
      nfila := 1;
    
      IF vcodtipmsg = 1 THEN
      
        if sys_get_nome_conexao_fnc = 'DESENVOLVIMENTO' then
          vdestmsg := sys_get_mail_fnc(codtipocad => cod_tipo_cad_usu,
                                       codcad     => cod_cad_usu);
        elsif sys_get_nome_conexao_fnc = 'HOMOLOGACAO' then
          vdestmsg := sys_get_mail_fnc(codtipocad => cod_tipo_cad_usu,
                                       codcad     => cod_cad_usu);
        else
          vdestmsg := vemail;
        end if;
      
      ELSIF vcodtipmsg = 2 THEN
        vdestmsg := regexp_replace(vnumerotelef, '[^0-9]', '');
        --                --Teste geral
        --                vdestmsg := alt_get_tel_fnc (icodtipotel   => 4,
        --                                   itipodado     => 0,
        --                                   icodtipocad   => cod_tipo_cad_usu,
        --                                   icodcad       => cod_cad_usu,
        --                                   iformat       => 0);
      END IF;
    END IF;
  
    sTags := 'TXT_MSG_1|' || sTxtMsg1 || '|TXT_MSG_2|' || sTxtMsg2 ||
             '|CAMPO_IMG_MSG|' || sCampoImgMsg || '|COD_CAD_BEN|' ||
             vcodcad || '|NOME_CAD_BEN_M|' || vnomerespm ||
             '|NOME_CAD_BEN|' || vnomeresp || '|COD_TRATAMENTO|' ||
             vtratamento || '|COD_TIPO_PESSOA|' || vtipopessoa ||
             '|DT_NASC_CAD|' || vdtnascimento || '|NUM_TEL|' ||
             vnumerotelef || '|MAIL|' || vemail || '|COD_UF|' || vuf ||
             '|COD_CONT|' || vnumcontrato || '|NOME_CAD_OPER|' ||
             vnomeoperadora || '|COD_PROP|' || vcodprop || '|COD_CAD_DEP|' ||
             vcodcaddep || '|NOME_CAD_DEP|' || vnomecaddep ||
             '|COD_PROP_DEP|' || vcodpropdep||
             '|DIA_VENC_CONT|' || vdiavctcont||
             '|NOME_CAD_ENT|' || vnomeentidade||
             '|CAMPO_EXTRA_1|' || vcampoextra1||
             '|CAMPO_EXTRA_2|' || vcampoextra2||
             '|CAMPO_EXTRA_3|' || vcampoextra3||
             '|CAMPO_EXTRA_4|' || vcampoextra4||
             '|CAMPO_EXTRA_5|' || vcampoextra5;
  
    vtitmsg := raltmala.titulo_email_mala;
    vtitmsg := REPLACE(vtitmsg, '#COD_CAD_BEN', vcodcad);
    vtitmsg := REPLACE(vtitmsg, '#NOME_CAD_BEN_M', vnomerespm);
    vtitmsg := REPLACE(vtitmsg, '#NOME_CAD_BEN', vnomeresp);
    vtitmsg := REPLACE(vtitmsg, '#COD_TRATAMENTO', vtratamento);
    vtitmsg := REPLACE(vtitmsg, '#COD_TIPO_PESSOA', vtipopessoa);
    vtitmsg := REPLACE(vtitmsg, '#DT_NASC_CAD', vdtnascimento);
    vtitmsg := REPLACE(vtitmsg, '#NUM_TEL', vnumerotelef);
    vtitmsg := REPLACE(vtitmsg, '#MAIL', vemail);
    vtitmsg := REPLACE(vtitmsg, '#COD_UF', vuf);
    vtitmsg := REPLACE(vtitmsg, '#COD_CONT', vnumcontrato);
    vtitmsg := REPLACE(vtitmsg, '#NOME_CAD_OPER', vnomeoperadora);
    vtitmsg := REPLACE(vtitmsg, '#COD_PROP', vcodprop);
    vtitmsg := REPLACE(vtitmsg, '#COD_CAD_DEP', vcodcaddep);
    vtitmsg := REPLACE(vtitmsg, '#NOME_CAD_DEP', vnomecaddep);
    vtitmsg := REPLACE(vtitmsg, '#COD_PROP_DEP', vcodpropdep);
    vtitmsg := REPLACE(vtitmsg, '#DIA_VENC_CONT', vdiavctcont);
    vtitmsg := REPLACE(vtitmsg, '#NOME_CAD_ENT', vnomeentidade);
  
    rSysSendMsg.mensagem_msg := ALT_BUILD_CORPO_HTML(raltmala.cod_html_modelo,
                                                     sTags,
                                                     raltmala.chk_cabecalho_default,
                                                     raltmala.chk_rodape_default);
  
    DECLARE
      AUX NUMBER := 1;
    BEGIN
      LOOP
        rSysSendMsg.cod_tipo_msg        := vcodtipmsg;
        rSysSendMsg.display_destino_msg := vnomerespm;
        rSysSendMsg.dth_prog_msg        := SYSDATE;
        rSysSendMsg.cod_sts_msg         := vcodmsg;
        rSysSendMsg.retorno_msg         := vretmsg;
        rSysSendMsg.cod_tipo_cad        := vcodtipocad;
        rSysSendMsg.cod_cad             := vcodcad;
        rSysSendMsg.cod_fila_msg        := nfila;
        rSysSendMsg.destino_msg         := vdestmsg;
        rSysSendMsg.cod_mala            := raltmala.cod_mala;
        rSysSendMsg.cod_prop            := vcodprop;
        rSysSendMsg.cod_prop_dep        := vcodpropdep;
        rSysSendMsg.titulo_msg          := vtitmsg;
        rSysSendMsg.anexos_msg          := vanexo_msg;
      
        ALT_SET_SYS_SEND_MSG(rSysSendMsg, vretorno);
      
        IF benvioteste AND AUX = 1 THEN
          IF raltmala.destino_msg_teste IS NOT NULL THEN
            vdestmsg := raltmala.destino_msg_teste;
            AUX      := AUX + 1;
          ELSE
            EXIT;
          END IF;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    END;
  
    IF vretorno != '-1' THEN
      RAISE NO_DATA_FOUND;
    END IF;
  
    vretorno := ('Mensagem registrado para envio');
  
    EXIT WHEN ncount = 100000;
  
    IF benvioteste THEN
      EXIT;
    END IF;
  END LOOP;

  IF ncount = 0 THEN
    COMMIT;
    RETURN sys_return_error('Não existem beneficiários para enviar mensagem.');
  END IF;

  IF benvioteste THEN
    IF raltmala.cod_sts_mala = 1 THEN
      UPDATE alt_mala
         SET cod_sts_mala = 2
       WHERE cod_mala = raltmala.cod_mala;
    END IF;
  ELSE
    IF raltmala.cod_sts_mala = 5 THEN
      UPDATE alt_mala
         SET cod_sts_mala = 3
       WHERE cod_mala = raltmala.cod_mala;
    ELSIF raltmala.cod_sts_mala = 3 THEN
      UPDATE alt_mala
         SET cod_sts_mala = 4
       WHERE cod_mala = raltmala.cod_mala;
    END IF;
  END IF;

  COMMIT;

  RETURN sys_return_true(vretorno);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    COMMIT;
    RETURN sys_return_error('Mensagem não pode ser enviado: ' ||
                            SUBSTR(vretorno, 1, 3000));
END;
