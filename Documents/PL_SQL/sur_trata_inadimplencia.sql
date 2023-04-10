CREATE OR REPLACE PROCEDURE TA_MASTER.SUR_TRATA_INADIMPLENCIA(
   p_cod_ts_contrato           IN   varchar2,
   p_cod_ts_contrato_dental    IN   varchar2,
   p_cod_entidade_ts           IN   number,
   p_cod_ts                    IN   number,
   p_cod_operadora             IN   VARCHAR2,
   p_cod_sucursal              IN   NUMBER,
   p_cod_inspetoria_ts         IN   NUMBER,
   p_tipo_empresa              IN   NUMBER,
   p_dias_atraso               IN   NUMBER,
   p_dt_vencimento             IN   DATE,
   p_cod_inadimplencia         IN   number,
   p_num_seq_cobranca          IN   number,
   p_mes_ano_ref               IN   DATE,
   p_ind_acao_jud              IN   char,
   p_ind_apos_dem              IN   char,
   p_ind_regra_dias            IN   char,
   p_prazo_venc_retro_inadimpl IN   pls_integer,
   p_tipo_pessoa_contrato      IN   char,
   p_cod_usuario               IN   varchar2,
   p_ind_trata_exclusao        IN   varchar2,        -- S/N
   p_ind_inadimplente          OUT nocopy VARCHAR2,  -- S/N
   p_ind_erro_out              OUT nocopy VARCHAR2,  -- 0 Realizado com sucesso
                                                     -- 1 Erro previsto
                                                     -- 2 Erro não previsto
                                                     -- 3 Advertência
   p_msg_retorno_out           OUT nocopy     VARCHAR2,
   p_versao              IN       VARCHAR2 DEFAULT 'N') authid current_user IS
/*** VERSÃO ORIGINAL **********************************************************************************
  Versão de Origem: 1.24 -> V9
/*** AUTOR E DATA DA CRIAÇÃO **************************************************************************
  Top-Down - 17/09/2013 - Rotina que efetua o tratamento da inadimplencia de uma cobrança.
  Versão inicial: 1.1
/*** MANUTENÇÕES **************************************************************************************
  ALTERAÇÃO  : SAC 60105 - Cancelamento das faturas pendentes
  SOLICITANTE: All Care
  DATA       : 28/07/2016
  ANALISTA   : Eldair Pinheiro
 ******************************************************************************************************
  ALTERAÇÃO  : SAC 63225 - Alteração cancelamento das faturas pendentes
  SOLICITANTE: Allcare
  DATA       : 22/12/2016
  ANALISTA   : Eldair Pinheiro  
 ******************************************************************************************************
  ALTERAÇÃO  : SAC 63225 - Alteração para recuperação da data de suspensão, filtrar movimentos cancelados
  SOLICITANTE: Allcare
  DATA       : 26/12/2016
  ANALISTA   : Eldair Pinheiro    
 ******************************************************************************************************
  ALTERAÇÃO  : SAC 63225 - Alteração para recuperação da data de cancelamento da fatura
  SOLICITANTE: Allcare
  DATA       : 16/01/2017
  ANALISTA   : Eldair Pinheiro     
 ******************************************************************************************************
  ALTERAÇÃO  : SAC 72203 - Adicionado o codigo da inadimplencia para verificar as cartas criadas.
  SOLICITANTE: CASE
  DATA       : 23/03/2018
  ANALISTA   : Ayrton Garcia
 ******************************************************************************************************/
   -- Variáveis Gerais
   ERR_TRATA_ERRO                   EXCEPTION;
   ERR_PREVISTO                     EXCEPTION;
   ERR_NAO_PREVISTO                 EXCEPTION;
   ERR_ADVERTENCIA                  EXCEPTION;
   v_posicao                        pls_integer;
   v_txt_versao                     VARCHAR2(1000);
   v_txt_parametros                 VARCHAR2(3000);
   v_erro_oracle                    VARCHAR2(300);
   -- Variáveis Específicas
   v_cod_inadimplencia              number(5);
   v_cod_inadimplencia_anterior     number(5);
   v_ind_situacao_contrato          char(1);
   v_ind_situacao_associado         char(1);
   v_ind_situacao_associado_wrk     char(1);
   v_cod_situacao_associado         pls_integer;
   v_cod_motivo_exclusao            pls_integer;
   v_ind_tipo_carta                 number(2);
   v_ind_tipo_carta_exige           number(2);
   v_data_exclusao                  date;
   v_ind_situacao_contrato_atual    char(1);
   v_cod_entidade_ts                number(15);
   v_cod_ts                         number(15);
   v_situacao_apos_dem              char(1);
   v_mes_ini_deposito_jud           date;
   v_mes_fim_deposito_jud           date;
   v_cod_cancelamento_contrato      pls_integer;
   v_dias_atraso                    pls_integer;
   v_dias_atraso_acum               pls_integer;
   v_ind_situacao                   char(1);
   v_ind_libera_inadimplencia       BOOLEAN;
   v_qtd_parcelas                   NUMBER;
   v_dt_vencimento_max              date;
   v_num_controle_carta_ts          number(15);
   v_usuario_exc                    varchar2(20);
   v_cod_produto                    varchar2(10);
   v_dt_registro_exc                DATE;
   v_dt_prazo_pagamento             date;
   v_query                          varchar2(32760);
   v_query_dias                     varchar2(32760);
   v_query_parcelas                 varchar2(32760);
   curSit                           sys_refcursor;
   v_ind_aviso_rec                  char(1);
   v_ind_cancela_faturas            char(1);
   v_exclui_apos_dem                char(1);
   v_ind_tipo_carta_a_emitir        number(2);
   v_data_atual                     date;
   v_id_rastreamento                varchar2(17);
   v_data_exclusao_wrk              date;
   v_usa_data_fato_exclusao         varchar2(1);
   v_data_canc_fatura               date;
   v_data_suspensao                 date;
      
   type rSit   is record (cod_inadimplencia         number(5),
                          ind_situacao_contrato     char(1),
                          ind_situacao_associado    char(1),
                          cod_situacao_associado    pls_integer,
                          ind_tipo_carta            pls_integer,
                          cod_cancelamento_contrato pls_integer,
                          ind_tipo_carta_exige      pls_integer,
                          qtd_dias_atraso           pls_integer,
                          qtd_parcelas_atraso       pls_integer,
                          ind_aviso_rec             char(1),
                          ind_cancela_faturas       char(1));
   type tSit is table of rSit index by pls_integer;
   rsSit                            tSit;
--
procedure Recupera_inadimplencia(p_dias_atraso_in              IN  pls_integer,
                                 p_qtd_parcelas_in             IN  pls_integer,
                                 p_tipo_carta_in               IN  pls_integer,
                                 p_somente_nao_exc_in          IN  char,
                                 p_cod_inadimplencia_out       OUT nocopy number,
                                 p_ind_situacao_contrato_out   OUT nocopy char,
                                 p_ind_situacao_associado_out  OUT nocopy char,
                                 p_cod_situacao_associado_out  OUT nocopy pls_integer,
                                 p_ind_tipo_carta_out          OUT nocopy pls_integer,
                                 p_cod_canc_contrato_out       OUT nocopy pls_integer,
                                 p_ind_tipo_carta_exige_out    OUT nocopy pls_integer,
                                 p_ind_aviso_rec_out           OUT nocopy char,
                                 p_ind_cancela_faturas_out     OUT nocopy char) is
   v_qtd_parcelas_atraso     pls_integer;
   v_qtd_dias_atraso         pls_integer;
   i                         pls_integer;
BEGIN
   p_cod_inadimplencia_out := -1;
   if p_qtd_parcelas_in is null then
       open curSit
       for v_query_dias
       using p_cod_ts_contrato,
             p_ind_apos_dem,
             p_cod_operadora,
             p_cod_sucursal,
             p_cod_inspetoria_ts,
             p_tipo_empresa,
             p_tipo_carta_in,
             p_tipo_carta_in,
             p_somente_nao_exc_in,
             p_somente_nao_exc_in,
             p_dias_atraso_in;
       loop
          fetch curSit bulk collect into rsSit limit 100;
          exit when rsSit.count = 0;
          i:= 1;
          p_cod_inadimplencia_out      := rsSit(i).cod_inadimplencia;
          p_ind_situacao_contrato_out  := rsSit(i).ind_situacao_contrato;
          p_ind_situacao_associado_out := rsSit(i).ind_situacao_associado;
          p_cod_situacao_associado_out := rsSit(i).cod_situacao_associado;
          p_ind_tipo_carta_out         := rsSit(i).ind_tipo_carta;
          p_cod_canc_contrato_out      := rsSit(i).cod_cancelamento_contrato;
          p_ind_tipo_carta_exige_out   := rsSit(i).ind_tipo_carta_exige;
          p_ind_aviso_rec_out          := rsSit(i).ind_aviso_rec;
          p_ind_cancela_faturas_out    := rsSit(i).ind_cancela_faturas;
          EXIT;
       end loop;
   else
       open curSit
       for v_query_parcelas
       using p_cod_ts_contrato,
             p_ind_apos_dem,
             p_cod_operadora,
             p_cod_sucursal,
             p_cod_inspetoria_ts,
             p_tipo_empresa,
             p_tipo_carta_in,
             p_tipo_carta_in,
             p_somente_nao_exc_in,
             p_somente_nao_exc_in,
             p_qtd_parcelas_in;
       loop
          fetch curSit bulk collect into rsSit limit 100;
          exit when rsSit.count = 0;
          for i in 1 .. rsSit.count
          loop
              p_cod_inadimplencia_out      := rsSit(i).cod_inadimplencia;
              p_ind_situacao_contrato_out  := rsSit(i).ind_situacao_contrato;
              p_ind_situacao_associado_out := rsSit(i).ind_situacao_associado;
              p_cod_situacao_associado_out := rsSit(i).cod_situacao_associado;
              p_ind_tipo_carta_out         := rsSit(i).ind_tipo_carta;
              p_cod_canc_contrato_out      := rsSit(i).cod_cancelamento_contrato;
              v_qtd_dias_atraso            := rsSit(i).qtd_dias_atraso;
              v_qtd_parcelas_atraso        := rsSit(i).qtd_parcelas_atraso;
              p_ind_tipo_carta_exige_out   := rsSit(i).ind_tipo_carta_exige;
              p_ind_aviso_rec_out          := rsSit(i).ind_aviso_rec;
              p_ind_cancela_faturas_out    := rsSit(i).ind_cancela_faturas;
              if (rsSit(i).qtd_parcelas_atraso = p_qtd_parcelas_in and rsSit(i).qtd_dias_atraso <= p_dias_atraso_in) or
                 (rsSit(i).qtd_parcelas_atraso < p_qtd_parcelas_in) then
                EXIT;
              end if;
          end loop;
       end loop;
       if v_qtd_parcelas_atraso = 1 and
          v_qtd_dias_atraso > p_dias_atraso_in then
           p_cod_inadimplencia_out := -1;
       end if;
    end if;
EXCEPTION
WHEN OTHERS THEN
    p_msg_retorno_out := 'Erro na recuperação da situação de inadimplencia, qtd_dias_atraso: '|| p_dias_atraso_in ||' e tipo_empresa: '|| p_tipo_empresa || '.';
    v_erro_oracle := top_utl_padrao.MsgErro;
    RAISE ERR_NAO_PREVISTO;
END;

PROCEDURE FINALIZA_ADITIVO(pdataexclusao date, pCodTSContrato number, pCodTS number, pCodEntidadeTS number) IS
    v_sql   varchar2(4000);
BEGIN
   v_sql := ' UPDATE associado_aditivo aa ' ||
            ' SET aa.DT_FIM_VIGENCIA = GREATEST(:pdataexclusao, AA.DT_INI_VIGENCIA) ' ||
            '    ,aa.dt_atu          = Sysdate ' ||
            '    ,aa.COD_USUARIO_ATU = :p_cod_usuario ' ||
            ' WHERE EXISTS (SELECT 1 ' ||
            '               FROM associado ass, contrato_empresa CE ' ||
            '               WHERE ASS.cod_ts_Contrato = CE.cod_ts_contrato ' ||
            '                 AND ass.cod_ts          = aa.cod_ts ' ||
            '                 AND ass.ind_situacao    = ''E''     ' ||
            '                 AND CE.cod_ts_contrato = :pCodTSContrato ';
   if pcodts is not null then
        v_sql := v_sql || ' AND ass.cod_ts_tit  = :pcodts ';
    else
        v_sql := v_sql || ' AND nvl(:pcodts,-1) = -1 ';
    end if;
    if pcodentidadets is not null then
        v_sql := v_sql || ' AND ass.cod_empresa  = :pcodentidadets ';
    else
        v_sql := v_sql || ' AND nvl(:pcodentidadets,-1) = -1 ';
    end if;
    v_sql := v_sql || ' AND ass.data_exclusao   = :pdataexclusao ' ||
                      ' AND NVL(ind_isento, ''N'') != ''S'' )' ||
                      ' AND (AA.DT_FIM_VIGENCIA IS NULL OR AA.DT_FIM_VIGENCIA > GREATEST(:pdataexclusao, AA.DT_INI_VIGENCIA)) ' ||
                      ' AND AA.DT_INI_VIGENCIA = (SELECT MAX(DT_INI_VIGENCIA)' ||
                      '                           FROM ASSOCIADO_ADITIVO AA2 ' ||
                      '                           WHERE AA.COD_TS          = AA2.COD_TS ' ||
                      '                             AND AA.COD_TS_CONTRATO = AA2.COD_TS_CONTRATO) ';
    execute immediate v_sql
    using pdataexclusao,
          p_cod_usuario,
          pCodTSContrato,
          pcodts,
          pcodentidadets,
          pdataexclusao,
          pdataexclusao;
 EXCEPTION
  WHEN OTHERS THEN
     p_msg_retorno_out := 'Erro na execução da Exclusão dos aditivos : '||top_utl_padrao.MsgErro;
     RAISE ERR_NAO_PREVISTO;
END;
BEGIN
   BEGIN
      BEGIN
         -- Teste da Versão
         v_txt_versao := '$Revision: 12755 $';
         IF NVL (p_versao, 'N') = 'S' THEN
            p_ind_erro_out := 0;
            p_msg_retorno_out := v_txt_versao;
            RETURN;
         END IF;
         -- Área de inicialização.
         v_posicao := 10;
         p_ind_erro_out := '0';
         p_msg_retorno_out := '';
         v_data_atual := trunc(SYSDATE);
         p_ind_inadimplente := 'S';
         v_dias_atraso := p_dias_atraso;
         v_txt_parametros := v_txt_versao
                          || ', p_cod_ts_contrato: '   || p_cod_ts_contrato
                          || ', p_cod_ts_contrato_dental: ' || p_cod_ts_contrato_dental
                          || ', p_cod_entidade_ts: '   || p_cod_entidade_ts
                          || ', p_cod_ts: '            || p_cod_ts
                          || ', p_cod_operadora: '     || p_cod_operadora
                          || ', p_cod_sucursal: '      || p_cod_sucursal
                          || ', p_cod_inspetoria_ts: ' || p_cod_inspetoria_ts
                          || ', p_dias_atraso: '       || p_dias_atraso
                          || ', p_dt_vencimento: '     || to_char(p_dt_vencimento,'dd/mm/RRRR')
                          || ', p_tipo_empresa: '      || p_tipo_empresa
                          || ', p_cod_inadimplencia: ' || p_cod_inadimplencia
                          || ', p_num_seq_cobranca: '  || p_num_seq_cobranca
                          || ', p_mes_ano_ref: '       || to_char(p_mes_ano_ref,'dd/mm/RRRR')
                          || ', p_ind_acao_jud: '      || p_ind_acao_jud
                          || ', p_ind_apos_dem: '      || p_ind_apos_dem
                          || ', p_ind_regra_dias: '    || p_ind_regra_dias
                          || ', p_cod_usuario: '       || p_cod_usuario
                          || ', p_ind_trata_exclusao: '|| p_ind_trata_exclusao;
         -- Início da Rotina
         v_posicao := 20;
         v_cod_inadimplencia_anterior := NVL (p_cod_inadimplencia, -1);
         IF p_cod_entidade_ts = -1 THEN
            v_cod_entidade_ts := NULL;
         ELSE
            v_cod_entidade_ts := p_cod_entidade_ts;
         END IF;
         IF p_cod_ts is not null THEN
            v_cod_ts := p_cod_ts;
            -- Verifica se Beneficiário era antigo titular e foi excluido devido ao Beneficio Familia (SEA/PEA)
            -- neste caso pega novo titular do grupo familiar
            v_posicao := 30;
            BEGIN
              execute immediate ' SELECT cod_ts      ' ||
                                ' FROM associado_sea ' ||
                                ' WHERE cod_ts_tit_original = :cod_ts '
              into v_cod_ts
              using v_cod_ts;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  p_msg_retorno_out := 'Erro na verificação de Beneficiário SEA. v_cod_ts :' || v_cod_ts;
                  RAISE ERR_NAO_PREVISTO;
            END;
         END IF;
         --
         -- parâmetro que será usado para exclusão dos Aposentados/Demitidos
         v_posicao := 23;
         BEGIN
            select NVL(val_parametro, 'N')
            into v_exclui_apos_dem
            from controle_sistema
            where cod_parametro = 'EXCLUIR_APOS_DEM';
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_exclui_apos_dem := 'N';
         END;
     --
         v_query_dias :=  ' SELECT si.cod_inadimplencia,   ' ||
                          '  si.ind_situacao_contrato,     ' ||
                          '  si.ind_situacao_associado,    ' ||
                          '  si.cod_situacao_associado,    ' ||
                          '  si.ind_tipo_carta,            ' ||
                          '  si.cod_cancelamento_contrato, ' ||
                          '  si.ind_tipo_carta_exige,      ' ||
                          '  si.qtd_dias_atraso,           ' ||
                          '  si.qtd_parcelas_atraso,       ' ||
                          '  si.ind_aviso_rec,             ' ||
                          '  si.ind_cancela_faturas        ' ||
                          '  FROM (SELECT DECODE (sc.cod_ts_contrato, NULL, si.cod_inadimplencia, sc.cod_inadimplencia)      cod_inadimplencia,     ' ||
                          '          si.nom_situacao, ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.qtd_dias_atraso, sc.qtd_dias_atraso)               qtd_dias_atraso,       ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.qtd_parcelas_atraso, sc.qtd_parcelas_atraso)       qtd_parcelas_atraso,   ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.ind_atendimento, sc.ind_atendimento)               ind_atendimento,       ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.ind_situacao_contrato, sc.ind_situacao_contrato)   ind_situacao_contrato, ' ||
                          '          si.tipo_empresa,      ' ||
                          '          si.cod_operadora,     ' ||
                          '          si.cod_sucursal,      ' ||
                          '          si.cod_inspetoria_ts, ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.ind_situacao_associado, sc.ind_situacao_associado) ind_situacao_associado, ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.cod_situacao_associado, sc.cod_situacao_associado) cod_situacao_associado, ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.ind_tipo_carta, sc.ind_tipo_carta)                 ind_tipo_carta, ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.cod_cancelamento_contrato, sc.cod_cancelamento_contrato) cod_cancelamento_contrato, ' ||
                          '          DECODE (sc.cod_ts_contrato, NULL, si.ind_tipo_carta_exige, sc.ind_tipo_carta_exige)     ind_tipo_carta_exige, ' ||
                          '          DECODE (sc.ind_aviso_rec, NULL, si.ind_aviso_rec, sc.ind_aviso_rec) ind_aviso_rec, ' ||
                          '          DECODE (sc.ind_cancela_faturas, NULL, si.ind_cancela_faturas, sc.ind_cancela_faturas) ind_cancela_faturas, ' ||
                          '          si.ind_tipo_regra '||
                          '    FROM situacao_inadimplencia si,    ' ||
                          '         situacao_inadimpl_contrato sc ' ||
                          '    WHERE si.ind_tipo_regra    = 1 '|| -- Atualiza Cadastro
                          '      AND si.cod_inadimplencia     =  sc.cod_inadimplencia(+) ' ||
                          '      AND sc.cod_ts_contrato   (+) =  :p_cod_ts_contrato      ' ||
                          '      AND sc.dt_validade       (+) >= trunc(sysdate)          ' ||
                          '      AND sc.ind_regra_inativo (+) =  :p_ind_apos_dem) si     ' ||
                          ' WHERE si.ind_tipo_regra    = 1 ' || -- Atualiza Cadastro
                          '   AND si.cod_operadora     = :p_cod_operadora     ' ||
                          '   AND si.cod_sucursal      = :p_cod_sucursal      ' ||
                          '   AND si.cod_inspetoria_ts = :p_cod_inspetoria_ts ' ||
                          '   AND si.tipo_empresa      = :p_tipo_empresa      ' ||
                          '   AND ((si.ind_tipo_carta = :p_tipo_carta_in) OR :p_tipo_carta_in = -1) ' || -- com carta tipo definido ou todos
                          '   AND ((si.ind_situacao_associado != ''E'' and :p_somente_nao_exc_in = ''S'') OR :p_somente_nao_exc_in = ''N'') ' || -- Somente não excluído ou Todos
                          '   AND si.qtd_dias_atraso <= :p_dias_atraso_in  ' ||
                          '  order by si.qtd_dias_atraso DESC ';
      v_query_parcelas := 'SELECT si.cod_inadimplencia,    ' ||
                      '      si.ind_situacao_contrato,     ' ||
                      '      si.ind_situacao_associado,    ' ||
                      '      si.cod_situacao_associado,    ' ||
                      '      si.ind_tipo_carta,            ' ||
                      '      si.cod_cancelamento_contrato, ' ||
                      '      si.ind_tipo_carta_exige, ' ||
                      '      si.qtd_dias_atraso,      ' ||
                      '      si.qtd_parcelas_atraso   ' ||
                      '      si.ind_aviso_rec,        ' ||
                      '      si.ind_cancela_faturas   ' ||
                      ' FROM (SELECT DECODE (sc.cod_ts_contrato, NULL, si.cod_inadimplencia, sc.cod_inadimplencia)           cod_inadimplencia,  ' ||
                      '              si.nom_situacao,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.qtd_dias_atraso, sc.qtd_dias_atraso)               qtd_dias_atraso,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.qtd_parcelas_atraso, sc.qtd_parcelas_atraso)       qtd_parcelas_atraso,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.ind_atendimento, sc.ind_atendimento)               ind_atendimento,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.ind_situacao_contrato, sc.ind_situacao_contrato)   ind_situacao_contrato,  ' ||
                      '              si.tipo_empresa,       ' ||
                      '              si.cod_operadora,      ' ||
                      '              si.cod_sucursal,       ' ||
                      '              si.cod_inspetoria_ts,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.ind_situacao_associado, sc.ind_situacao_associado) ind_situacao_associado,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.cod_situacao_associado, sc.cod_situacao_associado) cod_situacao_associado,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.ind_tipo_carta, sc.ind_tipo_carta)                 ind_tipo_carta,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.cod_cancelamento_contrato, sc.cod_cancelamento_contrato) cod_cancelamento_contrato,  ' ||
                      '              DECODE (sc.cod_ts_contrato, NULL, si.ind_tipo_carta_exige, sc.ind_tipo_carta_exige)     ind_tipo_carta_exige  ' ||
                      '              DECODE (sc.ind_aviso_rec, NULL, si.ind_aviso_rec, sc.ind_aviso_rec) ind_aviso_rec, ' ||
                      '              DECODE (sc.ind_cancela_faturas, NULL, si.ind_cancela_faturas, sc.ind_cancela_faturas) ind_cancela_faturas, '||
                      '              si.ind_tipo_regra '||
                      '        FROM situacao_inadimplencia si,      ' ||
                      '             situacao_inadimpl_contrato sc   ' ||
                      '        WHERE si.ind_tipo_regra        = 1   ' ||
                      '          AND si.cod_inadimplencia     =  sc.cod_inadimplencia(+) ' ||
                      '          AND sc.cod_ts_contrato   (+) =  :p_cod_ts_contrato      ' ||
                      '          AND sc.dt_validade       (+) >= trunc(sysdate)          ' ||
                      '          AND sc.ind_regra_inativo (+) =  :p_ind_apos_dem) si     ' ||
                      ' WHERE si.ind_tipo_regra    = 1  '||
                      '   AND si.cod_operadora     = :p_cod_operadora      ' ||
                      '   AND si.cod_sucursal      = :p_cod_sucursal       ' ||
                      '   AND si.cod_inspetoria_ts = :p_cod_inspetoria_ts  ' ||
                      '   AND si.tipo_empresa      = :p_tipo_empresa       ' ||
                      '   AND ((si.ind_tipo_carta = :p_tipo_carta_in) OR :p_tipo_carta_in = -1)  ' || -- com carta tipo definido ou todos
                      '   AND ((si.ind_situacao_associado != ''E'' and :p_somente_nao_exc_in = ''S'') OR :p_somente_nao_exc_in = ''N'')  ' || -- Somente não excluído ou Todos
                      '   AND si.qtd_parcelas_atraso <= :p_qtd_parcelas_in ' ||
                      ' order by si.qtd_parcelas_atraso DESC, si.qtd_dias_atraso DESC ';
         --
         v_posicao := 40;
         IF p_ind_regra_dias = 'A' THEN
            -- Apura quantidade de dias de atraso acumulado de cobranças baixadas
            v_dias_atraso_acum := 0;
            v_posicao := 50;
            BEGIN
              v_query := ' SELECT NVL(SUM (NVL (co.qtd_dias_atraso, 0) - NVL (co.qtd_dias_anistia_atraso, 0)),0) ' ||
                         ' FROM cobranca co, fatura fa  ' ||
                         ' WHERE co.cod_ts_contrato = :p_cod_ts_contrato     ' ||
                         '   AND co.num_seq_fatura_ts = fa.num_seq_fatura_ts ' ||
                         '   AND co.ind_estado_cobranca = ''1''              ' ||
                         '   AND decode(nvl(co.tipo_venc_inadimplencia,1),   ' ||
                         '              1,co.dt_vencimento,  ' ||
                         '              2,fa.dt_vencimento) > ADD_MONTHS(:p_dt_vencimento, - :p_prazo_venc_retro_inadimpl)  ';
              if v_cod_ts is not null then
                 v_query := v_query || ' AND co.cod_ts = :v_cod_ts  ' ||
                                       ' AND NVL(:v_cod_entidade_ts,-1) = -1  ';
              elsif v_cod_entidade_ts is not null then
                 v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 ' ||
                                       ' AND co.cod_entidade_ts = :v_cod_entidade_ts  ' ||
                                       ' AND co.cod_ts IS NULL  ';
              else
                 v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 ' ||
                                       ' AND NVL(:v_cod_entidade_ts,-1) = -1  ' ||
                                       ' AND co.cod_entidade_ts IS NULL ' ||
                                       ' AND co.cod_ts IS NULL ';
              end if;
               execute immediate v_query
               into v_dias_atraso_acum
               using p_cod_ts_contrato,
                     p_dt_vencimento,
                     p_prazo_venc_retro_inadimpl,
                     v_cod_ts,
                     v_cod_entidade_ts;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_dias_atraso_acum := 0;
               WHEN OTHERS THEN
                  v_erro_oracle := top_utl_padrao.MsgErro;
                  p_msg_retorno_out := 'Erro na verificação de dias de inadimplência acumuladas das cobranças baixadas.';
                  RAISE err_nao_previsto;
            END;
            v_dias_atraso := v_dias_atraso + v_dias_atraso_acum;
         END IF;
         -- recupera situação da inadimplência conforme tabela de parametros
         v_posicao := 60;
         v_ind_libera_inadimplencia := FALSE;
         IF p_ind_regra_dias != 'P' THEN
            v_posicao := 70;
            Recupera_inadimplencia(v_dias_atraso,
                                   NULL,
                                   -1,
                                   'N',
                                   v_cod_inadimplencia,
                                   v_ind_situacao_contrato,
                                   v_ind_situacao_associado,
                                   v_cod_situacao_associado,
                                   v_ind_tipo_carta,
                                   v_cod_cancelamento_contrato,
                                   v_ind_tipo_carta_exige,
                                   v_ind_aviso_rec,
                                   v_ind_cancela_faturas);
            if v_cod_inadimplencia = -1 then
               -- Débito ainda não é considerado uma inadimplência
               v_ind_libera_inadimplencia := TRUE;
            end if;
         ELSE
            -- Novo Tratamento por Quantidade de Parcelas em Atraso
            v_posicao := 80;
            v_dt_vencimento_max := NULL;
            v_qtd_parcelas := 0;
            BEGIN
               v_query := ' SELECT COUNT (1), MAX(decode(nvl(co.tipo_venc_inadimplencia,1),1,co.dt_vencimento,2,fa.dt_vencimento))  ' ||
                                 ' FROM cobranca co, fatura fa  ' ||
                                 ' WHERE co.cod_ts_contrato = :p_cod_ts_contrato  ' ||
                                 '   AND co.num_seq_fatura_ts = fa.num_seq_fatura_ts  ' ||
                                 '   AND co.ind_estado_cobranca = ''0''   ' ||
                                 '   AND co.dt_emissao IS NOT NULL        ' ||
                                 '   AND co.val_a_pagar > 0               ' ||
                                 '   AND decode(nvl(co.tipo_venc_inadimplencia,1), ' ||
                                 '              1,co.dt_vencimento, ' ||
                                 '              2,fa.dt_vencimento) > :p_dt_vencimento - :p_prazo_venc_retro_inadimpl ';
              if v_cod_ts is not null then
                 v_query := v_query || ' AND co.cod_ts = :v_cod_ts  ' ||
                                       ' AND NVL(:v_cod_entidade_ts,-1) = -1  ';
              elsif v_cod_entidade_ts is not null then
                 v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 ' ||
                                       ' AND co.cod_entidade_ts = :v_cod_entidade_ts  ' ||
                                       ' AND co.cod_ts IS NULL  ';
              else
                 v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 ' ||
                                       ' AND NVL(:v_cod_entidade_ts,-1) = -1  ' ||
                                       ' AND co.cod_entidade_ts IS NULL ' ||
                                       ' AND co.cod_ts IS NULL ';
              end if;
               execute immediate v_query
               INTO v_qtd_parcelas, v_dt_vencimento_max
               using p_cod_ts_contrato,
                     p_dt_vencimento,
                     p_prazo_venc_retro_inadimpl,
                     v_cod_ts,
                     v_cod_entidade_ts;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_qtd_parcelas := 0;
            END;
            -- Verifica se tem parcelas em atraso
            v_posicao := 90;
            IF v_qtd_parcelas != 0 THEN
               -- Descobre quantidade de Dias de atraso da parcela mais recente
               v_posicao := 100;
               v_dias_atraso := TRUNC(SYSDATE) - TRUNC(v_dt_vencimento_max);
               -- Procura situação de Inadimplência
               Recupera_inadimplencia(v_dias_atraso,
                                      v_qtd_parcelas,
                                      -1,
                                      'N',
                                      v_cod_inadimplencia,
                                      v_ind_situacao_contrato,
                                      v_ind_situacao_associado,
                                      v_cod_situacao_associado,
                                      v_ind_tipo_carta,
                                      v_cod_cancelamento_contrato,
                                      v_ind_tipo_carta_exige,
                      v_ind_aviso_rec,
                      v_ind_cancela_faturas);
               IF v_cod_inadimplencia = -1 THEN
                  -- Débito ainda não é considerado uma inadimplência
                  v_ind_libera_inadimplencia := TRUE;
               END IF;
               --
            ELSE
               v_ind_libera_inadimplencia := TRUE;
            END IF;
         END IF;
         --
         -- LIBERA INADIMPLÊNCIA
         --
         v_posicao := 120;
         IF v_ind_libera_inadimplencia THEN
            p_ind_inadimplente := 'N';
            -- Verifica indicador de exportação
            IF v_cod_inadimplencia_anterior != -1 THEN
               v_posicao := 140;
               BEGIN
                  execute immediate ' UPDATE cobranca '||
                                    '  SET cod_inadimplencia = NULL,  '||
                                    '      data_inadimplencia = NULL, '||
                                    '      cod_usuario_atu = :p_cod_usuario, '||
                                    '      dt_atu = sysdate '||
                                    ' WHERE num_seq_cobranca = :p_num_seq_cobranca '
                  using p_cod_usuario,
                        p_num_seq_cobranca;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_msg_retorno_out := 'Erro na atualização  da tabela cobranca : num_seq_cobranca : ' || p_num_seq_cobranca;
                     v_erro_oracle := top_utl_padrao.MsgErro;
                     RAISE err_nao_previsto;
               END;
            END IF;
            RETURN;
         END IF;
         -- Não excluir beneficiários durante a execução da reve inadimplência de um contrato.
         if p_ind_trata_exclusao = 'N' and v_ind_situacao_associado = 'E' then
            RETURN;
         end if;
         --
         -- ATUALIZA INADIMPLÊNCIA
         --
         -- Verifica se Contrato já está na situação de inadimplência
         v_posicao := 150;
         v_num_controle_carta_ts := NULL;
         IF v_cod_inadimplencia_anterior != v_cod_inadimplencia THEN
            -- Se for para excluir verifica emissão da carta
            IF v_ind_situacao_associado = 'E' AND
               v_ind_tipo_carta_exige IS NOT NULL THEN
               v_query := ' SELECT MAX (num_controle_carta_ts) ' ||
                          ' FROM controle_carta co ' ||
                          ' WHERE cod_ts_contrato   = :p_cod_ts_contrato ' ||
                          '   AND co.ind_tipo_carta = :v_ind_tipo_carta_exige  ' ||
                          '   AND nvl(ind_ativa,''S'') = ''S''  ';
               if v_cod_ts is not null THEN
                  v_query := v_query || ' AND co.cod_ts = :v_cod_ts '
                                     || ' AND NVL(:v_cod_entidade_ts,-1) = -1 ';
               elsif v_cod_entidade_ts is not null then
                  v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 '
                                     || ' AND co.cod_entidade_ts = :v_cod_entidade_ts '
                                     || ' AND co.cod_ts IS NULL';
               else
                  v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 '
                                     || ' AND NVL(:v_cod_entidade_ts,-1) = -1 '
                                     || ' AND co.cod_entidade_ts IS NULL '
                                     || ' AND co.cod_ts IS NULL';
               end if;
               execute immediate v_query
               into v_num_controle_carta_ts
               using p_cod_ts_contrato,
                     v_ind_tipo_carta_exige,
                     v_cod_ts,
                     v_cod_entidade_ts;
               --
               -- Verifica prazo de emissao da carta
               IF v_num_controle_carta_ts IS NOT NULL THEN
                  execute immediate ' SELECT dt_prazo_pagamento ' ||
                                    ' FROM controle_carta ' ||
                                    ' WHERE num_controle_carta_ts = :v_num_controle_carta_ts '
                  into v_dt_prazo_pagamento
                  using v_num_controle_carta_ts;
                  --
                  IF v_dt_prazo_pagamento > sysdate or v_dt_prazo_pagamento is null THEN -- Se não passou o prazo para recebimento
                     if p_ind_regra_dias != 'P' THEN
                        Recupera_inadimplencia(v_dias_atraso,
                                               NULL,
                                               -1,
                                               'S',
                                               v_cod_inadimplencia,
                                               v_ind_situacao_contrato,
                                               v_ind_situacao_associado,
                                               v_cod_situacao_associado,
                                               v_ind_tipo_carta,
                                               v_cod_cancelamento_contrato,
                                               v_ind_tipo_carta_exige,
                         v_ind_aviso_rec,
                         v_ind_cancela_faturas);
                        if v_cod_inadimplencia = -1 then
                           -- Não modifica a situação do Beneficiario;
                           RETURN;
                        end if;
                     else
                        Recupera_inadimplencia(v_dias_atraso,
                                               v_qtd_parcelas,
                                               -1,
                                               'S',
                                               v_cod_inadimplencia,
                                               v_ind_situacao_contrato,
                                               v_ind_situacao_associado,
                                               v_cod_situacao_associado,
                                               v_ind_tipo_carta,
                                               v_cod_cancelamento_contrato,
                                               v_ind_tipo_carta_exige,
                         v_ind_aviso_rec,
                         v_ind_cancela_faturas);
                        if v_cod_inadimplencia = -1 then
                           -- Não modifica a situação do Beneficiario
                           RETURN;
                        end if;
                     end if;
                     if v_cod_inadimplencia = v_cod_inadimplencia_anterior then
                         -- Já está na situação correta, não modifica a situação do Beneficiario
                         RETURN;
                     end if;
                  end if;
               ELSE
                  v_ind_tipo_carta_a_emitir := v_ind_tipo_carta_exige;
                  -- Não tem carta então faz o envio
                  IF p_ind_regra_dias != 'P' THEN
                      Recupera_inadimplencia(v_dias_atraso,
                                             NULL,
                                             v_ind_tipo_carta_a_emitir,
                                             'S',
                                             v_cod_inadimplencia,
                                             v_ind_situacao_contrato,
                                             v_ind_situacao_associado,
                                             v_cod_situacao_associado,
                                             v_ind_tipo_carta,
                                             v_cod_cancelamento_contrato,
                                             v_ind_tipo_carta_exige,
                                             v_ind_aviso_rec,
                                             v_ind_cancela_faturas);
                      if v_cod_inadimplencia = -1 then
                         -- Não modifica a situação do Beneficiario;
                         RETURN;
                      end if;
                  else
                      Recupera_inadimplencia(v_dias_atraso,
                                             v_qtd_parcelas,
                                             v_ind_tipo_carta_a_emitir,
                                             'S',
                                             v_cod_inadimplencia,
                                             v_ind_situacao_contrato,
                                             v_ind_situacao_associado,
                                             v_cod_situacao_associado,
                                             v_ind_tipo_carta,
                                             v_cod_cancelamento_contrato,
                                             v_ind_tipo_carta_exige,
                                             v_ind_aviso_rec,
                                             v_ind_cancela_faturas);
                      if v_cod_inadimplencia = -1 then
                         -- Não modifica a situação do Beneficiario;
                         RETURN;
                      end if;
                   END IF;
               END IF;
            END IF;
            -- atualiza situação inadimplencia da cobrança
            BEGIN
               execute immediate ' UPDATE cobranca '||
                                 ' SET cod_inadimplencia  = :v_cod_inadimplencia, '||
                                 '     data_inadimplencia = SYSDATE,              '||
                                 '     cod_usuario_atu    = :p_cod_usuario,       '||
                                 '     dt_atu = sysdate                           '||
                                 ' WHERE num_seq_cobranca = :p_num_seq_cobranca '
                using v_cod_inadimplencia,
                      p_cod_usuario,
                      p_num_seq_cobranca;
            EXCEPTION
               WHEN OTHERS THEN
                  p_msg_retorno_out := 'Erro na atualização do código de inadimplência da cobrança.';
                  v_erro_oracle := top_utl_padrao.MsgErro;
                  RAISE err_nao_previsto;
            END;
            IF v_ind_tipo_carta IS NOT NULL THEN
               -- Calcula a data de cancelamento
               v_posicao := 160;
               v_cod_produto := NULL;
               -- limpa carta pendente de emissão para não gerar duas cartas
               BEGIN
                  FOR c_prod IN (SELECT pm.cod_produto
                                 FROM contrato_plano cp, plano_medico pm
                                 WHERE cp.cod_ts_contrato = p_cod_ts_contrato
                                 AND cp.cod_plano = pm.cod_plano
                                 AND cp.dt_ini_vigencia = (SELECT MAX (cp2.dt_ini_vigencia)
                                                           FROM contrato_plano cp2
                                                           WHERE cp2.cod_ts_contrato = cp.cod_ts_contrato
                                                           AND cp2.dt_ini_vigencia <= SYSDATE))
                  LOOP
                  v_cod_produto := c_prod.cod_produto;
                  EXIT;
                  END LOOP;
                  DELETE controle_carta
                  WHERE dt_emissao IS NULL
                    AND cod_ts_contrato = p_cod_ts_contrato
                    AND ((v_cod_entidade_ts IS NULL AND cod_entidade_ts IS NULL) OR
                         (v_cod_entidade_ts IS NOT NULL AND cod_entidade_ts = v_cod_entidade_ts))
                    AND ((v_cod_ts IS NULL AND cod_ts IS NULL) OR
                         (v_cod_ts IS NOT NULL AND cod_ts = v_cod_ts));
               EXCEPTION
               WHEN others THEN
                   p_msg_retorno_out := 'Erro na exclusão de carta não emitida : p_cod_ts_contrato = '||p_cod_ts_contrato||', v_cod_entidade_ts = '||v_cod_entidade_ts||', v_cod_ts = '||v_cod_ts||'.';
                   v_erro_oracle := top_utl_padrao.MsgErro;
                   RAISE ERR_NAO_PREVISTO;
               END;
               -- Verifica se já tem carta emitida
               v_num_controle_carta_ts := NULL;
               v_query := ' SELECT MAX (num_controle_carta_ts) ' ||
                          ' FROM controle_carta co ' ||
                          ' WHERE cod_ts_contrato   = :p_cod_ts_contrato ' ||
                          '   AND co.ind_tipo_carta = :v_ind_tipo_carta_exige  ' ||
                          '   AND co.cod_inadimplencia = :v_cod_inadimplencia ' ||
                          '   AND nvl(ind_ativa,''S'') = ''S''  ';
               if v_cod_ts is not null THEN
                  v_query := v_query || ' AND co.cod_ts = :v_cod_ts '
                                     || ' AND NVL(:v_cod_entidade_ts,-1) = -1 ';
               elsif v_cod_entidade_ts is not null then
                  v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 '
                                     || ' AND co.cod_entidade_ts = :v_cod_entidade_ts '
                                     || ' AND co.cod_ts IS NULL';
               else
                  v_query := v_query || ' AND NVL(:v_cod_ts,-1) = -1 '
                                     || ' AND NVL(:v_cod_entidade_ts,-1) = -1 '
                                     || ' AND co.cod_entidade_ts IS NULL '
                                     || ' AND co.cod_ts IS NULL';
               end if;
               execute immediate v_query
               into v_num_controle_carta_ts
               using p_cod_ts_contrato,
                     v_ind_tipo_carta,
                     v_cod_inadimplencia,
                     v_cod_ts,
                     v_cod_entidade_ts;
               --
               -- Se não achou carta emitir
               IF v_num_controle_carta_ts IS NULL THEN
                  -- gera registro de Carta de Cobrança
                   v_posicao := 170;
                   BEGIN
                      v_id_rastreamento := substr(to_char(current_timestamp,'ddmmyhh24miSSFF'),1,17);
                      INSERT INTO controle_carta
                      (num_controle_carta_ts, cod_ts_contrato, cod_entidade_ts, cod_ts,
                       cod_inadimplencia, dt_geracao, ind_tipo_carta, ind_regra_dias_inadimplencia, id_rastreamento,
                       dt_atu, cod_usuario_atu, ind_situacao_carta, cod_produto, ind_aviso_rec)
                      VALUES
                      (ts_controle_carta_seq.NEXTVAL, p_cod_ts_contrato, v_cod_entidade_ts, v_cod_ts,
                       v_cod_inadimplencia, SYSDATE, v_ind_tipo_carta, p_ind_regra_dias, v_id_rastreamento,
                       sysdate, p_cod_usuario, '0', v_cod_produto, v_ind_aviso_rec);
                   EXCEPTION
                   WHEN OTHERS THEN
                       p_msg_retorno_out := 'Erro na geração do registro de Carta de Cobrança.';
                       v_erro_oracle := top_utl_padrao.MsgErro;
                       RAISE ERR_NAO_PREVISTO;
                   END;
               END IF;
            END IF;
            --*** POR ASSOCIADO  Mudou código de inadimplencia
            v_posicao := 190;
            IF v_cod_ts IS NOT NULL THEN
               -- trata inadimplencia de Associado
               v_posicao := 200;
               IF p_tipo_pessoa_contrato = 'F' THEN
                  -- Atualiza situação do Contrato pois o Contrato é de PF
                  FOR REG IN (select cod_ts_contrato,
                                 ind_situacao,
                                 NVL(cod_inadimplencia,-1) cod_inadimplencia
                              from contrato_empresa
                              where ind_situacao != 'E'
                                and (cod_ts_contrato = p_cod_ts_contrato
                                  or cod_ts_contrato = p_cod_ts_contrato_dental) )
                  LOOP
                      v_posicao := 210;
                      BEGIN
                         execute immediate ' UPDATE contrato_empresa ' ||
                                           ' SET ind_situacao = :v_ind_situacao_contrato, ' ||
                                           '     cod_inadimplencia  = :v_cod_inadimplencia, ' ||
                                           '     data_inadimplencia = SYSDATE, ' ||
                                           '     cod_usuario_atu    = :p_cod_usuario, ' ||
                                           '     dt_atu = sysdate ' ||
                                           ' WHERE cod_ts_contrato = :p_cod_ts_contrato ' ||
                                           '   AND ( NVL(ind_situacao, ''Z'') != :v_ind_situacao_contrato ' ||
                                           '      OR NVL(cod_inadimplencia, -1) != :v_cod_inadimplencia) '
                         using v_ind_situacao_contrato,
                               v_cod_inadimplencia,
                               p_cod_usuario,
                               REG.cod_ts_contrato,
                               v_ind_situacao_contrato,
                               v_cod_inadimplencia;
                      EXCEPTION
                      WHEN OTHERS THEN
                          p_msg_retorno_out := 'Erro na atualização da situação do contrato (' || p_cod_ts_contrato || ').';
                          v_erro_oracle := top_utl_padrao.MsgErro;
                          RAISE ERR_NAO_PREVISTO;
                      END;
                      -- Trata Encerramente do Contrato
                      IF SQL%ROWCOUNT = 1 THEN
                         IF v_ind_situacao_contrato = 'E' THEN
                             v_posicao := 220;
                             BEGIN
                                execute immediate ' UPDATE contrato_empresa ' ||
                                                  ' SET data_fim_vigencia = TRUNC (SYSDATE), ' ||
                                                  '     cod_cancelamento = :v_cod_cancelamento_contrato, ' ||
                                                  '     cod_usuario_atu = :p_cod_usuario, ' ||
                                                  '     dt_atu = sysdate                  ' ||
                                                  ' WHERE cod_ts_contrato = :p_cod_ts_contrato '
                                using v_cod_cancelamento_contrato,
                                      p_cod_usuario,
                                      REG.cod_ts_contrato;
                             EXCEPTION
                             WHEN OTHERS THEN
                                 p_msg_retorno_out := 'Erro na atualização data fim de vigência do contrato (' || p_cod_ts_contrato || ').';
                                 v_erro_oracle := top_utl_padrao.MsgErro;
                                 RAISE ERR_NAO_PREVISTO;
                             END;
                             -- Gera Ocorrência
                             INSERT INTO ocorrencia_contrato
                             (cod_ts_contrato, cod_ocorrencia, dt_ocorrencia, cod_usuario_atu, txt_obs, dt_fato)
                             VALUES
                             (REG.cod_ts_contrato, 4, SYSDATE, p_cod_usuario, 'Cancelamento automático do Contrato por Inadimplência', v_data_atual);
                         ELSIF v_ind_situacao_contrato = 'I' THEN
                             -- Gera Ocorrência
                             INSERT INTO ocorrencia_contrato
                             (cod_ts_contrato, cod_ocorrencia, dt_ocorrencia, cod_usuario_atu, txt_obs, dt_fato)
                             VALUES
                             (REG.cod_ts_contrato, 23, SYSDATE, p_cod_usuario, 'Suspensão automática do Contrato por Inadimplência', v_data_atual);
                         END IF;
                      END IF;
                  END LOOP;
               END IF;
               -- atualiza situação de todos os associados vinculados ao Responsável
               v_posicao := 230;
               v_data_exclusao_wrk := null;
               FOR ca IN (SELECT cod_ts, ind_situacao, data_exclusao, cod_motivo_exclusao, usuario_exc, data_registro_exclusao, tipo_Associado
                          FROM associado
                          WHERE ((cod_ts_contrato = p_cod_ts_contrato and cod_ts_tit = v_cod_ts) or (cod_ts_contrato = p_cod_ts_contrato_dental))
                            AND ind_situacao IN ('A', 'S', 'P')
                            order by tipo_associado desc)
               LOOP
                  v_posicao := 240;
                  IF ca.ind_situacao = 'P' THEN
                     -- No caso de patrocinador mantém situação, só atualiza demais campos
                     v_ind_situacao_associado_wrk := 'P';
                  ELSE
                     v_ind_situacao_associado_wrk := v_ind_situacao_associado;
                  END IF;
                  v_posicao := 240;          
                  -- se associado passar para excluído então deve-se atualizar a data de exclusao e motivo de exclusão
                  IF v_ind_situacao_associado = 'E' THEN
             v_data_exclusao_wrk := trunc(sysdate);             
                     IF ca.tipo_associado in ('T','P') THEN
                        -- Define data de cancelamento das faturas a partir da ultima suspensão
            v_data_canc_fatura := v_data_exclusao_wrk;
                        IF ca.ind_situacao = 'S' THEN
                           -- obtém data da suspensão
                           v_posicao := 241;                           
                           begin
                             select nvl(trim(val_parametro_default),'N')
                             into v_usa_data_fato_exclusao
                             from parametro_sistema 
                             where cod_parametro = 'FAT_EXCLUSAO_NA_DATA_DO_FATO';   
                           exception
                           when others then                
                      v_usa_data_fato_exclusao := 'N';
                           end;
                           --                        
               if v_usa_data_fato_exclusao = 'S' then
                   begin
                     select trunc(max(dt_atu))
                                 into v_data_suspensao
                                 from associado_operadora 
                                 where cod_ts = v_cod_ts
                                   and ind_tipo_movimento = 'N'
                                   and ind_situacao != 4;
                               exception
                               when others then               
                                   v_data_suspensao := null;
                               end;               
                               if v_data_suspensao < v_data_exclusao_wrk then
                                   v_data_canc_fatura := v_data_suspensao;
                               end if;
                           end if;
                        END IF;
                     end if;
                     if   (ca.data_exclusao is null)
                       or (ca.data_exclusao is not null and ca.data_exclusao > v_data_exclusao_wrk )  then
                        v_data_exclusao   := v_data_exclusao_wrk;
                        v_usuario_exc     := p_cod_usuario;
                        v_dt_registro_exc := sysdate;
                        v_cod_motivo_exclusao := v_cod_situacao_associado;
                     else
                        -- Se já tiver data exclusão não sobrepor pois a emissão de novas faturas pode postegar indefinidamente a exclusão do associado inadimplente
                        v_data_exclusao := ca.data_exclusao;
                        v_usuario_exc := ca.usuario_exc;
                        v_dt_registro_exc := ca.data_registro_exclusao;
                        v_cod_motivo_exclusao := ca.cod_motivo_exclusao;
                     end if;
                     -- Verifica se ficará com data de exclusão futura , Este teste estava fora do IF, e desta forma não colocava Inativos como suspenso pois estes tinham data exclusao futura
                     v_posicao := 250;
                     IF v_data_exclusao > v_data_exclusao_wrk THEN
                        v_ind_situacao := ca.ind_situacao;
                     ELSE
                        v_ind_situacao := 'E';
                     END IF;
                  ELSE
                     v_data_exclusao := ca.data_exclusao;
                     v_usuario_exc := ca.usuario_exc;
                     v_dt_registro_exc := ca.data_registro_exclusao;
                     v_cod_motivo_exclusao := ca.cod_motivo_exclusao;
                     v_ind_situacao := v_ind_situacao_associado_wrk;
                  END IF;
                  -- Atualiza situação dos Associados
                  v_posicao := 260;
                  BEGIN
                     execute immediate ' UPDATE associado ass ' ||
                                       ' SET ind_situacao = :v_ind_situacao,                ' ||
                                       '     cod_inadimplencia = :v_cod_inadimplencia,      ' ||
                                       '     data_inadimplencia = SYSDATE,                  ' ||
                                       '     cod_motivo_exclusao = :v_cod_motivo_exclusao,  ' ||
                                       '     data_exclusao = :v_data_exclusao,              ' ||
                                       '     usuario_exc = :v_usuario_exc,                  ' ||
                                       '     data_registro_exclusao = :v_dt_registro_exc,   ' ||
                                       '     cod_usuario_atu = :p_cod_usuario,              ' ||
                                       '     dt_atu = sysdate     ' ||
                                       ' WHERE cod_ts = :v_cod_ts ' ||
                                       '   AND ((:v_ind_situacao_associado_wrk = ''E'') OR ' ||
                                       '         (ind_situacao != ''S'') OR               ' ||
                                       '         (ind_situacao = ''S'' AND NOT EXISTS (SELECT 1 ' ||
                                       '                                               FROM ASSOCIADO_SUSPENSO SUSP         ' ||
                                       '                                               WHERE ass.cod_ts = SUSP.cod_ts       ' ||
                                       '                                                 and (data_fim_suspensao IS NULL OR ' ||
                                       '                                                     trunc(data_fim_suspensao) > trunc(sysdate))))) ' ||
                                       ' AND (   NVL(ind_situacao, ''Z'') != :v_ind_situacao_associado_wrk ' ||
                                       '      OR NVL(cod_inadimplencia, -1) != :v_cod_inadimplencia) ' ||
                                       ' AND NVL(ind_isento, ''N'') != ''S'' '
                     using v_ind_situacao,
                           v_cod_inadimplencia,
                           v_cod_motivo_exclusao,
                           v_data_exclusao,
                           v_usuario_exc,
                           v_dt_registro_exc,
                           p_cod_usuario,
                           ca.cod_ts,
                           v_ind_situacao_associado_wrk,
                           v_ind_situacao_associado_wrk,
                           v_cod_inadimplencia;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_msg_retorno_out := 'Erro na atualização da situação do associado (' || ca.cod_ts || ')';
                        v_erro_oracle := top_utl_padrao.MsgErro;
                        RAISE ERR_NAO_PREVISTO;
                  END;
                  -- Finalizar os aditivo
                  IF v_ind_situacao = 'E' THEN
                     v_posicao := 265;
                     FINALIZA_ADITIVO(v_data_exclusao, p_cod_ts_contrato, ca.cod_ts, null);
                  END IF;
               END LOOP;
            --*** POR EMPRESA    Mudou código de inadimplencia
            ELSIF v_cod_entidade_ts IS NOT NULL THEN
                v_posicao := 270;
                BEGIN
                   execute immediate ' UPDATE empresa_contrato ' ||
                                     ' SET cod_inadimplencia = :v_cod_inadimplencia, ' ||
                                     '     data_inadimplencia = SYSDATE,     ' ||
                                     '     cod_usuario_atu = :p_cod_usuario, ' ||
                                     '     dt_atu = sysdate ' ||
                                     ' WHERE cod_ts_contrato = :p_cod_ts_contrato ' ||
                                     '   AND cod_entidade_ts = :v_cod_entidade_ts ' ||
                                     '   AND NVL (cod_inadimplencia, -1) != :v_cod_inadimplencia ' ||
                                     '   AND (dt_fim_validade IS NULL OR dt_fim_validade > SYSDATE)'
                   using v_cod_inadimplencia,
                         p_cod_usuario,
                         p_cod_ts_contrato,
                         v_cod_entidade_ts,
                         v_cod_inadimplencia;
                EXCEPTION
                   WHEN OTHERS THEN
                      p_msg_retorno_out := 'Erro na atualização da situação do contrato (' || p_cod_ts_contrato || ').';
                      v_erro_oracle := top_utl_padrao.MsgErro;
                      RAISE ERR_NAO_PREVISTO;
                END;
                -- Trata Encerramente do Contrato
                IF     SQL%ROWCOUNT = 1 THEN
                   IF v_ind_situacao_contrato = 'E' THEN
                       v_posicao := 280;
                       BEGIN
                          execute immediate ' UPDATE empresa_contrato        ' ||
                                            ' SET dt_fim_validade = SYSDATE, ' ||
                                            '     cod_usuario_atu = :p_cod_usuario,      ' ||
                                            '     dt_atu = sysdate                       ' ||
                                            ' WHERE cod_ts_contrato = :p_cod_ts_contrato ' ||
                                            '   AND cod_entidade_ts = :v_cod_entidade_ts '
                          using p_cod_usuario,
                                p_cod_ts_contrato,
                                v_cod_entidade_ts;
                       EXCEPTION
                          WHEN OTHERS THEN
                             p_msg_retorno_out := 'Erro na atualização data fim de validade da empresa Contrato ('|| p_cod_ts_contrato ||'-'|| v_cod_entidade_ts ||').';
                             v_erro_oracle := top_utl_padrao.MsgErro;
                             RAISE ERR_NAO_PREVISTO;
                       END;
                       -- Gera Ocorrência
                       BEGIN
                          INSERT INTO ocorrencia_contrato
                          (cod_ts_contrato, cod_ocorrencia, dt_ocorrencia, cod_usuario_atu, txt_obs, dt_fato)
                          VALUES
                          (p_cod_ts_contrato, 4, SYSDATE, p_cod_usuario, 'Cancelamento automático do empresa '||to_char(v_cod_entidade_ts)||' por Inadimplência', v_data_atual);
                       EXCEPTION
                          WHEN OTHERS THEN
                             p_msg_retorno_out := 'Erro na inserção da Ocorrência do Contrato.';
                             v_erro_oracle := top_utl_padrao.MsgErro;
                             RAISE ERR_NAO_PREVISTO;
                       END;
                   ELSE
                       -- Gera Ocorrência
                       BEGIN
                          INSERT INTO ocorrencia_contrato
                          (cod_ts_contrato, cod_ocorrencia, dt_ocorrencia, cod_usuario_atu, txt_obs, dt_fato)
                          VALUES
                          (p_cod_ts_contrato, 23, SYSDATE, p_cod_usuario, 'Suspensão automática do '||to_char(v_cod_entidade_ts)||' por Inadimplência', v_data_atual);
                       EXCEPTION
                          WHEN OTHERS THEN
                             p_msg_retorno_out := 'Erro na inserção da Ocorrência do Contrato.';
                             v_erro_oracle := top_utl_padrao.MsgErro;
                             RAISE ERR_NAO_PREVISTO;
                       END;
                   END IF;
                END IF;
                -- atualiza situação de todos os associados vinculados a Empresa
                v_posicao := 290;
                FOR ca IN (SELECT B.cod_ts,
                                  B.ind_situacao,
                                  B.data_exclusao,
                                  B.cod_ts_tit,
                                  BC.cod_motivo_exclusao,
                                  BC.usuario_exc,
                                  B.data_registro_exclusao,
                                  NVL(B_TIT.ind_apos_dem, 'N') ind_apos_dem,
                                  NVL(B_TIT.ind_acao_jud, 'N') ind_acao_jud
                            FROM beneficiario B,
                                 beneficiario_contrato  BC,
                                 beneficiario_contrato  B_TIT
                            WHERE B.cod_ts_TIT = B_TIT.cod_ts (+)
                              and B.cod_ts = BC.cod_ts (+)
                              AND B.cod_ts_contrato = p_cod_ts_contrato
                              and B.cod_empresa  = v_cod_entidade_ts
                              AND (v_cod_ts IS NULL OR (v_cod_ts IS NOT NULL AND B.cod_ts_tit = v_cod_ts))
                              AND B.ind_situacao IN ('A', 'S', 'P'))
                LOOP
                   -- Verifica Aposentado/Demitido
                   IF CA.ind_apos_dem = 'S' AND (v_ind_situacao_contrato != 'E' OR (v_ind_situacao_contrato = 'E' AND v_exclui_apos_dem = 'N')) THEN
                      v_posicao := 310;
                      BEGIN
                          execute immediate ' SELECT ind_situacao ' ||
                                            ' FROM aposentado_demitido ' ||
                                            ' WHERE cod_ts = :v_cod_ts_tit ' ||
                                            '   AND mes_ini_fat <= :p_mes_ano_ref ' ||
                                            '   AND (mes_fim_fat IS NULL OR mes_fim_fat >= :p_mes_ano_ref)'
                          into  v_situacao_apos_dem
                          using ca.cod_ts_tit,
                                p_mes_ano_ref,
                                p_mes_ano_ref;
                             GOTO PROXIMO_ASSOCIADO_EMP;
                      EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          NULL;
                      END;
                   END IF;
                   -- Verifica Ação Judicial
                   IF CA.ind_acao_jud = 'S' THEN
                      v_posicao := 320;
                      BEGIN
                          execute immediate ' SELECT mes_ini_deposito_jud, mes_fim_deposito_jud ' ||
                                            ' FROM acao_jud_pgto ' ||
                                            ' WHERE cod_ts = :v_cod_ts_tit                ' ||
                                            '   AND NVL(ind_inadimplencia, ''N'') = ''N'' ' ||   -- ação indica que Não deve tratar inadimplência
                                            '   AND mes_ini_fat >= :p_mes_ano_ref         ' ||
                                            '   AND ( mes_fim_fat IS NULL OR mes_fim_fat <= :p_mes_ano_ref)' ||
                                            '   AND rownum = 1 '
                          into  v_mes_ini_deposito_jud, v_mes_fim_deposito_jud
                          using ca.cod_ts_tit,
                                p_mes_ano_ref,
                                p_mes_ano_ref;
                         GOTO PROXIMO_ASSOCIADO_EMP;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            NULL;
                      END;
                   END IF;
                   IF ca.ind_situacao = 'P' THEN
                      -- No caso de patrocinador mantém situação, só atualiza demais campos
                      v_ind_situacao_associado_wrk := 'P';
                   ELSE
                      v_ind_situacao_associado_wrk := v_ind_situacao_associado;
                   END IF;
                   -- se associado passar para excluído então deve-se atualizar a data de exclusao
                   v_posicao := 330;
                   IF v_ind_situacao_associado = 'E' THEN
                      v_data_exclusao   := TRUNC(SYSDATE);
                      v_usuario_exc     := p_cod_usuario;
                      v_dt_registro_exc := sysdate;
                      v_cod_motivo_exclusao := v_cod_situacao_associado;
                   ELSE
                      v_data_exclusao   := ca.data_exclusao;
                      v_usuario_exc     := ca.usuario_exc;
                      v_dt_registro_exc := ca.data_registro_exclusao;
                      v_cod_motivo_exclusao := ca.cod_motivo_exclusao;
                   END IF;
                   -- Atualiza situação dos Associados
                   v_posicao := 340;
                   BEGIN
                      execute immediate ' UPDATE associado ass ' ||
                                        ' SET ind_situacao = :v_ind_situacao_associado_wrk, ' ||
                                        '     cod_inadimplencia = :v_cod_inadimplencia,     ' ||
                                        '     data_inadimplencia = SYSDATE,                 ' ||
                                        '     cod_motivo_exclusao = :v_cod_motivo_exclusao, ' ||
                                        '     data_exclusao = :v_data_exclusao, ' ||
                                        '     usuario_exc   = :v_usuario_exc,   ' ||
                                        '     data_registro_exclusao = :v_dt_registro_exc, ' ||
                                        '     cod_usuario_atu = :p_cod_usuario, ' ||
                                        '     dt_atu = sysdate     ' ||
                                        ' WHERE cod_ts = :v_cod_ts ' ||
                                        '   AND ((:v_ind_situacao_associado_wrk = ''E'') OR   ' ||
                                        '      (ind_situacao != ''S'' ) OR                    ' ||
                                        '      (ind_situacao = ''S'' AND NOT EXISTS (SELECT 1 ' ||
                                        '                                            FROM ASSOCIADO_SUSPENSO SUSP ' ||
                                        '                                            WHERE ass.cod_ts = SUSP.cod_ts ' ||
                                        '                                              and (data_fim_suspensao IS NULL OR ' ||
                                        '                                                  trunc(data_fim_suspensao) > trunc(sysdate))))) ' ||
                                        ' AND (   NVL (ind_situacao, ''Z'') != :v_ind_situacao_associado_wrk ' ||
                                        '      OR NVL (cod_inadimplencia, -1) != :v_cod_inadimplencia) ' ||
                                        ' AND NVL (ind_isento, ''N'') != ''S''  '
                       using v_ind_situacao_associado_wrk,
                             v_cod_inadimplencia,
                             v_cod_motivo_exclusao,
                             v_data_exclusao,
                             v_usuario_exc,
                             v_dt_registro_exc,
                             p_cod_usuario,
                             ca.cod_ts,
                             v_ind_situacao_associado_wrk,
                             v_ind_situacao_associado_wrk,
                             v_cod_inadimplencia;
                   EXCEPTION
                      WHEN OTHERS THEN
                         p_msg_retorno_out := 'Erro na atualização da situação do associado (' || ca.cod_ts || ').';
                         v_erro_oracle := top_utl_padrao.MsgErro;
                         RAISE ERR_NAO_PREVISTO;
                   END;
                    -- Finalizar os aditivos
                    IF v_ind_situacao_associado_wrk = 'E' THEN
                        FINALIZA_ADITIVO(v_data_exclusao, p_cod_ts_contrato, ca.cod_ts, null);
                    END IF;
                   <<PROXIMO_ASSOCIADO_EMP>>
                   NULL;
                END LOOP;
             ---*** POR CONTRATO   Mudou código de inadimplencia
             ELSE
                v_posicao := 350;
                FOR REG IN (select cod_ts_contrato,
                                   ind_situacao,
                                   NVL(cod_inadimplencia,-1) cod_inadimplencia
                            from contrato_empresa ce
                            where ind_situacao != 'E'
                              and cod_ts_contrato = p_cod_ts_contrato)
                LOOP
                    IF v_ind_situacao_contrato != 'E' THEN
                       execute immediate ' UPDATE contrato_empresa ' ||
                                         ' SET ind_situacao = :v_ind_situacao_contrato,  ' ||
                                         '     cod_inadimplencia = :v_cod_inadimplencia, ' ||
                                         '     data_inadimplencia = SYSDATE,     ' ||
                                         '     cod_usuario_atu = :p_cod_usuario, ' ||
                                         '     dt_atu = sysdate ' ||
                                         ' WHERE cod_ts_contrato = :v_cod_ts_contrato ' ||
                                         '   AND (   ind_situacao != :v_ind_situacao_contrato ' ||
                                         '      OR NVL (cod_inadimplencia, -1) != :v_cod_inadimplencia)'
                       using v_ind_situacao_contrato,
                             v_cod_inadimplencia,
                             p_cod_usuario,
                             REG.cod_ts_contrato,
                             v_ind_situacao_contrato,
                             v_cod_inadimplencia;
                       IF  SQL%ROWCOUNT = 1 THEN
                          -- Gera Ocorrência
                          INSERT INTO ocorrencia_contrato
                          (cod_ts_contrato, cod_ocorrencia, dt_ocorrencia, cod_usuario_atu, txt_obs, dt_fato)
                          VALUES
                          (REG.cod_ts_contrato, 23, SYSDATE, p_cod_usuario, 'Suspensão automática do contrato por Inadimplência', v_data_atual);
                       END IF;
                    ELSE
                       -- Trata Encerramente do Contrato
                       v_posicao := 360;
                       BEGIN
                          execute immediate ' UPDATE contrato_empresa  ' ||
                                            ' SET data_fim_vigencia = TRUNC(SYSDATE), ' ||
                                            '     cod_cancelamento = :v_cod_cancelamento_contrato, ' ||
                                            '     ind_situacao = :v_ind_situacao_contrato,  ' ||
                                            '     cod_inadimplencia = :v_cod_inadimplencia, ' ||
                                            '     data_inadimplencia = SYSDATE,             ' ||
                                            '     cod_usuario_atu = :p_cod_usuario,         ' ||
                                            '     dt_atu = sysdate                          ' ||
                                            ' WHERE cod_ts_contrato = :v_cod_ts_contrato    '
                          using v_cod_cancelamento_contrato,
                                v_ind_situacao_contrato,
                                v_cod_inadimplencia,
                                p_cod_usuario,
                                REG.cod_ts_contrato;
                       END;
                       IF  SQL%ROWCOUNT = 1 THEN
                          -- Gera Ocorrência
                          INSERT INTO ocorrencia_contrato
                          (cod_ts_contrato, cod_ocorrencia, dt_ocorrencia, cod_usuario_atu, txt_obs, dt_fato)
                          VALUES
                          (REG.cod_ts_contrato, 4, SYSDATE, p_cod_usuario, 'Cancelamento automático do contrato por inadimplência', v_data_atual);
                       END IF;
                    END IF;
                    -- atualiza todas as empresas do contrato
                    v_posicao := 370;
                    BEGIN
                       execute immediate ' UPDATE empresa_contrato ' ||
                                         '  SET cod_inadimplencia = :v_cod_inadimplencia, ' ||
                                         '      data_inadimplencia = SYSDATE, ' ||
                                         '      cod_usuario_atu = :p_cod_usuario, ' ||
                                         '      dt_atu = sysdate ' ||
                                         ' WHERE cod_ts_contrato = :v_cod_ts_contrato ' ||
                                         '  AND NVL (cod_inadimplencia, -1) != :v_cod_inadimplencia ' ||
                                         '  AND (   dt_fim_validade IS NULL ' ||
                                         '       OR dt_fim_validade > SYSDATE)'
                       using v_cod_inadimplencia,
                             p_cod_usuario,
                             REG.cod_ts_contrato,
                             v_cod_inadimplencia;
                    EXCEPTION
                       WHEN OTHERS THEN
                          p_msg_retorno_out := 'Erro na atualização das empresas do contrato. ('|| p_cod_ts_contrato ||').';
                          v_erro_oracle := top_utl_padrao.MsgErro;
                          RAISE ERR_NAO_PREVISTO;
                    END;
                END LOOP;
                -- atualiza situação de todos os associados vinculados ao Contrato
                v_posicao := 380;
                FOR CA IN (SELECT B.cod_ts,
                                  B.ind_situacao,
                                  B.data_exclusao,
                                  B.cod_ts_tit,
                                  BC.cod_motivo_exclusao,
                                  BC.usuario_exc,
                                  B.data_registro_exclusao,
                                  NVL(B_TIT.ind_apos_dem, 'N') ind_apos_dem,
                                  NVL(B_TIT.ind_acao_jud, 'N') ind_acao_jud
                            FROM beneficiario B,
                                 beneficiario_contrato  BC,
                                 beneficiario_contrato  B_TIT,
                                 contrato_empresa CE
                            WHERE B.cod_ts_contrato = CE.cod_ts_contrato
                              AND B.cod_ts_TIT = B_TIT.cod_ts (+)
                              and B.cod_ts = BC.cod_ts (+)
                              AND ce.cod_ts_contrato = p_cod_ts_contrato
                              AND (v_cod_ts IS NULL OR (v_cod_ts IS NOT NULL AND B.cod_ts_tit = v_cod_ts))
                              AND B.ind_situacao IN ('A', 'S', 'P'))
                LOOP
                   -- Verifica Aposentado/Demitido
                   IF CA.ind_apos_dem = 'S'  AND (v_ind_situacao_contrato != 'E' OR (v_ind_situacao_contrato = 'E' AND v_exclui_apos_dem = 'N')) THEN
                      v_posicao := 390;
                      BEGIN
                          execute immediate ' SELECT ind_situacao ' ||
                                            ' FROM aposentado_demitido ' ||
                                            ' WHERE cod_ts = :v_cod_ts_tit ' ||
                                            '   AND mes_ini_fat <= :p_mes_ano_ref ' ||
                                            '   AND (mes_fim_fat IS NULL OR mes_fim_fat >= :p_mes_ano_ref)'
                          into  v_situacao_apos_dem
                          using ca.cod_ts_tit,
                                p_mes_ano_ref,
                                p_mes_ano_ref;
                             GOTO PROXIMO_ASSOCIADO_CONT;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            NULL;
                      END;
                   END IF;
                   -- Verifica Ação Judicial
                   IF CA.ind_acao_jud = 'S' THEN
                      v_posicao := 400;
                      BEGIN
                          execute immediate ' SELECT mes_ini_deposito_jud, mes_fim_deposito_jud ' ||
                                            ' FROM acao_jud_pgto ' ||
                                            ' WHERE cod_ts = :v_cod_ts_tit                ' ||
                                            '   AND NVL(ind_inadimplencia, ''N'') = ''N'' ' ||   -- ação indica que Não deve tratar inadimplência
                                            '   AND mes_ini_fat >= :p_mes_ano_ref         ' ||
                                            '   AND (mes_fim_fat IS NULL OR mes_fim_fat <= :p_mes_ano_ref)' ||
                                            '   AND rownum = 1 '
                          into  v_mes_ini_deposito_jud, v_mes_fim_deposito_jud
                          using ca.cod_ts_tit,
                                p_mes_ano_ref,
                                p_mes_ano_ref;
                         GOTO PROXIMO_ASSOCIADO_CONT;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            NULL;
                      END;
                   END IF;
                   IF ca.ind_situacao = 'P' THEN
                      -- No caso de patrocinador mantém situação, só atualiza demais campos
                      v_ind_situacao_associado_wrk := 'P';
                   ELSE
                      v_ind_situacao_associado_wrk := v_ind_situacao_associado;
                   END IF;
                   -- se associado passar para excluído então deve-se atualizar a data de exclusao
                   v_posicao := 410;
                   IF v_ind_situacao_associado = 'E' THEN
                      v_data_exclusao := TRUNC(SYSDATE);
                      v_usuario_exc := p_cod_usuario;
                      v_dt_registro_exc := sysdate;
                      v_cod_motivo_exclusao := v_cod_situacao_associado;
                   ELSE
                      v_data_exclusao := ca.data_exclusao;
                      v_usuario_exc := ca.usuario_exc;
                      v_dt_registro_exc := ca.data_registro_exclusao;
                      v_cod_motivo_exclusao := ca.cod_motivo_exclusao;
                   END IF;
                   -- Atualiza situação dos Associados
                   v_posicao := 420;
                   BEGIN
                      execute immediate ' UPDATE associado ass ' ||
                                        ' SET ind_situacao = :v_ind_situacao_associado_wrk, ' ||
                                        '     cod_inadimplencia = :v_cod_inadimplencia,      ' ||
                                        '     data_inadimplencia = SYSDATE, ' ||
                                        '     cod_motivo_exclusao = :v_cod_motivo_exclusao, ' ||
                                        '     data_exclusao = :v_data_exclusao, ' ||
                                        '     usuario_exc =  :v_usuario_exc, ' ||
                                        '     data_registro_exclusao = :v_dt_registro_exc, ' ||
                                        '     cod_usuario_atu = :p_cod_usuario, ' ||
                                        '     dt_atu = sysdate ' ||
                                        ' WHERE cod_ts = :v_cod_ts ' ||
                                        ' AND ((:v_ind_situacao_associado_wrk = ''E'') OR ' ||
                                        '      (ind_situacao != ''S'' ) OR ' ||
                                        '      (ind_situacao = ''S'' AND NOT EXISTS (SELECT 1 ' ||
                                        '                                            FROM ASSOCIADO_SUSPENSO SUSP ' ||
                                        '                                            WHERE ass.cod_ts = SUSP.cod_ts ' ||
                                        '                                              and (data_fim_suspensao IS NULL OR ' ||
                                        '                                                  trunc(data_fim_suspensao) > trunc(sysdate))))) ' ||
                                        ' AND (ind_situacao != :v_ind_situacao_associado_wrk ' ||
                                        '      OR NVL (cod_inadimplencia, -1) != :v_cod_inadimplencia) ' ||
                                        ' AND NVL (ind_isento, ''N'') != ''S'' '
                      using v_ind_situacao_associado_wrk,
                            v_cod_inadimplencia,
                            v_cod_motivo_exclusao,
                            v_data_exclusao,
                            v_usuario_exc,
                            v_dt_registro_exc,
                            p_cod_usuario,
                            ca.cod_ts,
                            v_ind_situacao_associado_wrk,
                            v_ind_situacao_associado_wrk,
                            v_cod_inadimplencia;
                   EXCEPTION
                      WHEN OTHERS THEN
                         p_msg_retorno_out := 'Erro na atualização da situação do associado (' || ca.cod_ts || ').';
                         v_erro_oracle := top_utl_padrao.MsgErro;
                         RAISE ERR_NAO_PREVISTO;
                   END;
                   -- Finalizar os aditivos
                   IF v_ind_situacao_associado_wrk = 'E' THEN
                       FINALIZA_ADITIVO(v_data_exclusao, p_cod_ts_contrato, ca.cod_ts, null);
                   END IF;
                   <<PROXIMO_ASSOCIADO_CONT>>
                   NULL;
                END LOOP;
             END IF;
         ELSE
            -- A situação de inadimplência é a mesma, mas deve-se verificar se não foi mudado o status do contrato
            -- ou do Beneficiário
            -- Obtém Situação de Inadimplência do Contrato
             IF     NVL (p_ind_apos_dem, 'N') = 'N'
              AND v_cod_ts IS NULL THEN
              v_posicao := 430;
              FOR REG IN (select cod_ts_contrato,
                                 ind_situacao,
                                 NVL(cod_inadimplencia,-1) cod_inadimplencia
                          from contrato_empresa ce
                          where ind_situacao != 'E'
                            and ce.cod_ts_contrato = p_cod_ts_contrato)
              LOOP
                  v_posicao := 440;
                  IF v_ind_situacao_contrato != REG.ind_situacao THEN
                     ts_log_execucao ('SUR_TRATA_INADIMPLENCIA',
                                      v_posicao,
                                      'Contrato :'  || p_cod_ts_contrato ||
                                      ' com situação alterada de :' || v_ind_situacao_contrato_atual ||
                                      ' para:'|| v_ind_situacao_contrato,
                                      v_txt_parametros,
                                      p_msg_retorno_out);
                     IF v_ind_situacao_contrato = 'E' THEN
                        BEGIN
                           execute immediate ' UPDATE contrato_empresa ' ||
                                             ' SET ind_situacao = :v_ind_situacao_contrato, ' ||
                                             '     data_fim_vigencia = TRUNC (SYSDATE),     ' ||
                                             '     cod_cancelamento = :v_cod_cancelamento_contrato, ' ||
                                             '     cod_usuario_atu = :p_cod_usuario, ' ||
                                             '     dt_atu = sysdate ' ||
                                             ' WHERE cod_ts_contrato = :v_cod_ts_contrato'
                            using v_ind_situacao_contrato,
                                  v_cod_cancelamento_contrato,
                                  p_cod_usuario,
                                  REG.cod_ts_contrato;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_erro_oracle := top_utl_padrao.MsgErro;
                              p_msg_retorno_out := 'Erro na atualização da situação do contrato :' || p_cod_ts_contrato;
                              RAISE ERR_NAO_PREVISTO;
                        END;
                        -- Gera Ocorrência
                        INSERT INTO ocorrencia_contrato
                        (cod_ts_contrato, cod_ocorrencia, dt_ocorrencia, cod_usuario_atu, txt_obs, dt_fato)
                        VALUES
                        (REG.cod_ts_contrato, 4, SYSDATE, p_cod_usuario, 'Cancelamento automático do contrato por inadimplência', v_data_atual);
                     ELSE
                        BEGIN
                           execute immediate ' UPDATE contrato_empresa ' ||
                                             ' SET ind_situacao = :v_ind_situacao_contrato, ' ||
                                             '  cod_usuario_atu = :p_cod_usuario, ' ||
                                             '   dt_atu = sysdate ' ||
                                             ' WHERE cod_ts_contrato = :v_cod_ts_contrato '
                            using v_ind_situacao_contrato,
                                  p_cod_usuario,
                                  REG.cod_ts_contrato;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_erro_oracle := top_utl_padrao.MsgErro;
                              p_msg_retorno_out := 'Erro na atualização da situação do contrato :'|| p_cod_ts_contrato;
                              RAISE ERR_NAO_PREVISTO;
                        END;
                     END IF;
                  END IF;
              END LOOP;
              v_posicao := 450;
              --** POR EMPRESA  Revalida Situação de Beneficiários
              IF v_cod_entidade_ts IS NOT NULL THEN
                 v_posicao := 460;
                 IF v_ind_situacao_associado = 'E' THEN
                    BEGIN
                       execute immediate ' UPDATE associado ass ' ||
                                         ' SET ind_situacao = :v_ind_situacao_associado, ' ||
                                         '     data_exclusao = TRUNC(SYSDATE), ' ||
                                         '     cod_motivo_exclusao = :v_cod_situacao_associado, ' ||
                                         '     usuario_exc =  :p_cod_usuario,    ' ||
                                         '     data_registro_exclusao = sysdate, ' ||
                                         '     cod_usuario_atu = :p_cod_usuario, ' ||
                                         '     dt_atu = sysdate                  ' ||
                                         ' WHERE cod_ts_contrato = :p_cod_ts_contrato  ' ||
                                         ' AND cod_empresa = :v_cod_entidade_ts        ' ||
                                         ' AND ((:v_ind_situacao_associado = ''E'') OR ' ||
                                         '      (ind_situacao != ''S'' ) OR ' ||
                                         '      (ind_situacao = ''S'' AND NOT EXISTS (SELECT 1 ' ||
                                         '                                            FROM ASSOCIADO_SUSPENSO SUSP   ' ||
                                         '                                            WHERE ass.cod_ts = SUSP.cod_ts ' ||
                                         '                                              and (data_fim_suspensao IS NULL OR ' ||
                                         '                                                   trunc(data_fim_suspensao) > trunc(sysdate))))) ' ||
                                         ' AND (   :v_cod_ts IS NULL ' ||
                                         '      OR (:v_cod_ts IS NOT NULL AND (cod_ts_tit = :v_cod_ts)) ' ||
                                         '     ) ' ||
                                         ' AND ind_situacao != ''E'' ' ||
                                         ' AND ind_situacao != :v_ind_situacao_associado ' ||
                                         ' AND NVL (ind_isento, ''N'') != ''S'' '
                        using v_ind_situacao_associado,
                              v_cod_situacao_associado,
                              p_cod_usuario,
                              p_cod_usuario,
                              p_cod_ts_contrato,
                              v_cod_entidade_ts,
                              v_ind_situacao_associado,
                              v_cod_ts,
                              v_cod_ts,
                              v_cod_ts,
                              v_ind_situacao_associado;
                    EXCEPTION
                       WHEN OTHERS THEN
                          v_erro_oracle := top_utl_padrao.MsgErro;
                          p_msg_retorno_out := 'Erro na atualização da situação dos beneficiários da empresa, cod_ts_contrato: '|| p_cod_ts_contrato ||' - v_cod_entidade_ts : '|| v_cod_entidade_ts;
                          RAISE ERR_NAO_PREVISTO;
                    END;
                    -- Finalizar os aditivos
                     FINALIZA_ADITIVO (TRUNC(SYSDATE), p_cod_ts_contrato, NULL, v_cod_entidade_ts );
                 ELSE
                    BEGIN
                       execute immediate ' UPDATE associado ass ' ||
                                         ' SET ind_situacao = :v_ind_situacao_associado, ' ||
                                         '     cod_usuario_atu = :p_cod_usuario, ' ||
                                         '     dt_atu = sysdate ' ||
                                         ' WHERE cod_ts_contrato = :p_cod_ts_contrato ' ||
                                         ' AND cod_empresa = :v_cod_entidade_ts ' ||
                                         ' AND ((:v_ind_situacao_associado = ''E'') OR ' ||
                                         '      (ind_situacao != ''S'' ) OR ' ||
                                         '      (ind_situacao = ''S'' AND NOT EXISTS (SELECT 1 ' ||
                                         '                                            FROM ASSOCIADO_SUSPENSO SUSP ' ||
                                         '                                            WHERE ass.cod_ts = SUSP.cod_ts ' ||
                                         '                                             and (data_fim_suspensao IS NULL OR ' ||
                                         '                                                 trunc(data_fim_suspensao) > trunc(sysdate))))) ' ||
                                         ' AND ( :v_cod_ts IS NULL ' ||
                                         '      OR (:v_cod_ts IS NOT NULL AND cod_ts_tit = :v_cod_ts)) ' ||
                                         ' AND ind_situacao != ''E''  ' ||
                                         ' AND ind_situacao != :v_ind_situacao_associado ' ||
                                         ' AND NVL(ind_isento, ''N'') != ''S'' '
                          using v_ind_situacao_associado,
                                p_cod_usuario,
                                p_cod_ts_contrato,
                                v_cod_entidade_ts,
                                v_ind_situacao_associado,
                                v_cod_ts,
                                v_cod_ts,
                                v_cod_ts,
                                v_ind_situacao_associado;
                    EXCEPTION
                       WHEN OTHERS THEN
                          v_erro_oracle := top_utl_padrao.MsgErro;
                          p_msg_retorno_out := 'Erro na atualização da situação dos beneficiários da empresa, cod_ts_contrato: '|| p_cod_ts_contrato ||' - v_cod_entidade_ts: '|| v_cod_entidade_ts;
                          RAISE err_nao_previsto;
                    END;
                 END IF;
              --** POR CONTRATO / BENEFICIÁRIO Revalida Situação de Beneficiários
              ELSE
                 v_posicao := 470;
                 FOR CA IN (SELECT B.cod_ts,
                                   B.ind_situacao,
                                   B.data_exclusao,
                                   B.cod_ts_tit,
                                   BC.cod_motivo_exclusao,
                                   BC.usuario_exc,
                                   B.data_registro_exclusao,
                                   NVL(B_TIT.ind_apos_dem, 'N') ind_apos_dem,
                                   NVL(B_TIT.ind_acao_jud, 'N') ind_acao_jud
                             FROM beneficiario B,
                                  beneficiario_contrato  BC,
                                  beneficiario_contrato  B_TIT,
                                  contrato_empresa CE
                             WHERE B.cod_ts_contrato = CE.cod_ts_contrato
                               AND B.cod_ts_TIT = B_TIT.cod_ts (+)
                               and B.cod_ts = BC.cod_ts (+)
                               AND ce.cod_ts_contrato = p_cod_ts_contrato
                               AND (v_cod_ts IS NULL OR (v_cod_ts IS NOT NULL AND B.cod_ts_tit = v_cod_ts))
                               AND B.ind_situacao IN ('A', 'S', 'P')
                               AND NVL(BC.ind_isento, 'N') != 'S'
                               AND B.ind_situacao != 'E'
                               AND B.ind_situacao != v_ind_situacao_associado)
                 LOOP
                     IF v_ind_situacao_associado = 'E' THEN
                        BEGIN
                           execute immediate ' UPDATE associado ' ||
                                             ' SET ind_situacao = :v_ind_situacao_associado, ' ||
                                             '     data_exclusao = TRUNC(SYSDATE),   ' ||
                                             '     cod_motivo_exclusao = :v_cod_situacao_associado, ' ||
                                             '     usuario_exc =  :p_cod_usuario,    ' ||
                                             '     data_registro_exclusao = sysdate, ' ||
                                             '     cod_usuario_atu = :p_cod_usuario, ' ||
                                             '     dt_atu = sysdate ' ||
                                             ' WHERE  cod_ts = :v_cod_ts '
                           using v_ind_situacao_associado,
                                 v_cod_situacao_associado,
                                 p_cod_usuario,
                                 p_cod_usuario,
                                 CA.cod_ts;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_erro_oracle := top_utl_padrao.MsgErro;
                              p_msg_retorno_out := 'Erro na atualização da situação dos beneficiários da empresa, cod_ts_contrato: '|| p_cod_ts_contrato|| ' - cod_entidade_ts: '|| v_cod_entidade_ts;
                              RAISE ERR_NAO_PREVISTO;
                        END;
                        -- Finalizar os aditivos
                         FINALIZA_ADITIVO (TRUNC(SYSDATE), p_cod_ts_contrato, CA.cod_ts, null );
                     ELSE
                        BEGIN
                           execute immediate ' UPDATE associado ass ' ||
                                             ' SET ind_situacao = :v_ind_situacao_associado, ' ||
                                             '     cod_usuario_atu = :p_cod_usuario, ' ||
                                             '     dt_atu = sysdate                  ' ||
                                             ' WHERE cod_ts = :v_cod_ts              ' ||
                                             '   AND ((ind_situacao != ''S'' ) OR    ' ||
                                             '        (ind_situacao = ''S'' AND NOT EXISTS (SELECT 1  ' ||
                                             '                                              FROM ASSOCIADO_SUSPENSO SUSP    ' ||
                                             '                                              WHERE ass.cod_ts = SUSP.cod_ts  ' ||
                                             '                                                and (data_fim_suspensao IS NULL OR  ' ||
                                             '                                                   trunc(data_fim_suspensao) > trunc(sysdate)))))'
                           using v_ind_situacao_associado,
                                 p_cod_usuario,
                                 CA.cod_ts ;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_erro_oracle := top_utl_padrao.MsgErro;
                              p_msg_retorno_out := 'Erro na atualização da situação dos beneficiários da empresa, contrato: '|| p_cod_ts_contrato || ' - cod_entidade_ts: '|| v_cod_entidade_ts;
                              RAISE ERR_NAO_PREVISTO;
                        END;
                     END IF;
                 END LOOP;
              END IF;
            END IF;
         END IF;
         IF (v_ind_situacao_contrato = 'E' or v_ind_situacao_associado = 'E')  and v_ind_cancela_faturas = 'S' THEN
            -- Cancelamento das faturas emitidas
            FOR CFat IN (select f.num_seq_fatura_ts
                           from fatura f,
                                ciclo_faturamento cf,
                                extrato_contrato ec,
                                cobranca co
                          where f.num_ciclo_ts = cf.num_ciclo_ts
                            and f.num_ciclo_ts = ec.num_ciclo_ts
                            and f.cod_ts_contrato = ec.cod_ts_contrato
                            and f.cod_ts_contrato = p_cod_ts_contrato
                            and f.num_seq_fatura_ts = co.num_seq_fatura_ts
                            and co.ind_estado_cobranca = '0'
                            and ec.dt_ini_periodo > v_data_canc_fatura
                            and (v_cod_ts is null          or f.cod_ts = v_cod_ts)
                            and (v_cod_entidade_ts is null or f.cod_entidade_ts = v_cod_entidade_ts)
                            and f.ind_situacao in ('2', '8')
                            and (nvl(f.ind_apos_dem,'N') = 'N' OR v_exclui_apos_dem = 'S')
                            and cf.cod_tipo_ciclo = 1)
            LOOP
               v_posicao := 480;
               execute immediate 'begin fat_cancela_fatura( :p_num_seq_fatura_ts,
                                                            :p_txt_motivo_cancelamento,
                                                            :p_cod_usuario,
                                                            :p_ind_erro_out,
                                                            :p_msg_retorno_out,
                                                            :p_commit,
                                                            :p_ind_trata_inadimplencia,
                                                            :p_ind_desfaz_faturamento ); end; '
               using in  CFat.num_seq_fatura_ts,
                     in  'Cancelamento automatico por inadimplencia',
                     in  p_cod_usuario,
                     out p_ind_erro_out,
                     out p_msg_retorno_out,
                     in  'N',
                     in  'N',
                     in  'S';
               IF p_ind_erro_out != 0 THEN
                  v_erro_oracle := top_utl_padrao.MsgErro;
                  RAISE ERR_NAO_PREVISTO;
               END IF;
            END LOOP;
            --
            -- Desfazendo os Itens sem cobrança ou de fatura não emitida
            FOR CFat2 IN (select c.num_ciclo_ts
                          from cobranca c,
                               ciclo_faturamento cf,
                               contrato_empresa ce
                          where ce.cod_ts_contrato = c.cod_ts_contrato
                            and c.num_ciclo_ts = cf.num_ciclo_ts
                            and cf.cod_tipo_ciclo = 1
                            and c.ind_estado_cobranca = '0'
                            and c.dt_emissao is null
                            and (nvl(c.ind_apos_dem,'N') = 'N' OR v_exclui_apos_dem = 'S')
                            and c.cod_ts_contrato = p_cod_ts_contrato
                            and (v_cod_ts is null          or c.cod_ts = v_cod_ts)
                            and (v_cod_entidade_ts is null or c.cod_entidade_ts = v_cod_entidade_ts)
                          union
                          select ic.num_ciclo_ts
                          from itens_cobranca ic,
                               ciclo_faturamento cf,
                               contrato_empresa ce,
                               tipo_contrato tc
                          where ce.cod_ts_contrato = ic.cod_ts_contrato
                            and ic.num_ciclo_ts = cf.num_ciclo_ts
                            and ce.cod_tipo_contrato = tc.cod_tipo_contrato
                            and cf.cod_tipo_ciclo = 1
                            and ic.num_seq_cobranca is null
                            and ic.num_item_pagamento_ts is null
                            and ic.val_item_cobranca != 0
                            and (nvl(ic.ind_apos_dem,'N') = 'N' OR v_exclui_apos_dem = 'S')
                            and ic.cod_ts_contrato = p_cod_ts_contrato
                            and (v_cod_ts is null          or ic.cod_ts_titular = v_cod_ts)
                            and (v_cod_entidade_ts is null or ic.cod_entidade_ts = v_cod_entidade_ts)
               )
            LOOP
               v_posicao := 490;
               fat_desfaz_faturamento ( p_ind_erro_out             => p_ind_erro_out
                                      , p_msg_retorno_out          => p_msg_retorno_out
                                      , p_cod_operadora            => null
                                      , p_cod_sucursal             => null
                                      , p_cod_inspetoria_ts        => null
                                      , p_num_ciclo_ts             => CFat2.Num_Ciclo_Ts
                                      , p_dia_vencimento_ini       => null
                                      , p_dia_vencimento_fim       => null
                                      , p_ind_tipo_vencimento      => null
                                      , p_qtd_meses                => null
                                      , p_cod_ts_contrato_matriz   => null
                                      , p_cod_ts_contrato          => p_cod_ts_contrato
                                      , p_cod_tipo_contrato        => null
                                      , p_tipo_empresa             => null
                                      , p_cod_grupo_empresa        => null
                                      , p_sgl_area                 => null
                                      , p_cod_ts_titular           => v_cod_ts
                                      , p_ind_tipo_pessoa          => 'A'
                                      , p_ind_forma_cobranca       => null
                                      , p_qtd_laminas              => null
                                      , p_mes_aniversario          => null
                                      , p_ind_coparticipacao       => null
                                      , p_cod_usuario              => p_cod_usuario
                                      , p_endereco_ip              => null
                                      , p_commit                   => 'N'
                                      , p_versao                   => 'N'
                                      , p_desprezar_emitidos       => 'S');
               IF p_ind_erro_out != '0' THEN
                  p_msg_retorno_out := 'Erro gerado pela PROCEDURE FAT_DESFAZ_FATURAMENTO : '||p_msg_retorno_out;
                  RAISE err_previsto;
               END IF;
            END LOOP;
         END IF;
      EXCEPTION
         WHEN ERR_ADVERTENCIA THEN
            p_ind_erro_out := '3';
            RAISE ERR_TRATA_ERRO;
         WHEN ERR_PREVISTO THEN
            p_ind_erro_out := '1';
            RAISE ERR_TRATA_ERRO;
         WHEN ERR_NAO_PREVISTO THEN
            p_ind_erro_out := '2';
            RAISE ERR_TRATA_ERRO;
         WHEN OTHERS THEN
            p_msg_retorno_out := top_utl_padrao.MsgErro;
            v_erro_oracle := top_utl_padrao.MsgErro;
            p_ind_erro_out := '2';
            RAISE ERR_TRATA_ERRO;
      END;
   EXCEPTION
      WHEN ERR_TRATA_ERRO THEN
          ts_log_execucao ('SUR_TRATA_INADIMPLENCIA',
                           v_posicao,
                           v_erro_oracle,
                           v_txt_parametros,
                           p_msg_retorno_out,
                           1);
   END;
END;
