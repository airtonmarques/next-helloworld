--B = a��o de benefici�rio  C = a��o de contrato
select distinct
       b.num_associado numBeneficiario,
       b.nome_associado nomeBeneficiario,
       lpad(be.num_cpf, 11, '0') CPFBeneficiario,
       b.ind_situacao situacaoBeneficiario,
       bc.data_adesao dataAdesao,
       b.data_exclusao dataExclusao,
       op.nom_operadora operadora,
       ce.num_contrato numContrato,
       es.nome_entidade nomeContrato,
       aj.num_processo processo,
       aj.dt_ini_acao dataCitacao,
       maj.nome_motivo_acao motivoAcao,
       sub.nome_sub_motivo_acao subMotivoAcao,
       aj.ind_situacao_durante situacaoBeneficiarioDurante,
       decode(aj.ind_faturamento, 'S', 'Sim', 'N�o') faturar,
       decode(aj.ind_inadimplencia, 'S', 'Sim', 'N�o') aplicarInadimplencia,
       aj.polo_ativo poloAtivo,
       aj.polo_passivo_1 poloPassivo1,
       aj.polo_passivo_2 poloPassivo2,
       
       (select decode(itensResp.Ind_Resposta, 'S', 'Sim', 'N', 'N�o', itensResp.Txt_Resposta)
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 9
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) temDepositoJudicial,
        
        (select decode(itensResp.Ind_Resposta, 'S', 'Sim', 'N', 'N�o', itensResp.Txt_Resposta)
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 12
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) cobrarTaxaAdministrativa,
        
        (select decode(itensResp.Ind_Resposta, 'S', 'Sim', 'N', 'N�o', itensResp.Txt_Resposta)
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 13
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) cobrarMensalidadeAssociativa,
        
        (select decode(itensResp.Ind_Resposta, 'S', 'Sim', 'N', 'N�o', itensResp.Txt_Resposta)
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 15
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) haMensalidadeOperadora,
              
        (select decode(itensResp.Ind_Resposta, 'S', 'Sim', 'N', 'N�o', itensResp.Txt_Resposta)
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 16
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) reajusteAnual,
        
        (select itensResp.Txt_Resposta
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 17
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) baseReajusteAnual,   
              
        (select decode(itensResp.Ind_Resposta, 'S', 'Sim', 'N', 'N�o', itensResp.Txt_Resposta)
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 18
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) reajusteFaixaEtaria, 
              
        (select itensResp.Txt_Resposta
        from ts.ASS_ITENS_ORIE_JURIDICA itens
             join ts.ASS_DADOS_RESPOSTA_ITENS_OJ itensResp 
                  on itensResp.Cod_Item_Orie_Juridica = itens.cod_item_orie_juridica
        where itens.cod_item_orie_juridica = 19
              and itensResp.Cod_Acao_Ts = aj.cod_acao_ts) baseReajusteFaixaEtaria,  
        aj.dt_fim_acao dataEncerramento,
        saj.txt_situacao_acao Situacao,
        aj.ind_situacao_apos situacaoApos      
        
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
           and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.acao_jud_pgto aj on aj.cod_ts = b.cod_ts
     left join ts.motivo_acao_jud maj on maj.cod_motivo_acao = aj.cod_motivo_acao
     left join ts.con_sub_motivo_acao_jud sub on sub.cod_sub_motivo_acao = aj.cod_sub_motivo_acao
     left join ts.situacao_acao_judicial saj on saj.cod_situacao = aj.cod_situacao
--where b.num_associado = 1002101
     
