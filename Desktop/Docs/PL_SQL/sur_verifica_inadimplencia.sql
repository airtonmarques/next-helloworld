CREATE OR REPLACE PROCEDURE TA_MASTER.SUR_VERIFICA_INADIMPLENCIA  (
   p_ind_erro_out            OUT      VARCHAR2,  -- 0 Realizado com sucesso
                                                 -- 1 Erro previsto
                                                 -- 2 Erro não previsto
                                                 -- 3 Advertência
   p_msg_retorno_out         OUT      VARCHAR2,
   p_cod_operadora           IN       VARCHAR2,
   p_cod_sucursal            IN       NUMBER,
   p_cod_inspetoria_ts       IN       NUMBER,
   p_commit                  IN       VARCHAR2 DEFAULT NULL,
   p_cod_usuario             IN       VARCHAR2 DEFAULT NULL,
   p_endereco_ip             IN       VARCHAR2 DEFAULT NULL,
   p_versao                  IN       VARCHAR2 DEFAULT 'N')
   AUTHID CURRENT_USER IS
/*** VERSÃO ORIGINAL **********************************************************************************
  Tratamento de retaguarda antes do inadimplência do contrato
  Versão de Origem: 1.18 -> V9
/*** AUTOR E DATA DA CRIAÇÃO **************************************************************************
  Top-Down - 17/09/2013 -
    Verifica cobranças em aberto para atualizar status dos contratos e beneficiários, bem como
    gerar ordem para emissão de carta de cobrança.
  Versão inicial: 1.1
/*** MANUTENÇÕES **************************************************************************************
  ALTERAÇÃO  : Retirado tratamento marca
  SOLICITANTE:
  DATA       : 03/10/2013
  ANALISTA   : Eldair Pinheiro
 ******************************************************************************************************
  ALTERAÇÃO  : Versão: 1.4 - BCKLOG_ZERO - Email corretor
  SOLICITANTE: SAC:41201 - Unimed Odonto
  DATA       : 08/08/2014
  ANALISTA   : Samuel Reis
 ******************************************************************************************************/
   -- Variáveis Gerais
   err_trata_erro                EXCEPTION;
   err_previsto                  EXCEPTION;
   err_nao_previsto              EXCEPTION;
   err_advertencia               EXCEPTION;
   v_posicao                     pls_integer;
   v_txt_parametros              VARCHAR2(2000);
   v_erro_oracle                 VARCHAR2(300);
   v_ind_erro                    VARCHAR2(1);
   v_msg_retorno                 VARCHAR2(1000);
   -- Variáveis Específicas
   v_cod_ts_contrato_ant         varchar2(17);
   v_cod_entidade_ts_ant         number(15);
   v_cod_ts_ant                  number(15);
   v_ind_inadimplente            VARCHAR2(1);
   v_cod_inadimplencia           number(5);
   v_cod_entidade_ts_aux         number(15);
   v_txt_versao                  VARCHAR2(300);
   v_qtd_dias_apos_venc          pls_integer;
   v_prazo_venc_retro_inadimpl   pls_integer;
   v_dias_atraso                 pls_integer;
   v_Achou                       pls_integer;
   v_sql                         varchar2(4000);
   v_sql2                        varchar2(8000);
   curCob                        sys_refcursor;
   v_ind_apos_dem                varchar2(1);
   v_operadora_ts                VARCHAR2(20);
   type rCob   is record (dias_atraso            number(6) ,
                          cod_ts_contrato        varchar2(17),
                          cod_ts_contrato_dental varchar2(17),
                          cod_entidade_ts        number(15),
                          cod_ts                 number(15),
                          tipo_empresa           number(2),
                          cod_operadora          varchar2(10),
                          cod_sucursal           number(5),
                          cod_inspetoria_ts      number(15),
                          cod_inadimplencia_cont number(5),
                          cod_inadimplencia_emp  number(5),
                          cod_inadimplencia_ass  number(5),
                          num_seq_cobranca       number(15),
                          ind_acao_jud           char(1),
                          ind_apos_dem           char(1),
                          ind_tipo_pessoa        char(1),
                          dt_competencia         date,
                          dt_vencimento          date);
   type tCob is table of rCob index by pls_integer;
   rsCob                          tCob;
BEGIN
      BEGIN
         --  Teste da Versão
         v_txt_versao := '$Revision $';
         IF nvl(p_versao,'N') = 'S' then
            p_ind_erro_out := 0;
            p_msg_retorno_out := v_txt_versao;
            RETURN;
         END IF;
         -- Área de inicialização.
         v_posicao := 10;
         p_ind_erro_out := '0';
         p_msg_retorno_out := '';
         v_cod_ts_contrato_ant := -1;
         v_cod_entidade_ts_ant := -1;
         v_cod_ts_ant := -1;
         v_txt_parametros := ' p_cod_usuario:'        || p_cod_usuario       ||
                             ',p_endereco_ip:'        || p_endereco_ip       ||
                             ',p_cod_operadora: '     || p_cod_operadora     ||
                             ',p_cod_sucursal: '      || p_cod_sucursal      ||
                             ',p_cod_inspetoria_ts: ' || p_cod_inspetoria_ts ;
         TS_LOG_EXECUCAO ( 'SUR_VERIFICA_INADIMPLENCIA', 0, 0, v_txt_parametros, 'INÍCIO DE PROCESSAMENTO' );
         -- Verifica se é dia útil
         if to_char(sysdate,'D') in (1,7) then
            TS_LOG_EXECUCAO ( 'SUR_VERIFICA_INADIMPLENCIA', 0, 0, v_txt_parametros, 'EXECUÇÃO FINALIZADA DEVIDO NÃO SER DIA ÚTIL' );
            RETURN;
         end if;
         begin
           SELECT 1
           INTO v_Achou
           FROM DUAL
           WHERE EXISTS(SELECT NULL
                        FROM FERIADO_SUR
                        WHERE DT_FERIADO = TRUNC(sysdate)
                          AND IND_TIPO_FERIADO = 'N'); -- Nacional
            TS_LOG_EXECUCAO ( 'SUR_VERIFICA_INADIMPLENCIA', 0, 0, v_txt_parametros, 'EXECUÇÃO FINALIZADA DEVIDO NÃO SER DIA ÚTIL' );
            RETURN;
         exception
         when NO_DATA_FOUND then
            null;
         end;
         -- Tratamento Especial para alterar o tipo_dia_vencimento para vencimento original nos casos
         -- que o cliente foi prorrogado e a sua suspensão não foi realizada
        for cp in (select num_seq_cobranca from cobranca co
                    where co.ind_estado_cobranca = '0'
                      and dt_vencimento < sysdate -2
                      and tipo_venc_inadimplencia = 1
                      and dt_vencimento_orig is not null) loop
           begin
              update cobranca co
              set tipo_venc_inadimplencia = 2
            where num_Seq_cobranca = cp.num_seq_cobranca ;
           exception
              when others then
                 p_msg_retorno_out := 'Erro na atualização do tipo_venc_inadimplencia, num_Seq_cobranca = '||cp.num_Seq_cobranca||' - erro : '||top_utl_padrao.MsgErro;
                 raise err_nao_previsto;
           end;
           --
           -- cria ocorrencia
           --
           BEGIN
            INSERT INTO OCORRENCIA_COBRANCA
            (num_seq_cobranca,
             cod_ocorrencia,
             dt_ocorrencia,
             cod_usuario,
             txt_desc_ocorrencia,
             txt_obs_usuario )
            VALUES
            (cp.num_Seq_cobranca,
             32,
             SYSDATE,
             p_cod_usuario,
             'Alterou a configuração da data de inadimplência da cobrança para vencimento original',
             null);
         EXCEPTION
            WHEN OTHERS THEN
               p_Msg_Retorno_Out := 'Erro na geração da ocorrência da cobrança.';
               v_Erro_Oracle := top_utl_padrao.MsgErro;
               RAISE ERR_PREVISTO;
         END;

        end loop;
        v_sql :=          '  SELECT trunc(sysdate) - decode(nvl(co.tipo_venc_inadimplencia,1),1,trunc(co.dt_vencimento),2,trunc(fa.dt_vencimento)) dias_atraso, ';
        v_sql := v_sql || '                     co.cod_ts_contrato, ';
        v_sql := v_sql || '         decode(ce.IND_CONTRATO_DENTAL_EMBUTIDO,''S'', ce.cod_ts_contrato_dental, NULL) cod_ts_contrato_dental, ';
        v_sql := v_sql || '         DECODE(co.cod_ts, NULL, NVL(co.cod_entidade_ts,-1), co.cod_ts) cod_entidade_ts, ';
        v_sql := v_sql || '         co.cod_ts, ';
        v_sql := v_sql || '         ce.tipo_empresa, ';
        v_sql := v_sql || '         ce.cod_operadora_contrato, ';
        v_sql := v_sql || '         ce.cod_sucursal, ';
        v_sql := v_sql || '         ce.cod_inspetoria_ts, ';
        v_sql := v_sql || '         ce.cod_inadimplencia cod_inadimplencia_cont, ';
        v_sql := v_sql || '         ec.cod_inadimplencia cod_inadimplencia_emp, ';
        v_sql := v_sql || '         bf.cod_inadimplencia cod_inadimplencia_ass, ';
        v_sql := v_sql || '         co.num_seq_cobranca, ';
        v_sql := v_sql || '         NVL(CO.ind_acao_jud, ''N'') ind_acao_jud, ';
        v_sql := v_sql || '         nvl(CO.ind_apos_dem, ''N'') ind_apos_dem, ';
        v_sql := v_sql || '         tc.ind_tipo_pessoa, ';
        v_sql := v_sql || '         co.dt_competencia, ';
        v_sql := v_sql || '         decode(nvl(co.tipo_venc_inadimplencia,1), 1, co.dt_vencimento, 2, fa.dt_vencimento) dt_vencimento ';
        v_sql := v_sql || ' FROM cobranca co, ';
        v_sql := v_sql || '      contrato_empresa ce, ';
        v_sql := v_sql || '      tipo_contrato tc, ';
        v_sql := v_sql || '      beneficiario b, ';
        v_sql := v_sql || '      beneficiario_faturamento bf, ';
        v_sql := v_sql || '      empresa_contrato ec, ';
        v_sql := v_sql || '      fatura fa ';
        v_sql := v_sql || ' WHERE co.ind_estado_cobranca = ''0'' ';
        v_sql := v_sql || '   AND decode(nvl(co.tipo_venc_inadimplencia,1), 1, co.dt_vencimento, 2, fa.dt_vencimento) < trunc(sysdate) - :v_qtd_dias_apos_venc ';
        v_sql := v_sql || '   AND decode(nvl(co.tipo_venc_inadimplencia,1), 1, co.dt_vencimento, 2, fa.dt_vencimento) > ADD_MONTHS(sysdate, - :v_prazo_venc_retro_inadimpl) ';
        v_sql := v_sql || '   AND co.dt_emissao is not null ';
        v_sql := v_sql || '   AND fa.ind_situacao = ''2'' '; -- emitida
        v_sql := v_sql || '   AND co.val_a_pagar > 0  ';
        v_sql := v_sql || '   AND fa.num_seq_fatura_ts = co.num_seq_fatura_ts ';
        v_sql := v_sql || '   AND co.cod_ts_contrato = ce.cod_ts_contrato ';
        v_sql := v_sql || '   AND ce.cod_tipo_contrato = tc.cod_tipo_contrato ';
        v_sql := v_sql || '   AND co.cod_ts = b.cod_ts (+) ';
        v_sql := v_sql || '   AND b.cod_ts = bf.cod_ts (+) ';
        v_sql := v_sql || '   AND co.cod_ts_contrato = ec.cod_ts_contrato (+) ';
        v_sql := v_sql || '   AND co.cod_entidade_ts = ec.cod_entidade_ts (+) ';
        v_sql := v_sql || '   AND ((ce.tipo_empresa    = :tipo_empresa AND nvl(CO.ind_apos_dem, ''N'') = ''N'') OR (:tipo_empresa = 4 AND nvl(CO.ind_apos_dem, ''N'') IN (''A'',''D''))) ';
        v_sql := v_sql || '   AND ce.cod_sucursal      = :cod_sucursal  ';
        v_sql := v_sql || '   AND ce.cod_operadora_contrato     = :cod_operadora ';
        v_sql := v_sql || '   AND ce.cod_inspetoria_ts = :cod_inspetoria_ts ';
        v_sql := v_sql || '   AND ce.ind_situacao     != ''E'' '; -- contratos ativos
        --v_sql := v_sql || '   AND co.cod_ts =  207351 ';--teste
        v_sql := v_sql || '   AND (co.cod_ts IS NULL OR (co.cod_ts IS NOT NULL AND nvl(b.ind_situacao,''A'') != ''E'')) '; -- beneficiários ativos
        v_sql := v_sql || '   AND not exists (select 1 from Associado_desemprego AD ';
        v_sql := v_sql || '                   where ad.cod_ts = co.cod_ts ';
        v_sql := v_sql || '                     and co.dt_competencia between ad.mes_ini_isencao and ad.mes_fim_isencao) ';
        v_sql := v_sql || '   AND not exists (select 1 from ACAO_JUD_PGTO AJ ';
        v_sql := v_sql || '                   where AJ.cod_ts_contrato = CO.cod_ts_contrato ';
        v_sql := v_sql || '                     and AJ.cod_ts is null ';
        v_sql := v_sql || '                     and aj.dt_ini_acao <= sysdate ';
        v_sql := v_sql || '                     and nvl(aj.ind_inadimplencia,''N'') = ''N'' ';
        v_sql := v_sql || '                     and (aj.dt_fim_acao is null or aj.dt_fim_acao >= sysdate)) ';
        v_sql := v_sql || '   AND not exists (select 1 from ACAO_JUD_PGTO AP ';
        v_sql := v_sql || '                   where AP.cod_ts = co.cod_ts ';
        v_sql := v_sql || '                     and nvl(ap.ind_inadimplencia,''N'') = ''N'' ';
        v_sql := v_sql || '                     and ap.dt_ini_acao <= sysdate ';
        v_sql := v_sql || '                     and (ap.dt_fim_acao is null or ap.dt_fim_acao >= sysdate))';
        v_sql := v_sql || ' ORDER BY co.cod_ts_contrato, co.cod_entidade_ts, co.cod_ts, 1 DESC ';
         -- Início da Rotina
         for CSI in (select distinct
                            si.cod_sucursal,
                            si.cod_operadora,
                            si.cod_inspetoria_ts,
                            si.tipo_empresa,
                            nvl(re.ind_regra_dias_inadimplencia,'C') ind_regra_dias_inadimplencia,
                            re.ind_classificacao
                     from situacao_inadimplencia si,
                          regra_empresa re
                     where si.ind_tipo_regra = 1
                       and si.tipo_empresa  = re.tipo_empresa
                       and (si.cod_operadora     = p_cod_operadora     or p_cod_operadora     is null)
                       and (si.cod_sucursal      = p_cod_sucursal      or p_cod_sucursal      is null)
                       and (si.cod_inspetoria_Ts = p_cod_inspetoria_ts or p_cod_inspetoria_ts is null)
                     order by 1,2,3,4,5)
         loop
             v_posicao := 20;
             -- Quantidade de dias para processar a inadimplência
             v_qtd_dias_apos_venc :=  getparametrosistemavalor('QTD_DIAS_INADIMP_APOS_VENC',
                                                               CSI.cod_operadora,
                                                               CSI.cod_sucursal,
                                                               CSI.cod_inspetoria_ts,
                                                               NULL);
            -- Prazo considerado para análise de inadimplência (quantidade de meses)
            v_prazo_venc_retro_inadimpl := getparametrosistemavalor('PRAZO_VENC_RETRO_INADIMPL',
                                                                    CSI.cod_operadora,
                                                                    CSI.cod_sucursal,
                                                                    CSI.cod_inspetoria_ts,
                                                                    NULL);
            open curCob
            for v_sql
            using v_qtd_dias_apos_venc,
                  v_prazo_venc_retro_inadimpl,
                  CSI.tipo_empresa,
                  CSI.tipo_empresa,
                  CSI.cod_sucursal,
                  CSI.cod_operadora,
                  CSI.cod_inspetoria_ts;
            loop
                fetch curCob  bulk collect into rsCob limit 100;
                v_posicao := 25;
                EXIT  WHEN rsCob.count = 0;
                for i in 1..rsCob.count
                loop
                    v_posicao := 30;
                    IF v_cod_ts_contrato_ant != rsCob(i).cod_ts_contrato OR
                       NVL(v_cod_entidade_ts_ant,-1) != NVL(rsCob(i).cod_entidade_ts,-1) OR
                       NVL(v_cod_ts_ant,-1) != NVL(rsCob(i).cod_ts,-1) THEN
                       --
                       IF rsCob(i).cod_ts is not null THEN
                          v_cod_inadimplencia := rsCob(i).cod_inadimplencia_ass;
                       ELSIF rsCob(i).cod_entidade_ts is not null THEN
                          v_cod_inadimplencia := rsCob(i).cod_inadimplencia_emp;
                       ELSE
                          v_cod_inadimplencia := rsCob(i).cod_inadimplencia_cont;
                       END IF;
                       IF rsCob(i).COD_ENTIDADE_TS = rsCob(i).COD_TS THEN
                          v_cod_entidade_ts_aux := -1;
                       ELSE
                          v_cod_entidade_ts_aux := rsCob(i).COD_ENTIDADE_TS;
                       END IF;
                       -- Verificação de Segurança para garantir que ainda existem cobranças vencidas
                       v_sql2 := 'SELECT   MAX(TRUNC (SYSDATE) ';
                       v_sql2 := v_sql2 || '         - DECODE (NVL (co.tipo_venc_inadimplencia, 1),';
                       v_sql2 := v_sql2 || '         1, ';
                       v_sql2 := v_sql2 || '         TRUNC (co.dt_vencimento), ';
                       v_sql2 := v_sql2 || '         2, ';
                       v_sql2 := v_sql2 || '         TRUNC (fa.dt_vencimento))) ';
                       v_sql2 := v_sql2 || '         dias_atraso ';
                       v_sql2 := v_sql2 || '  FROM   cobranca co, ';
                       v_sql2 := v_sql2 || '         contrato_empresa ce, ';
                       v_sql2 := v_sql2 || '         tipo_contrato tc, ';
                       v_sql2 := v_sql2 || '         beneficiario b, ';
                       v_sql2 := v_sql2 || '         fatura fa ';
                       v_sql2 := v_sql2 || ' WHERE   co.ind_estado_cobranca = ''0'' ';
                       v_sql2 := v_sql2 || '     AND DECODE (NVL (co.tipo_venc_inadimplencia, 1), ';
                       v_sql2 := v_sql2 || '         1, ';
                       v_sql2 := v_sql2 || '         co.dt_vencimento, ';
                       v_sql2 := v_sql2 || '         2,  ';
                       v_sql2 := v_sql2 || '         fa.dt_vencimento) < TRUNC (SYSDATE) - :v_qtd_dias_apos_venc';
                       v_sql2 := v_sql2 || '     AND DECODE (NVL (co.tipo_venc_inadimplencia, 1),';
                       v_sql2 := v_sql2 || '         1, ';
                       v_sql2 := v_sql2 || '         co.dt_vencimento, ';
                       v_sql2 := v_sql2 || '         2, ';
                       v_sql2 := v_sql2 || '         fa.dt_vencimento) > ADD_MONTHS (SYSDATE, - :v_prazo_venc_retro_inadimpl)';
                       v_sql2 := v_sql2 || '     AND co.dt_emissao IS NOT NULL ';
                       v_sql2 := v_sql2 || '     AND fa.ind_situacao = ''2'' ';                        -- emitida
                       v_sql2 := v_sql2 || '     AND co.val_a_pagar > 0 ';
                       v_sql2 := v_sql2 || '     AND fa.num_seq_fatura_ts = co.num_seq_fatura_ts ';
                       v_sql2 := v_sql2 || '     AND co.cod_ts_contrato = ce.cod_ts_contrato ';
                       v_sql2 := v_sql2 || '     AND ce.cod_tipo_contrato = tc.cod_tipo_contrato ';
                       v_sql2 := v_sql2 || '     AND co.cod_ts = b.cod_ts(+) ';
                       v_sql2 := v_sql2 || '     AND co.cod_ts_contrato = :p_cod_ts_contrato ';
                       v_sql2 := v_sql2 || '     AND (:p_cod_ts IS NULL OR (:p_cod_ts IS NOT NULL AND co.cod_ts = :p_cod_ts)) ';
                       v_sql2 := v_sql2 || '     AND ce.ind_situacao != ''E''   ';                                                               -- contratos ativos
                       v_sql2 := v_sql2 || '     AND (co.cod_ts IS NULL OR (co.cod_ts IS NOT NULL AND NVL (b.ind_situacao, ''A'') != ''E'')) '; -- beneficiários ativos
                       v_sql2 := v_sql2 || '     AND NOT EXISTS ';
                       v_sql2 := v_sql2 || '         (SELECT 1 ';
                       v_sql2 := v_sql2 || '            FROM associado_desemprego ad ';
                       v_sql2 := v_sql2 || '           WHERE ad.cod_ts = co.cod_ts AND co.dt_competencia BETWEEN ad.mes_ini_isencao AND ad.mes_fim_isencao) ';
                       v_sql2 := v_sql2 || '     AND NOT EXISTS ';
                       v_sql2 := v_sql2 || '         (SELECT 1 ';
                       v_sql2 := v_sql2 || '            FROM acao_jud_pgto aj ';
                       v_sql2 := v_sql2 || '           WHERE aj.cod_ts_contrato = co.cod_ts_contrato ';
                       v_sql2 := v_sql2 || '             AND AJ.cod_ts is null  ';
                       v_sql2 := v_sql2 || '             AND aj.dt_ini_acao <= SYSDATE ';
                       v_sql2 := v_sql2 || '             AND NVL (aj.ind_inadimplencia, ''N'') = ''N'' ';
                       v_sql2 := v_sql2 || '             AND (aj.dt_fim_acao IS NULL OR aj.dt_fim_acao >= SYSDATE)) ';
                       v_sql2 := v_sql2 || '     AND NOT EXISTS ';
                       v_sql2 := v_sql2 || '         (SELECT 1 ';
                       v_sql2 := v_sql2 || '            FROM acao_jud_pgto ap ';
                       v_sql2 := v_sql2 || '           WHERE ap.cod_ts = co.cod_ts ';
                       v_sql2 := v_sql2 || '             AND NVL (ap.ind_inadimplencia, ''N'') = ''N'' ';
                       v_sql2 := v_sql2 || '             AND ap.dt_ini_acao <= SYSDATE ';
                       v_sql2 := v_sql2 || '             AND (ap.dt_fim_acao IS NULL OR ap.dt_fim_acao >= SYSDATE)) ';
                       BEGIN
                          EXECUTE IMMEDIATE v_sql2
                             INTO v_dias_atraso
                            USING v_qtd_dias_apos_venc,
                                  v_prazo_venc_retro_inadimpl,
                                  rsCob(i).cod_ts_contrato,
                                  rsCob(i).cod_ts,
                                  rsCob(i).cod_ts,
                                  rsCob(i).cod_ts;
                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             v_dias_atraso := 0;
                          WHEN OTHERS THEN
                             v_erro_oracle := top_utl_padrao.MsgErro;
                             p_msg_retorno_out := 'Erro crítica de retaguarda de cobranças vencidas :'||top_utl_padrao.MsgErro ;
                             RAISE err_nao_previsto;
                       END;
                       IF v_dias_atraso > 0 THEN
                          IF rsCob(i).ind_apos_dem in ('A','D') THEN
                             v_ind_apos_dem := 'S';
                          ELSE
                             v_ind_apos_dem := 'N';
                          END IF;
                          SUR_TRATA_INADIMPLENCIA (rsCob(i).cod_ts_contrato,
                                                   rsCob(i).cod_ts_contrato_dental,
                                                   v_cod_entidade_ts_aux,
                                                   rsCob(i).cod_ts,
                                                   CSI.cod_operadora,
                                                   CSI.cod_sucursal,
                                                   CSI.cod_inspetoria_ts,
                                                   CSI.tipo_empresa,
                                                   rsCob(i).dias_atraso,
                                                   rsCob(i).dt_vencimento,
                                                   v_cod_inadimplencia,
                                                   rsCob(i).num_seq_cobranca,
                                                   rsCob(i).dt_competencia,
                                                   rsCob(i).ind_acao_jud,
                                                   v_ind_apos_dem,
                                                   CSI.ind_regra_dias_inadimplencia,
                                                   v_prazo_venc_retro_inadimpl,
                                                   rsCob(i).ind_tipo_pessoa,
                                                   nvl(p_cod_usuario,'JOB'),
                                                   'S',
                                                   v_ind_inadimplente,
                                                   v_ind_erro,
                                                   v_msg_retorno);
                          IF v_ind_erro != '0' THEN
                             p_msg_retorno_out := v_msg_retorno;
                             v_erro_oracle :='Erro gerado pela PROCEDURE SUR_TRATA_INADIMPLENCIA.';
                             RAISE ERR_NAO_PREVISTO;
                          END IF;
                       END IF;
                       <<PROXIMO>>
                       v_posicao := 40;
                       v_cod_ts_contrato_ant := rsCob(i).cod_ts_contrato;
                       v_cod_entidade_ts_ant := rsCob(i).cod_entidade_ts;
                       v_cod_ts_ant := rsCob(i).cod_ts;
                    END IF;
                    if nvl(p_commit,'S') = 'S' then
                       COMMIT;
                    end if;
                end loop;
             END LOOP;
             TS_LOG_EXECUCAO ( 'SUR_VERIFICA_INADIMPLENCIA', 0, 0, v_txt_parametros, 'cod_operadora ' || CSI.cod_operadora || ' cod_sucursal ' || CSI.cod_sucursal || ' cod_inspetoria_ts ' || CSI.cod_inspetoria_ts || ' tipo_empresa ' || CSI.tipo_empresa);
         END LOOP;
         v_posicao := 90;
         if nvl(p_commit,'S') = 'S' then
            COMMIT;
         end if;
      EXCEPTION
         WHEN err_advertencia THEN
            p_ind_erro_out := '3';
            raise err_trata_erro;
         WHEN err_previsto THEN
            p_ind_erro_out := '1';
            RAISE err_trata_erro;
         WHEN err_nao_previsto THEN
            p_ind_erro_out := '2';
            RAISE err_trata_erro;
         WHEN OTHERS THEN
            p_msg_retorno_out := top_utl_padrao.MsgErro;
            v_erro_oracle := top_utl_padrao.MsgErro;
            p_ind_erro_out := '2';
            RAISE err_trata_erro;
      END;
   EXCEPTION
   WHEN err_trata_erro THEN
        ts_log_execucao ('SUR_VERIFICA_INADIMPLENCIA',
                         v_posicao,
                         v_erro_oracle,
                         v_txt_parametros,
                         p_msg_retorno_out,
                         1);
         ROLLBACK;
END;
